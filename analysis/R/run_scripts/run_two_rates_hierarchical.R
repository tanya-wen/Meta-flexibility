library("rstan") # observe startup messages
library("tidyverse")
setwd("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility")
#setwd("/Users/rmgeddert/Box Sync/meta-flexibility")

# choose which Experiment to analyze
exp_num = 1;

#read the list of behavioral files
subFiles = list.files(path=sprintf("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility/experiment%i/",exp_num), pattern="*.log")
#subFiles = list.files(path=sprintf("/Users/rmgeddert/Box Sync/meta-flexibility/experiment%i/",exp_num), pattern="*.log")

#for each subject, load data, and add to data frame
allSubjects <- data.frame() 
subject_total_acc = list();
for (subj in 1:length(subFiles)) {
  # read subject data
  sub_dat = read.csv(file.path(sprintf("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility/experiment%i/",exp_num),subFiles[subj]));
  #sub_dat = read.csv(file.path(sprintf("/Users/rmgeddert/Box Sync/meta-flexibility/experiment%i/",exp_num),subFiles[subj]));
  # calculate subject accuracy
  subject_total_acc[subj] = mean(as.integer(as.logical(sub_dat$response_acc[41:280])),na.rm=TRUE)
  # analyze good subjects only
  if (subject_total_acc[subj] >= 0.65) {
    allSubjects = rbind(allSubjects, sub_dat)
  }
}

allSubjects_transfer <- allSubjects %>% 
  filter(practice=="false") %>% 
  filter(trial >= 120) %>% 
  mutate(madeChoice = ifelse(response_time > 300, 1, 0)) %>% 
  mutate(sub_num = group_indices(., subject)) %>% 
  mutate(trial_num = trial - 119) %>% 
  mutate(picked_rule = ifelse(madeChoice == 0, 0, ifelse(as.character(type) == type[1], ifelse(as.character(answer) == as.character(response), 1, 2), 
                              ifelse(as.character(answer) == as.character(response), 2, 1)))) %>% 
  mutate(result = ifelse(reward_validity == 1, ifelse(as.character(answer) == as.character(response), 1, 0), 
                         ifelse(as.character(answer) == as.character(response), 0, 1))) %>% 
  mutate(group = ifelse(volatility == "high", 1, 0))

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
                       group = allSubjects_details$group
                      )

# model fitting
model_fit <- stan(
  file = "models/two_rates_hierarchical.stan",  # Stan program
  data = data_for_model,    # named list of data
  chains = 1,             # number of Markov chains
  warmup = 200,          # number of warmup iterations per chain
  iter = 400,            # total number of iterations per chain
  cores = 2              # number of cores (could use one per chain)
)

# visualize diagnostics
print(model_fit, pars=c("eta_R_mu", "eta_R_sigma", "eta_U_mu", "eta_U_sigma", "beta_mu", "beta_sigma", "alpha_R_mu", "alpha_R_sigma", "group_effect_eta_R", "alpha_U_mu", "alpha_U_sigma", "group_effect_eta_U", "group_effect_beta", "starting_utility"), probs=c(.1,.5,.9))

traceplot(model_fit, pars = c("eta_R_mu", "eta_R_sigma", "eta_U_mu", "eta_U_sigma", "beta_mu", "beta_sigma", "alpha_R_mu", "alpha_R_sigma", "group_effect_eta_R", "alpha_U_mu", "alpha_U_sigma", "group_effect_eta_U", "group_effect_beta", "starting_utility"), inc_warmup = TRUE, nrow = 2)

# hyperparameters posterior distributions
stan_hist(model_fit, pars = c("eta_R_mu", "eta_R_sigma", "eta_U_mu", "eta_U_sigma", "beta_mu", "beta_sigma", "alpha_R_mu", "alpha_R_sigma", "group_effect_eta_R", "alpha_U_mu", "alpha_U_sigma", "group_effect_eta_U", "group_effect_beta", "starting_utility"))

# loo for model comparison
loo_fit <- loo::loo(model_fit)
loo_fit
