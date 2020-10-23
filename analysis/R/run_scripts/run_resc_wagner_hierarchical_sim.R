library("rstan") # observe startup messages
library("tidyverse")
setwd("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility")
# setwd("/Users/rmgeddert/Box/meta-flexibility")

# # choose which Experiment to analyze
# exp_num = 1;
# 
# #read the list of behavioral files
# #subFiles = list.files(path=sprintf("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility/experiment%i/",exp_num), pattern="*.log")
# subFiles = list.files(path=sprintf("/Users/rmgeddert/Box Sync/meta-flexibility/experiment%i/",exp_num), pattern="*.log")
# 
# #for each subject, load data, and add to data frame
# allSubjects <- data.frame() 
# subject_total_acc = list();
# for (subj in 1:length(subFiles)) {
#   # read subject data
#   #sub_dat = read.csv(file.path(sprintf("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility/experiment%i/",exp_num),subFiles[subj]));
#   sub_dat = read.csv(file.path(sprintf("/Users/rmgeddert/Box Sync/meta-flexibility/experiment%i/",exp_num),subFiles[subj]));
#   # calculate subject accuracy
#   subject_total_acc[subj] = mean(as.integer(as.logical(sub_dat$response_acc[41:280])),na.rm=TRUE)
#   # analyze good subjects only
#   if (subject_total_acc[subj] >= 0.65) {
#     allSubjects = rbind(allSubjects, sub_dat)
#   }
# }
allSubjects = read.csv("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility/simulated_data/RW_hierarchical_simulated_data.csv")
# allSubjects = read.csv("/Users/rmgeddert/Box/meta-flexibility/simulated_data/RW_hierarchical_simulated_data.csv")

allSubjects_details <- allSubjects %>% 
  select(subject, group) %>% 
  group_by(subject) %>% 
  summarise(group = mean(group) - 1)
  
# create list object for passing data to stan models
data_for_model <- list(nSubjects = length(unique(allSubjects$subject)),
                       TotalTrials = nrow(allSubjects), 
                       madeChoiceTrials = sum(allSubjects$madeChoice), # excluding trials where no choice is made
                       Subject = allSubjects$subject, # continuous subject index, different from subject number
                       TrialNum = allSubjects$trialCount,
                       choices = allSubjects$choices, 
                       rewards = allSubjects$rewards,
                       group = allSubjects_details$group
                      )

# model fitting
model_fit <- stan(
  file = "models/resc_wagner_hierarchical.stan",  # Stan program
  data = data_for_model,    # named list of data
  chains = 1,             # number of Markov chains
  warmup = 200,          # number of warmup iterations per chain
  iter = 400,            # total number of iterations per chain
  cores = 1              # number of cores (could use one per chain)
)

# visualize diagnostics
print(model_fit, pars=c("eta_mu", "eta_sigma","alpha_mu_group1","alpha_sigma_group1","alpha_mu_group2","alpha_sigma_group2","beta_mu","beta_sigma","group_effect_eta","group_effect_beta","group_effect_alpha","starting_utility"), probs=c(.1,.5,.9))

traceplot(model_fit, pars = c("eta_mu", "eta_sigma","beta_mu","beta_sigma","starting_utility"), inc_warmup = TRUE, nrow = 2)

# hyperparameters posterior distributions
stan_hist(model_fit, pars = c("eta_mu", "eta_sigma","alpha_mu_group1","alpha_sigma_group1","alpha_mu_group2","alpha_sigma_group2","beta_mu","beta_sigma","group_effect_eta","group_effect_beta","group_effect_alpha","starting_utility"))

# view individual subject estimates
summary(model_fit,"alphas")

# loo for model comparison
loo_fit <- loo::loo(model_fit)
loo_fit
