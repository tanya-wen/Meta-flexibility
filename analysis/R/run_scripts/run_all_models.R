library("rstan") # observe startup messages
library("tidyverse")
setwd("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility")
# load("~/Box/meta-flexibility/RData.RData")
# setwd("/Users/rmgeddert/Box/meta-flexibility")

# choose which Experiment to analyze
exp_num = 3;

#read the list of behavioral files
subFiles = list.files(path=sprintf("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility/experiment%i/",exp_num), pattern="*.log")
#subFiles = list.files(path=sprintf("/Users/rmgeddert/Box/meta-flexibility/experiment%i/",exp_num), pattern="*.log")

#for each subject, load data, and add to data frame
allSubjects <- data.frame() 
subject_total_acc = list();
for (subj in 1:length(subFiles)) {
  # read subject data
  sub_dat = read.csv(file.path(sprintf("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility/experiment%i/",exp_num),subFiles[subj]));
  #sub_dat = read.csv(file.path(sprintf("/Users/rmgeddert/Box/meta-flexibility/experiment%i/",exp_num),subFiles[subj]));
  # calculate subject accuracy
  subject_total_acc[subj] = mean(as.integer(as.logical(sub_dat$response_acc[41:280])),na.rm=TRUE)
  # analyze good subjects only
  if (subject_total_acc[subj] >= 0.65) {
    allSubjects = rbind(allSubjects, sub_dat)
  }
}

# fix missing data (NA)
allSubjects <- allSubjects %>% 
  mutate(response = ifelse(is.na(response), "none", response)) %>% 
  mutate(response_time = ifelse(is.na(response_time), 0, response_time)) %>% 
  mutate(response_acc = ifelse(is.na(response_acc), "false", response_acc))

# organize transfer data
allSubjects_transfer <- allSubjects %>% 
  filter(practice=="false") %>% 
  filter(as.numeric(trial) >= 120) %>% 
  mutate(madeChoice = ifelse(response_time > 300, 1, 0)) %>% 
  mutate(sub_num = group_indices(., subject)) %>% 
  mutate(trial_num = as.numeric(trial) - 119) %>% 
  mutate(picked_rule = ifelse(madeChoice == 0, 0, ifelse(as.character(type) == type[1], ifelse(as.character(answer) == as.character(response), 1, 2), 
                              ifelse(as.character(answer) == as.character(response), 2, 1)))) %>% 
  mutate(result = ifelse(reward_validity == 1, ifelse(as.character(answer) == as.character(response), 1, 0), 
                         ifelse(as.character(answer) == as.character(response), 0, 1))) %>% 
  mutate(group = ifelse(volatility == "high", 1, 0)) %>% 
  mutate(activeRule = ifelse(result==1, picked_rule, ifelse(picked_rule==1, 2, 1)))

allSubjects_details <- allSubjects_transfer %>% 
  select(subject, sub_num, group) %>% 
  group_by(subject) %>% 
  summarise(group = mean(group), sub_num = mean(sub_num))
  
# create list object for passing data to stan models
data_for_model <- list(nSubjects = length(unique(allSubjects_transfer$sub_num)),
                       TotalTrials = nrow(allSubjects_transfer), 
                       madeChoiceTrials = sum(allSubjects_transfer$madeChoice), # excluding trials where no choice is made
                       Subject = allSubjects_transfer$sub_num, # continuous subject index, different from subject number
                       TrialNum = allSubjects_transfer$trial_num,
                       choices = allSubjects_transfer$picked_rule, 
                       rewards = allSubjects_transfer$result,
                       activeRule = allSubjects_transfer$activeRule,
                       group = allSubjects_details$group
                      )

##### Rescorla Wagner #####
model_fit_RW <- stan(
  file = "models/resc_wagner_hierarchical.stan",  # Stan program
  data = data_for_model,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 500,          # number of warmup iterations per chain
  iter = 1000,            # total number of iterations per chain
  cores = 4              # number of cores (could use one per chain)
)

# visualize diagnostics
print(model_fit_RW, pars=c("eta_mu", "eta_sigma","beta_mu","beta_sigma","alpha_mu_group1","alpha_sigma_group1","alpha_mu_group2","alpha_sigma_group2","group_effect_eta","group_effect_beta","group_effect_alpha","starting_utility"), probs=c(.1,.5,.9))

traceplot(model_fit_RW, pars = c("eta_mu", "eta_sigma","beta_mu","beta_sigma","starting_utility"), inc_warmup = TRUE, nrow = 2)

# hyperparameters posterior distributions
stan_hist(model_fit_RW, pars = c("eta_mu", "eta_sigma","beta_mu","beta_sigma","alpha_mu_group1","alpha_sigma_group1","alpha_mu_group2","alpha_sigma_group2","group_effect_eta","group_effect_beta","group_effect_alpha","starting_utility"))

# loo for model comparison
loo_fit_RW <- loo::loo(model_fit_RW)
loo_fit_RW

##### Two Rates RW #####
model_fit_2R <- stan(
  file = "models/two_rates_hierarchical.stan",  # Stan program
  data = data_for_model,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 500,          # number of warmup iterations per chain
  iter = 1000,            # total number of iterations per chain
  cores = 4              # number of cores (could use one per chain)
)

# visualize diagnostics
print(model_fit_2R, pars=c("eta_R_mu", "eta_R_sigma", "eta_U_mu", "eta_U_sigma", "beta_mu", "beta_sigma", "alpha_R_mu_group1", "alpha_R_sigma_group1", "alpha_U_mu_group1", "alpha_U_sigma_group1", "alpha_R_mu_group2", "alpha_R_sigma_group2", "alpha_U_mu_group2", "alpha_U_sigma_group2", "group_effect_eta_R", "group_effect_eta_U", "group_effect_beta", "group_effect_alpha_R", "group_effect_alpha_U", "starting_utility"), probs=c(.1,.5,.9))

traceplot(model_fit_2R, pars = c("eta_R_mu", "eta_R_sigma", "eta_U_mu", "eta_U_sigma", "beta_mu", "beta_sigma", "group_effect_eta_R", "group_effect_eta_U", "group_effect_beta", "starting_utility"), inc_warmup = TRUE, nrow = 2)

# hyperparameters posterior distributions
stan_hist(model_fit_2R, pars = c("eta_R_mu", "eta_R_sigma", "eta_U_mu", "eta_U_sigma", "beta_mu", "beta_sigma", "alpha_R_mu_group1", "alpha_R_sigma_group1", "alpha_U_mu_group1", "alpha_U_sigma_group1", "alpha_R_mu_group2", "alpha_R_sigma_group2", "alpha_U_mu_group2", "alpha_U_sigma_group2", "group_effect_eta_R", "group_effect_eta_U", "group_effect_beta", "group_effect_alpha_R", "group_effect_alpha_U", "starting_utility"))

# loo for model comparison
loo_fit_2R <- loo::loo(model_fit_2R)
loo_fit_2R

##### Pearce Hall #####
model_fit_PH <- stan(
  file = "models/pearce_hall_hierarchical.stan",  # Stan program
  data = data_for_model,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 500,          # number of warmup iterations per chain
  iter = 1000,            # total number of iterations per chain
  cores = 4              # number of cores (could use one per chain)
)

# visualize diagnostics
print(model_fit_PH, pars=c("eta_mu","eta_sigma","beta_mu","beta_sigma","gamma_mu","gamma_sigma","alpha_mu_group1","alpha_sigma_group1","alpha_mu_group2","alpha_sigma_group2","omega_mu_group1","omega_sigma_group1","omega_mu_group2","omega_sigma_group2","group_effect_eta","group_effect_beta","group_effect_alpha","group_effect_gamma","starting_utility"), probs=c(.1,.5,.9))

traceplot(model_fit_PH, pars = c("eta_mu", "eta_sigma","beta_mu","beta_sigma","gamma_mu","gamma_sigma","starting_utility"), inc_warmup = TRUE, nrow = 2)

# hyperparameters posterior distributions
stan_hist(model_fit_PH, pars = c("eta_mu","eta_sigma","beta_mu","beta_sigma","gamma_mu","gamma_sigma","alpha_mu_group1","alpha_sigma_group1","alpha_mu_group2","alpha_sigma_group2","omega_mu_group1","omega_sigma_group1","omega_mu_group2","omega_sigma_group2","group_effect_eta","group_effect_beta","group_effect_alpha","group_effect_gamma","starting_utility"))

# loo for model comparison
loo_fit_PH <- loo::loo(model_fit_PH)
loo_fit_PH

##### Pearce Hall Reduced Parameters #####
model_fit_PH_simple <- stan(
  file = "models/pearce_hall_hierarchical_simple.stan",  # Stan program
  data = data_for_model,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 500,          # number of warmup iterations per chain
  iter = 1000,            # total number of iterations per chain
  cores = 4              # number of cores (could use one per chain)
)

# visualize diagnostics
print(model_fit_PH_simple, pars=c("eta_mu","eta_sigma","beta_mu","beta_sigma","gamma_mu","gamma_sigma","alpha_mu","alpha_sigma","omega_mu","omega_sigma","starting_utility"), probs=c(.1,.5,.9))

traceplot(model_fit_PH_simple, pars = c("eta_mu", "eta_sigma","beta_mu","beta_sigma","gamma_mu","gamma_sigma","starting_utility"), inc_warmup = TRUE, nrow = 2)

# hyperparameters posterior distributions
stan_hist(model_fit_PH_simple, pars = c("eta_mu", "eta_sigma","beta_mu","beta_sigma","alpha_mu","alpha_sigma","starting_utility"))

# loo for model comparison
loo_fit_PH_simple <- loo::loo(model_fit_PH_simple)
loo_fit_PH_simple

##### State Learning #####
model_fit_SL <- stan(
  file = "models/state_learning_hierarchical.stan",  # Stan program
  data = data_for_model,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 500,          # number of warmup iterations per chain
  iter = 1000,            # total number of iterations per chain
  cores = 4              # number of cores (could use one per chain)
)

# visualize diagnostics
print(model_fit_SL, pars=c("eta_mu", "eta_sigma","beta_mu","beta_sigma","alpha_mu_group1","alpha_sigma_group1","alpha_mu_group2","alpha_sigma_group2","group_effect_eta","group_effect_beta","group_effect_alpha","starting_utility"), probs=c(.1,.5,.9))

traceplot(model_fit_SL, pars = c("eta_mu", "eta_sigma","beta_mu","beta_sigma","starting_utility"), inc_warmup = TRUE, nrow = 2)

# hyperparameters posterior distributions
stan_hist(model_fit_SL, pars = c("eta_mu", "eta_sigma","beta_mu","beta_sigma","alpha_mu_group1","alpha_sigma_group1","alpha_mu_group2","alpha_sigma_group2","group_effect_eta","group_effect_beta","group_effect_alpha","starting_utility"))

# loo for model comparison
loo_fit_SL <- loo::loo(model_fit_SL)
loo_fit_SL

##### Choice Auto correlation model
model_fit_CA <- stan(
  file = "models/choice_auto_hierarchical.stan",  # Stan program
  data = data_for_model,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 500,          # number of warmup iterations per chain
  iter = 1000,            # total number of iterations per chain
  cores = 4              # number of cores (could use one per chain)
)

# visualize diagnostics
print(model_fit_CA, pars=c("eta_mu", "eta_sigma", "beta_mu", "beta_sigma", "phi_mu", "phi_sigma", "theta_mu", "theta_sigma", "alpha_mu_group1", "alpha_sigma_group1", "alpha_mu_group2", "alpha_sigma_group2", "group_effect_eta", "group_effect_beta","group_effect_alpha", "group_effect_phi", "group_effect_theta", "starting_utility"), probs=c(.1,.5,.9))

traceplot(model_fit_CA, pars = c("eta_mu", "eta_sigma", "beta_mu", "beta_sigma", "phi_mu", "phi_sigma", "theta_mu", "theta_sigma", "group_effect_beta", "group_effect_alpha", "group_effect_phi", "group_effect_theta", "starting_utility"), inc_warmup = TRUE, nrow = 2)

# hyperparameters posterior distributions
stan_hist(model_fit_CA, pars = c("eta_mu", "eta_sigma", "beta_mu", "beta_sigma", "phi_mu", "phi_sigma", "theta_mu", "theta_sigma", "alpha_mu_group1", "alpha_sigma_group1", "alpha_mu_group2", "alpha_sigma_group2", "group_effect_eta", "group_effect_beta","group_effect_alpha", "group_effect_phi", "group_effect_theta", "starting_utility"))

# loo for model comparison
loo_fit_CA <- loo::loo(model_fit_CA)
loo_fit_CA

##### Compare Models #####
loo::loo_compare(loo_fit_RW, loo_fit_2R, loo_fit_SL, loo_fit_PH)