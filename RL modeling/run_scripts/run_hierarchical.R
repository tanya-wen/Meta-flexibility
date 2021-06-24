library("rstan") # observe startup messages
library("tidyverse")
setwd("C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility")

allSubjects <- data.frame() 
subject_total_acc = list();
subject_learning_acc = list();
subject_transfer_acc = list();

for (exp_num in 1:3) {
  #read the list of behavioral files
  subFiles = list.files(path=sprintf("C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/mturk data/experiment%i",exp_num), pattern="*.log")
  
  for (subj in 1:length(subFiles)) {
    # read subject data
    sub_dat = read.csv(file.path(sprintf("C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/mturk data/experiment%i",exp_num),subFiles[subj]));
    sub_dat = sub_dat[,!(names(sub_dat) %in% c("sequence"))]
    sub_dat$experiment <- exp_num
    # calculate subject accuracy
    subject_total_acc[subj] = mean(as.integer(as.logical(sub_dat$response_acc[41:280])),na.rm=TRUE)
    subject_learning_acc[subj] = mean(as.integer(as.logical(sub_dat$response_acc[41:160])),na.rm=TRUE)
    subject_transfer_acc[subj] = mean(as.integer(as.logical(sub_dat$response_acc[161:280])),na.rm=TRUE)
    # analyze good subjects only
    if (subject_total_acc[subj] >= 0.65) {
      allSubjects = rbind(allSubjects, sub_dat)
    }
  }
}

# fix missing data (NA)
allSubjects <- allSubjects %>%
  mutate(response = ifelse(is.na(response), "none", response)) %>%
  mutate(response_time = ifelse(is.na(response_time), 0, response_time)) %>%
  mutate(response_acc = ifelse(is.na(response_acc), "false", response_acc))

allSubjects_data <- allSubjects %>% 
  filter(practice=="false") %>% 
  mutate(phase = ifelse(as.numeric(trial) >= 120, 2, 1)) %>% 
  mutate(madeChoice = ifelse(response_time > 300, 1, 0)) %>% 
  mutate(sub_num = group_indices(., subject)) %>% 
  group_by(sub_num) %>% 
  mutate(trial_num = as.numeric(trial)+1) %>% 
  mutate(picked_rule = ifelse(madeChoice == 0, 0, # if madeChoice = 0, set picked_rule to 0
                              ifelse(phase == 1, ifelse(as.character(type) == type[1], ifelse(as.character(answer) == as.character(response), 1, 2), # if madeChoice = 1 && if phase = 1 && if current rule is the same as first rule (e.g., first trial = color, current trial = color) if answer is the same as response, set picked_rule to 1 else set to 2
                                                         ifelse(as.character(answer) == as.character(response), 2, 1)), # if madeChoice = 1 && if phase = 1 && if current rule is differen from the first rule (e.g., first trial = color, current trial = shape), if answer is the same as response, set picked_rule to 2 else set to 1
                              ifelse(as.character(type) == type[121], ifelse(as.character(answer) == as.character(response), 1, 2), # if madeChoice = 1 && if phase = 2 && if current rule is the same as first rule (e.g., first trial = race, current trial = race) if answer is the same as response, set picked_rule to 1 else set to 2
                                     ifelse(as.character(answer) == as.character(response), 2, 1))))) %>% # if madeChoice = 1 && if phase = 2 && if current rule is differen from the first rule (e.g., first trial = race, current trial = gender), if answer is the same as response, set picked_rule to 2 else set to 1
  mutate(rewards = ifelse(reward_validity == 1, ifelse(as.character(answer) == as.character(response), 1, 0), 
                         ifelse(as.character(answer) == as.character(response), 0, 1))) %>% 
  mutate(group = ifelse(volatility == "high", 2, 1))

allSubjects_details <- allSubjects_data %>% 
  select(subject, sub_num, group, experiment) %>% 
  group_by(subject) %>% 
  summarise(group = mean(group), sub_num = mean(sub_num), experiment = mean(as.numeric(experiment)))

allSubjects_data = subset(allSubjects_data, select = -c(age,race,gender,ethnicity,color,vision,neuro))

# create list object for passing data to stan models
data_for_model <- list(nSubjects = length(unique(allSubjects_data$sub_num)),
                       nChoices = 2,
                       nGroups = 2,
                       nPhases = 2,
                       nExperiments = 3,
                       nTrials = nrow(allSubjects_data), 
                       madeChoiceTrials = sum(allSubjects_data$madeChoice), # excluding trials where no choice is made
                       subject = allSubjects_data$sub_num, # continuous subject index, different from subject number
                       trialNum = allSubjects_data$trial_num,
                       experiment = allSubjects_details$experiment,
                       group = allSubjects_details$group,
                       phase = allSubjects_data$phase,
                       choices = allSubjects_data$picked_rule, 
                       rewards = allSubjects_data$rewards
)

# -------------------------------- model fitting (Resc_Wagner) -------------------------------------#
model_fit_RW <- stan(
  file = "C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/RL modeling/models/resc_wagner_hierarchical.stan",  # Stan program
  data = data_for_model,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 150,          # number of warmup iterations per chain
  iter = 1000,            # total number of iterations per chain
  cores = 4             # number of cores (could use one per chain)
)

# visualize diagnostics
print(model_fit_RW, pars=c("eta_mu_mu", "eta_mu_sigma", "eta_mu", "eta_mu_raw", "eta_sigma", "beta_mu_mu", "beta_mu_sigma", "beta_mu", "beta_mu_raw", "beta_sigma", "starting_utility", "alpha_mu"), probs=c(.1,.5,.9))
traceplot(model_fit_RW, pars = c("eta_mu_mu", "eta_mu_sigma", "eta_mu", "eta_mu_raw", "eta_sigma", "beta_mu_mu", "beta_mu_sigma", "beta_mu", "beta_mu_raw", "beta_sigma", "starting_utility", "alpha_mu"), inc_warmup = TRUE)


# hyperparameters posterior distributions
stan_hist(model_fit_RW, pars = c("eta_mu_mu", "eta_mu_sigma", "eta_mu", "eta_mu_raw", "eta_sigma", "beta_mu_mu", "beta_mu_sigma", "beta_mu", "beta_mu_raw", "beta_sigma", "starting_utility", "alpha_mu"))
# loo for model comparison
loo_fit_RW <- loo::loo(model_fit_RW)
loo_fit_RW



alpha_mu <- rstan::extract(model_fit_RW, pars = 'alpha_mu', permuted = TRUE)$alpha_mu
# Experiment 1: compare learning phase between groups
sum(alpha_mu[ ,1,2,1] > alpha_mu[ ,1,1,1], na.rm = TRUE) / 3400 * 100
sum(alpha_mu[ ,1,2,1] - alpha_mu[ ,1,1,1]) / 3400
quantile(alpha_mu[ ,1,2,1] - alpha_mu[ ,1,1,1],probs=c(.025,.975))
# Experiment 1: compare transfer phase between groups
sum(alpha_mu[ ,2,2,1] > alpha_mu[ ,2,1,1], na.rm = TRUE) / 3400 * 100
sum(alpha_mu[ ,2,2,1] - alpha_mu[ ,2,1,1]) / 3400
quantile(alpha_mu[ ,2,2,1] - alpha_mu[ ,2,1,1],probs=c(.025,.975))
# Experiment 2: compare learning phase between groups
sum(alpha_mu[ ,1,2,2] > alpha_mu[ ,1,1,2], na.rm = TRUE) / 3400 * 100
sum(alpha_mu[ ,1,2,2] - alpha_mu[ ,1,1,2]) / 3400
quantile(alpha_mu[ ,1,2,2] - alpha_mu[ ,1,1,2],probs=c(.025,.975))
# Experiment 2: compare transfer phase between groups
sum(alpha_mu[ ,2,2,2] > alpha_mu[ ,2,1,2], na.rm = TRUE) / 3400 * 100
sum(alpha_mu[ ,2,2,2] - alpha_mu[ ,2,1,2]) / 3400
quantile(alpha_mu[ ,2,2,2] - alpha_mu[ ,2,1,2],probs=c(.025,.975))
# Experiment 3: compare learning phase between groups
sum(alpha_mu[ ,1,2,3] > alpha_mu[ ,1,1,3], na.rm = TRUE) / 3400 * 100
sum(alpha_mu[ ,1,2,3] - alpha_mu[ ,1,1,3]) / 3400
quantile(alpha_mu[ ,1,2,3] - alpha_mu[ ,1,1,3],probs=c(.025,.975))
# Experiment 3: compare transfer phase between groups
sum(alpha_mu[ ,2,2,3] > alpha_mu[ ,2,1,3], na.rm = TRUE) / 3400 * 100
sum(alpha_mu[ ,2,2,3] - alpha_mu[ ,2,1,3]) / 3400
quantile(alpha_mu[ ,2,2,3] - alpha_mu[ ,2,1,3],probs=c(.025,.975))

# ANOVA-like analysis (only for transfer phase)
# Experiment x group interaction
# Exp 1 vs Exp 2
sum((alpha_mu[ ,2,2,1] - alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,2] - alpha_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100
sum((alpha_mu[ ,2,2,1] - alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,2] - alpha_mu[ ,2,1,2])) / 3400
quantile((alpha_mu[ ,2,2,1] - alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,2] - alpha_mu[ ,2,1,2]), probs=c(.025,.975))
# Exp 1 vs Exp 3
sum((alpha_mu[ ,2,2,1] - alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,3] - alpha_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((alpha_mu[ ,2,2,1] - alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,3] - alpha_mu[ ,2,1,3])) / 3400
quantile((alpha_mu[ ,2,2,1] - alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,3] - alpha_mu[ ,2,1,3]), probs=c(.025,.975))
# Exp 2 vs Exp 3
sum((alpha_mu[ ,2,2,2] - alpha_mu[ ,2,1,2]) > (alpha_mu[ ,2,2,3] - alpha_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((alpha_mu[ ,2,2,2] - alpha_mu[ ,2,1,2]) > (alpha_mu[ ,2,2,3] - alpha_mu[ ,2,1,3])) / 3400
quantile((alpha_mu[ ,2,2,2] - alpha_mu[ ,2,1,2]) > (alpha_mu[ ,2,2,3] - alpha_mu[ ,2,1,3]), probs=c(.025,.975))
# Main effect of experiment
# Exp 1 vs Exp 2
sum((alpha_mu[ ,2,2,1] + alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,2] + alpha_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100
sum((alpha_mu[ ,2,2,1] + alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,2] + alpha_mu[ ,2,1,2])) / 3400
quantile((alpha_mu[ ,2,2,1] + alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,2] + alpha_mu[ ,2,1,2]), probs=c(.025,.975))
# Exp 1 vs Exp 3
sum((alpha_mu[ ,2,2,1] + alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,3] + alpha_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((alpha_mu[ ,2,2,1] + alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,3] + alpha_mu[ ,2,1,3])) / 3400
quantile((alpha_mu[ ,2,2,1] + alpha_mu[ ,2,1,1]) > (alpha_mu[ ,2,2,3] + alpha_mu[ ,2,1,3]), probs=c(.025,.975))
# Exp 2 vs Exp 3
sum((alpha_mu[ ,2,2,2] + alpha_mu[ ,2,1,2]) > (alpha_mu[ ,2,2,3] + alpha_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((alpha_mu[ ,2,2,2] + alpha_mu[ ,2,1,2]) > (alpha_mu[ ,2,2,3] + alpha_mu[ ,2,1,3])) / 3400
quantile((alpha_mu[ ,2,2,2] + alpha_mu[ ,2,1,2]) > (alpha_mu[ ,2,2,3] + alpha_mu[ ,2,1,3]), probs=c(.025,.975))
# Main effect of group
# high vs low
sum((alpha_mu[ ,2,2,1] + alpha_mu[ ,2,2,2] + alpha_mu[ ,2,2,3]) > 
      (alpha_mu[ ,2,1,1] + alpha_mu[ ,2,1,2] + alpha_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((alpha_mu[ ,2,2,1] + alpha_mu[ ,2,2,2] + alpha_mu[ ,2,2,3]) > 
      (alpha_mu[ ,2,1,1] + alpha_mu[ ,2,1,2] + alpha_mu[ ,2,1,3])) / 3400
quantile((alpha_mu[ ,2,2,1] + alpha_mu[ ,2,2,2] + alpha_mu[ ,2,2,3]) > 
           (alpha_mu[ ,2,1,1] + alpha_mu[ ,2,1,2] + alpha_mu[ ,2,1,3]), probs=c(.025,.975))



beta_mu <- rstan::extract(model_fit_RW, pars = 'beta_mu', permuted = TRUE)$beta_mu
# Experiment 1: compare learning phase between groups
sum(beta_mu[ ,1,2,1] > beta_mu[ ,1,1,1], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1]) / 3400
quantile(beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1],probs=c(.025,.975))
# Experiment 1: compare transfer phase between groups
sum(beta_mu[ ,2,2,1] > beta_mu[ ,2,1,1], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1]) / 3400
quantile(beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1],probs=c(.025,.975))
# Experiment 2: compare learning phase between groups
sum(beta_mu[ ,1,2,2] > beta_mu[ ,1,1,2], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2]) / 3400
quantile(beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2],probs=c(.025,.975))
# Experiment 2: compare transfer phase between groups
sum(beta_mu[ ,2,2,2] > beta_mu[ ,2,1,2], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2]) / 3400
quantile(beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2],probs=c(.025,.975))
# Experiment 3: compare learning phase between groups
sum(beta_mu[ ,1,2,3] > beta_mu[ ,1,1,3], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3]) / 3400
quantile(beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3],probs=c(.025,.975))
# Experiment 3: compare transfer phase between groups
sum(beta_mu[ ,2,2,3] > beta_mu[ ,2,1,3], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3]) / 3400
quantile(beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3],probs=c(.025,.975))

# ANOVA-like analysis (only for transfer phase)
# Experiment x group x phase
# Exp 1 vs Exp 2
sum(((beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1]) - (beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1])) > ((beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2]) - (beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2])), na.rm = TRUE) / 3400 * 100 #experiment x group x phase
sum((beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1]) > (beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2]), na.rm = TRUE) / 3400 * 100 #experiment x group (in learning phase)
sum((beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1]) > (beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100 #experiment x group (in transfer phase)
# Exp 1 vs Exp 3
sum(((beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1]) - (beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1])) > ((beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3]) - (beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3])), na.rm = TRUE) / 3400 * 100 #experiment x group x phase
sum((beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1]) > (beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3]), na.rm = TRUE) / 3400 * 100 #experiment x group (in learning phase)
sum((beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1]) > (beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 #experiment x group (in transfer phase)
# Exp 1 vs Exp 2
sum(((beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2]) - (beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2])) > ((beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3]) - (beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3])), na.rm = TRUE) / 3400 * 100 #experiment x group x phase
sum((beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2]) > (beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3]), na.rm = TRUE) / 3400 * 100 #experiment x group (in learning phase)
sum((beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2]) > (beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 #experiment x group (in transfer phase)
# Main effect of experiment
# Exp 1 vs Exp 2
sum((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,1,1,1] + beta_mu[ ,2,1,1]) > (beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,1,1,1] + beta_mu[ ,2,1,1]) - (beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2])) / 3400
quantile((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,1,1,1] + beta_mu[ ,2,1,1]) - (beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2]),probs=c(.025,.975))
# Exp 1 vs Exp 3
sum((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,2,1,1] + beta_mu[ ,1,1,1]) > (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,2,1,1] + beta_mu[ ,1,1,1]) - (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3])) / 3400
quantile((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,2,1,1] + beta_mu[ ,1,1,1]) - (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3]),probs=c(.025,.975))
# Exp 2 vs Exp 3
sum((beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2]) > (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2]) - (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3])) / 3400
quantile((beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2]) - (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3]),probs=c(.025,.975))
# Main effect of group
# high vs low
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
       beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) > 
      (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3] + 
         beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
       beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) - 
      (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3] + 
         beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3])) / 3400
quantile((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
            beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) - 
           (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3] + 
              beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]),probs=c(.025,.975))
# high vs low (learning phase)
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3]) > 
      (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3]) - 
      (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3])) / 3400
quantile((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3]) - 
           (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3]),probs=c(.025,.975))
# high vs low (transfer phase)
sum((beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) > 
      (beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) - 
      (beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3])) / 3400
quantile((beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) - 
           (beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]),probs=c(.025,.975))
# Main effect of phase
# learning vs transfer
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
       beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3]) > 
      (beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3] +
         beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
       beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3]) - 
      (beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3] +
         beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3])) / 3400
quantile((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
            beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3]) - 
           (beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3] +
              beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]),probs=c(.025,.975))



# -------------------------------- model fitting (Two-Rates) -------------------------------------#
model_fit_2R <- stan(
  file = "C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/RL modeling/models/two_rates_hierarchical.stan",  # Stan program
  data = data_for_model,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 150,          # number of warmup iterations per chain
  iter = 1000,            # total number of iterations per chain
  cores = 4             # number of cores (could use one per chain)
)

# visualize diagnostics
print(model_fit_2R, pars=c("eta_P_mu_mu", "eta_P_mu_sigma", "eta_P_mu", "eta_P_mu_raw", "eta_P_sigma", "eta_N_mu_mu", "eta_N_mu_sigma", "eta_N_mu", "eta_N_mu_raw", "eta_N_sigma", "beta_mu", "beta_mu_raw", "beta_sigma", "starting_utility", "alpha_P_mu", "alpha_N_mu"), probs=c(.1,.5,.9))
traceplot(model_fit_2R, pars = c("eta_P_mu_mu", "eta_P_mu_sigma", "eta_P_mu", "eta_P_mu_raw", "eta_P_sigma", "eta_N_mu_mu", "eta_N_mu_sigma", "eta_N_mu", "eta_N_mu_raw", "eta_N_sigma", "beta_mu", "beta_mu_raw", "beta_sigma", "starting_utility", "alpha_P_mu", "alpha_N_mu"), inc_warmup = TRUE)
traceplot(model_fit_2R_simp2, pars = c("eta_P_mu", "eta_N_mu"), inc_warmup = TRUE)

# hyperparameters posterior distributions
stan_hist(model_fit_2R, pars = c("eta_P_mu_mu", "eta_P_mu_sigma", "eta_P_mu", "eta_P_mu_raw", "eta_P_sigma", "eta_N_mu_mu", "eta_N_mu_sigma", "eta_N_mu", "eta_N_mu_raw", "eta_N_sigma", "beta_mu", "beta_mu_raw", "beta_sigma", "starting_utility", "alpha_P_mu", "alpha_N_mu"))

# loo for model comparison
loo_fit_2R <- loo::loo(model_fit_2R)
loo_fit_2R


alpha_P_mu <- rstan::extract(model_fit_2R, pars = 'alpha_P_mu', permuted = TRUE)$alpha_P_mu
alpha_N_mu <- rstan::extract(model_fit_2R, pars = 'alpha_N_mu', permuted = TRUE)$alpha_N_mu
# Experiment 1: compare learning phase between groups
sum((alpha_N_mu[ ,1,2,1] - alpha_N_mu[ ,1,1,1]) > (alpha_P_mu[ ,1,2,1] - alpha_P_mu[ ,1,1,1]), na.rm = TRUE) / 3400 * 100 # interaction of group x feedback
sum((alpha_N_mu[ ,1,2,1] - alpha_N_mu[ ,1,1,1]) - (alpha_P_mu[ ,1,2,1] - alpha_P_mu[ ,1,1,1])) / 3400
quantile((alpha_N_mu[ ,1,2,1] - alpha_N_mu[ ,1,1,1]) - (alpha_P_mu[ ,1,2,1] - alpha_P_mu[ ,1,1,1]), probs=c(.025,.975))
sum((alpha_N_mu[ ,1,2,1] + alpha_N_mu[ ,1,1,1]) > (alpha_P_mu[ ,1,2,1] + alpha_P_mu[ ,1,1,1]), na.rm = TRUE) / 3400 * 100 # main effect of feedback
sum((alpha_N_mu[ ,1,2,1] + alpha_N_mu[ ,1,1,1]) - (alpha_P_mu[ ,1,2,1] + alpha_P_mu[ ,1,1,1])) / 3400
quantile((alpha_N_mu[ ,1,2,1] + alpha_N_mu[ ,1,1,1]) - (alpha_P_mu[ ,1,2,1] + alpha_P_mu[ ,1,1,1]), probs=c(.025,.975))
sum((alpha_N_mu[ ,1,2,1] + alpha_P_mu[ ,1,2,1]) > (alpha_N_mu[ ,1,1,1] + alpha_P_mu[ ,1,1,1]), na.rm = TRUE) / 3400 * 100 # main effect of group
sum((alpha_N_mu[ ,1,2,1] + alpha_P_mu[ ,1,2,1]) - (alpha_N_mu[ ,1,1,1] + alpha_P_mu[ ,1,1,1])) / 3400
quantile((alpha_N_mu[ ,1,2,1] + alpha_P_mu[ ,1,2,1]) - (alpha_N_mu[ ,1,1,1] + alpha_P_mu[ ,1,1,1]), probs=c(.025,.975))
sum(alpha_P_mu[ ,1,2,1] > alpha_P_mu[ ,1,1,1], na.rm = TRUE) / 3400 * 100 # high vs low (positive feedback)
sum(alpha_P_mu[ ,1,2,1] - alpha_P_mu[ ,1,1,1]) / 3400
quantile(alpha_P_mu[ ,1,2,1] - alpha_P_mu[ ,1,1,1], probs=c(.025,.975))
sum(alpha_N_mu[ ,1,2,1] > alpha_N_mu[ ,1,1,1], na.rm = TRUE) / 3400 * 100 # high vs low (negative feedback)
sum(alpha_N_mu[ ,1,2,1] - alpha_N_mu[ ,1,1,1]) / 3400
quantile(alpha_N_mu[ ,1,2,1] - alpha_N_mu[ ,1,1,1], probs=c(.025,.975))
# Experiment 1: compare transfer phase between groups
sum((alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1]) > (alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]), na.rm = TRUE) / 3400 * 100 # interaction of group x feedback
sum((alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1])) / 3400
quantile((alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]), probs=c(.025,.975))
sum((alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,1,1]) > (alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,1,1]), na.rm = TRUE) / 3400 * 100 # main effect of feedback
sum((alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,1,1])) / 3400
quantile((alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,1,1]), probs=c(.025,.975))
sum((alpha_N_mu[ ,2,2,1] + alpha_P_mu[ ,2,2,1]) > (alpha_N_mu[ ,2,1,1] + alpha_P_mu[ ,2,1,1]), na.rm = TRUE) / 3400 * 100 # main effect of group
sum((alpha_N_mu[ ,2,2,1] + alpha_P_mu[ ,2,2,1]) - (alpha_N_mu[ ,2,1,1] + alpha_P_mu[ ,2,1,1])) / 3400
quantile((alpha_N_mu[ ,2,2,1] + alpha_P_mu[ ,2,2,1]) - (alpha_N_mu[ ,2,1,1] + alpha_P_mu[ ,2,1,1]), probs=c(.025,.975))
sum(alpha_P_mu[ ,2,2,1] > alpha_P_mu[ ,2,1,1], na.rm = TRUE) / 3400 * 100 # high vs low (positive feedback)
sum(alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) / 3400
quantile(alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1], probs=c(.025,.975))
sum(alpha_N_mu[ ,2,2,1] > alpha_N_mu[ ,2,1,1], na.rm = TRUE) / 3400 * 100 # high vs low (negative feedback)
sum(alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1]) / 3400
quantile(alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1], probs=c(.025,.975))
# Experiment 2: compare learning phase between groups
sum((alpha_N_mu[ ,1,2,2] - alpha_N_mu[ ,1,1,2]) > (alpha_P_mu[ ,1,2,2] - alpha_P_mu[ ,1,1,2]), na.rm = TRUE) / 3400 * 100 # interaction of group x feedback
sum((alpha_N_mu[ ,1,2,2] - alpha_N_mu[ ,1,1,2]) - (alpha_P_mu[ ,1,2,2] - alpha_P_mu[ ,1,1,2])) / 3400
quantile((alpha_N_mu[ ,1,2,2] - alpha_N_mu[ ,1,1,2]) - (alpha_P_mu[ ,1,2,2] - alpha_P_mu[ ,1,1,2]), probs=c(.025,.975))
sum((alpha_N_mu[ ,1,2,2] + alpha_N_mu[ ,1,1,2]) > (alpha_P_mu[ ,1,2,2] + alpha_P_mu[ ,1,1,2]), na.rm = TRUE) / 3400 * 100 # main effect of feedback
sum((alpha_N_mu[ ,1,2,2] + alpha_N_mu[ ,1,1,2]) - (alpha_P_mu[ ,1,2,2] + alpha_P_mu[ ,1,1,2])) / 3400
quantile((alpha_N_mu[ ,1,2,2] + alpha_N_mu[ ,1,1,2]) - (alpha_P_mu[ ,1,2,2] + alpha_P_mu[ ,1,1,2]), probs=c(.025,.975))
sum((alpha_N_mu[ ,1,2,2] + alpha_P_mu[ ,1,2,2]) > (alpha_N_mu[ ,1,1,2] + alpha_P_mu[ ,1,1,2]), na.rm = TRUE) / 3400 * 100 # main effect of group
sum((alpha_N_mu[ ,1,2,2] + alpha_P_mu[ ,1,2,2]) - (alpha_N_mu[ ,1,1,2] + alpha_P_mu[ ,1,1,2])) / 3400
quantile((alpha_N_mu[ ,1,2,2] + alpha_P_mu[ ,1,2,2]) - (alpha_N_mu[ ,1,1,2] + alpha_P_mu[ ,1,1,2]), probs=c(.025,.975))
sum(alpha_P_mu[ ,1,2,2] > alpha_P_mu[ ,1,1,2], na.rm = TRUE) / 3400 * 100 # high vs low (positive feedback)
sum(alpha_P_mu[ ,1,2,2] - alpha_P_mu[ ,1,1,2]) / 3400
quantile(alpha_P_mu[ ,1,2,2] - alpha_P_mu[ ,1,1,2], probs=c(.025,.975))
sum(alpha_N_mu[ ,1,2,2] > alpha_N_mu[ ,1,1,2], na.rm = TRUE) / 3400 * 100 # high vs low (negative feedback)
sum(alpha_N_mu[ ,1,2,2] - alpha_N_mu[ ,1,1,2]) / 3400
quantile(alpha_N_mu[ ,1,2,2] - alpha_N_mu[ ,1,1,2], probs=c(.025,.975))
# Experiment 2: compare transfer phase between groups
sum((alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2]) > (alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100 # interaction of group x feedback
sum((alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2]) - (alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2])) / 3400
quantile((alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2]) - (alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]), probs=c(.025,.975))
sum((alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,1,2]) > (alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100 # main effect of feedback
sum((alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,1,2]) - (alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,1,2])) / 3400
quantile((alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,1,2]) - (alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,1,2]), probs=c(.025,.975))
sum((alpha_N_mu[ ,2,2,2] + alpha_P_mu[ ,2,2,2]) > (alpha_N_mu[ ,2,1,2] + alpha_P_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100 # main effect of group
sum((alpha_N_mu[ ,2,2,2] + alpha_P_mu[ ,2,2,2]) - (alpha_N_mu[ ,2,1,2] + alpha_P_mu[ ,2,1,2])) / 3400
quantile((alpha_N_mu[ ,2,2,2] + alpha_P_mu[ ,2,2,2]) - (alpha_N_mu[ ,2,1,2] + alpha_P_mu[ ,2,1,2]), probs=c(.025,.975))
sum(alpha_P_mu[ ,2,2,2] > alpha_P_mu[ ,2,1,2], na.rm = TRUE) / 3400 * 100 # high vs low (positive feedback)
sum(alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]) / 3400
quantile(alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2], probs=c(.025,.975))
sum(alpha_N_mu[ ,2,2,2] > alpha_N_mu[ ,2,1,2], na.rm = TRUE) / 3400 * 100 # high vs low (negative feedback)
sum(alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2]) / 3400
quantile(alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2], probs=c(.025,.975))
# Experiment 3: compare learning phase between groups
sum((alpha_N_mu[ ,1,2,3] - alpha_N_mu[ ,1,1,3]) > (alpha_P_mu[ ,1,2,3] - alpha_P_mu[ ,1,1,3]), na.rm = TRUE) / 3400 * 100 # interaction of group x feedback
sum((alpha_N_mu[ ,1,2,3] - alpha_N_mu[ ,1,1,3]) - (alpha_P_mu[ ,1,2,3] - alpha_P_mu[ ,1,1,3])) / 3400
quantile((alpha_N_mu[ ,1,2,3] - alpha_N_mu[ ,1,1,3]) - (alpha_P_mu[ ,1,2,3] - alpha_P_mu[ ,1,1,3]), probs=c(.025,.975))
sum((alpha_N_mu[ ,1,2,3] + alpha_N_mu[ ,1,1,3]) > (alpha_P_mu[ ,1,2,3] + alpha_P_mu[ ,1,1,3]), na.rm = TRUE) / 3400 * 100 # main effect of feedback
sum((alpha_N_mu[ ,1,2,3] + alpha_N_mu[ ,1,1,3]) - (alpha_P_mu[ ,1,2,3] + alpha_P_mu[ ,1,1,3])) / 3400
quantile((alpha_N_mu[ ,1,2,3] + alpha_N_mu[ ,1,1,3]) - (alpha_P_mu[ ,1,2,3] + alpha_P_mu[ ,1,1,3]), probs=c(.025,.975))
sum((alpha_N_mu[ ,1,2,3] + alpha_P_mu[ ,1,2,3]) > (alpha_N_mu[ ,1,1,3] + alpha_P_mu[ ,1,1,3]), na.rm = TRUE) / 3400 * 100 # main effect of group
sum((alpha_N_mu[ ,1,2,3] + alpha_P_mu[ ,1,2,3]) - (alpha_N_mu[ ,1,1,3] + alpha_P_mu[ ,1,1,3])) / 3400
quantile((alpha_N_mu[ ,1,2,3] + alpha_P_mu[ ,1,2,3]) - (alpha_N_mu[ ,1,1,3] + alpha_P_mu[ ,1,1,3]), probs=c(.025,.975))
sum(alpha_P_mu[ ,1,2,3] > alpha_P_mu[ ,1,1,3], na.rm = TRUE) / 3400 * 100 # high vs low (positive feedback)
sum(alpha_P_mu[ ,1,2,3] - alpha_P_mu[ ,1,1,3]) / 3400
quantile(alpha_P_mu[ ,1,2,3] - alpha_P_mu[ ,1,1,3], probs=c(.025,.975))
sum(alpha_N_mu[ ,1,2,3] > alpha_N_mu[ ,1,1,3], na.rm = TRUE) / 3400 * 100 # high vs low (negative feedback)
sum(alpha_N_mu[ ,1,2,3] - alpha_N_mu[ ,1,1,3]) / 3400
quantile(alpha_N_mu[ ,1,2,3] - alpha_N_mu[ ,1,1,3], probs=c(.025,.975))
# Experiment 3: compare transfer phase between groups
sum((alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3]) > (alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 # interaction of group x feedback
sum((alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3]) - (alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3])) / 3400
quantile((alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3]) - (alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]), probs=c(.025,.975))
sum((alpha_N_mu[ ,2,2,3] + alpha_N_mu[ ,2,1,3]) > (alpha_P_mu[ ,2,2,3] + alpha_P_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 # main effect of feedback
sum((alpha_N_mu[ ,2,2,3] + alpha_N_mu[ ,2,1,3]) - (alpha_P_mu[ ,2,2,3] + alpha_P_mu[ ,2,1,3])) / 3400
quantile((alpha_N_mu[ ,2,2,3] + alpha_N_mu[ ,2,1,3]) - (alpha_P_mu[ ,2,2,3] + alpha_P_mu[ ,2,1,3]), probs=c(.025,.975))
sum((alpha_N_mu[ ,2,2,3] + alpha_P_mu[ ,2,2,3]) > (alpha_N_mu[ ,2,1,3] + alpha_P_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 # main effect of group
sum((alpha_N_mu[ ,2,2,3] + alpha_P_mu[ ,2,2,3]) - (alpha_N_mu[ ,2,1,3] + alpha_P_mu[ ,2,1,3])) / 3400
quantile((alpha_N_mu[ ,2,2,3] + alpha_P_mu[ ,2,2,3]) - (alpha_N_mu[ ,2,1,3] + alpha_P_mu[ ,2,1,3]), probs=c(.025,.975))
sum(alpha_P_mu[ ,2,2,3] > alpha_P_mu[ ,2,1,3], na.rm = TRUE) / 3400 * 100 # high vs low (positive feedback)
sum(alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]) / 3400
quantile(alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3], probs=c(.025,.975))
sum(alpha_N_mu[ ,2,2,3] > alpha_N_mu[ ,2,1,3], na.rm = TRUE) / 3400 * 100 # high vs low (negative feedback)
sum(alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3]) / 3400
quantile(alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3], probs=c(.025,.975))

# ANOVA-like analysis (only for transfer phase)
# Experiment x group x feedback
# Exp 1 vs Exp 2
sum((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) > (alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100 # interaction of group x experiment (positive feedback)
sum((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2])) / 3400
quantile((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]), probs=c(.025,.975))
sum((alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1]) > (alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100 # interaction of group x experiment (negative feedback)
sum((alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1]) - (alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2])) / 3400
quantile((alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1]) - (alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2]), probs=c(.025,.975))
sum(((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) - (alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1])) > ((alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]) - (alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2])), na.rm = TRUE) / 3400 * 100 # interaction of group x experiment x feedback
sum(((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) - (alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1])) - ((alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]) - (alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2]))) / 3400
quantile(((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) - (alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1])) - ((alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]) - (alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2])), probs=c(.025,.975))
# Exp 1 vs Exp 3
sum((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) > (alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 # interaction of group x experiment (positive feedback)
sum((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3])) / 3400
quantile((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]), probs=c(.025,.975))
sum((alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1]) > (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 # interaction of group x experiment (negative feedback)
sum((alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1]) - (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3])) / 3400
quantile((alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1]) - (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3]), probs=c(.025,.975))
sum(((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) - (alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1])) > ((alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]) - (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3])), na.rm = TRUE) / 3400 * 100 # interaction of group x experiment x feedback
sum(((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) - (alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1])) - ((alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]) - (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3]))) / 3400
quantile(((alpha_P_mu[ ,2,2,1] - alpha_P_mu[ ,2,1,1]) - (alpha_N_mu[ ,2,2,1] - alpha_N_mu[ ,2,1,1])) - ((alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]) - (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3])), probs=c(.025,.975))
# Exp 2 vs Exp 3
sum((alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]) > (alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 # interaction of group x experiment (positive feedback)
sum((alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]) - (alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3])) / 3400
quantile((alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]) - (alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]), probs=c(.025,.975))
sum((alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2]) > (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 # interaction of group x experiment (negative feedback)
sum((alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2]) - (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3])) / 3400
quantile((alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2]) - (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3]), probs=c(.025,.975))
sum(((alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]) - (alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2])) > ((alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]) - (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3])), na.rm = TRUE) / 3400 * 100 # interaction of group x experiment x feedback
sum(((alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]) - (alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2])) - ((alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]) - (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3]))) / 3400
quantile(((alpha_P_mu[ ,2,2,2] - alpha_P_mu[ ,2,1,2]) - (alpha_N_mu[ ,2,2,2] - alpha_N_mu[ ,2,1,2])) - ((alpha_P_mu[ ,2,2,3] - alpha_P_mu[ ,2,1,3]) - (alpha_N_mu[ ,2,2,3] - alpha_N_mu[ ,2,1,3])), probs=c(.025,.975))
# Main effect of experiment
# Exp 1 vs Exp 2
sum((alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,1,1] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,1,1]) > (alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,1,2] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100
sum((alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,1,1] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,1,2] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,1,2])) / 3400
quantile((alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,1,1] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,1,2] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,1,2]), probs=c(.025,.975))
# Exp 1 vs Exp 3
sum((alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,1,1] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,1,1]) > (alpha_P_mu[ ,2,2,3] + alpha_P_mu[ ,2,1,3] + alpha_N_mu[ ,2,2,3] + alpha_N_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,1,1] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,3] + alpha_P_mu[ ,2,1,3] + alpha_N_mu[ ,2,2,3] + alpha_N_mu[ ,2,1,3])) / 3400
quantile((alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,1,1] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,1,1]) - (alpha_P_mu[ ,2,2,3] + alpha_P_mu[ ,2,1,3] + alpha_N_mu[ ,2,2,3] + alpha_N_mu[ ,2,1,3]), probs=c(.025,.975))
# Exp 2 vs Exp 3
sum((alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,1,2] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,1,2]) > (alpha_P_mu[ ,2,2,3] + alpha_P_mu[ ,2,1,3] + alpha_N_mu[ ,2,2,3] + alpha_N_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,1,2] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,1,2]) - (alpha_P_mu[ ,2,2,3] + alpha_P_mu[ ,2,1,3] + alpha_N_mu[ ,2,2,3] + alpha_N_mu[ ,2,1,3])) / 3400
quantile((alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,1,2] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,1,2]) - (alpha_P_mu[ ,2,2,3] + alpha_P_mu[ ,2,1,3] + alpha_N_mu[ ,2,2,3] + alpha_N_mu[ ,2,1,3]), probs=c(.025,.975))
# Main effect of group
# high vs low
sum((alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,2,3] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,2,3] > 
       alpha_P_mu[ ,2,1,1] + alpha_P_mu[ ,2,1,2] + alpha_P_mu[ ,2,1,3] + alpha_N_mu[ ,2,1,1] + alpha_N_mu[ ,2,1,2] + alpha_N_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,2,3] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,2,3] - 
       alpha_P_mu[ ,2,1,1] + alpha_P_mu[ ,2,1,2] + alpha_P_mu[ ,2,1,3] + alpha_N_mu[ ,2,1,1] + alpha_N_mu[ ,2,1,2] + alpha_N_mu[ ,2,1,3])) / 3400
quantile((alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,2,3] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,2,3] - 
            alpha_P_mu[ ,2,1,1] + alpha_P_mu[ ,2,1,2] + alpha_P_mu[ ,2,1,3] + alpha_N_mu[ ,2,1,1] + alpha_N_mu[ ,2,1,2] + alpha_N_mu[ ,2,1,3]), probs=c(.025,.975))
# Main effect of reward
# positive vs negative
sum((alpha_P_mu[ ,2,1,1] + alpha_P_mu[ ,2,1,2] + alpha_P_mu[ ,2,1,3] + alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,2,3] > 
       alpha_N_mu[ ,2,1,1] + alpha_N_mu[ ,2,1,2] + alpha_N_mu[ ,2,1,3] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,2,3]), na.rm = TRUE) / 3400 * 100
sum((alpha_P_mu[ ,2,1,1] + alpha_P_mu[ ,2,1,2] + alpha_P_mu[ ,2,1,3] + alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,2,3] - 
       alpha_N_mu[ ,2,1,1] + alpha_N_mu[ ,2,1,2] + alpha_N_mu[ ,2,1,3] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,2,3])) / 3400
quantile((alpha_P_mu[ ,2,1,1] + alpha_P_mu[ ,2,1,2] + alpha_P_mu[ ,2,1,3] + alpha_P_mu[ ,2,2,1] + alpha_P_mu[ ,2,2,2] + alpha_P_mu[ ,2,2,3] - 
            alpha_N_mu[ ,2,1,1] + alpha_N_mu[ ,2,1,2] + alpha_N_mu[ ,2,1,3] + alpha_N_mu[ ,2,2,1] + alpha_N_mu[ ,2,2,2] + alpha_N_mu[ ,2,2,3]), probs=c(.025,.975))



beta_mu <- rstan::extract(model_fit_RW, pars = 'beta_mu', permuted = TRUE)$beta_mu
# Experiment 1: compare learning phase between groups
sum(beta_mu[ ,1,2,1] > beta_mu[ ,1,1,1], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1]) / 3400
quantile(beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1],probs=c(.025,.975))
# Experiment 1: compare transfer phase between groups
sum(beta_mu[ ,2,2,1] > beta_mu[ ,2,1,1], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1]) / 3400
quantile(beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1],probs=c(.025,.975))
# Experiment 2: compare learning phase between groups
sum(beta_mu[ ,1,2,2] > beta_mu[ ,1,1,2], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2]) / 3400
quantile(beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2],probs=c(.025,.975))
# Experiment 2: compare transfer phase between groups
sum(beta_mu[ ,2,2,2] > beta_mu[ ,2,1,2], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2]) / 3400
quantile(beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2],probs=c(.025,.975))
# Experiment 3: compare learning phase between groups
sum(beta_mu[ ,1,2,3] > beta_mu[ ,1,1,3], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3]) / 3400
quantile(beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3],probs=c(.025,.975))
# Experiment 3: compare transfer phase between groups
sum(beta_mu[ ,2,2,3] > beta_mu[ ,2,1,3], na.rm = TRUE) / 3400 * 100
sum(beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3]) / 3400
quantile(beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3],probs=c(.025,.975))

# ANOVA-like analysis (only for transfer phase)
# Experiment x group x phase
# Exp 1 vs Exp 2
sum(((beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1]) - (beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1])) > ((beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2]) - (beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2])), na.rm = TRUE) / 3400 * 100 #experiment x group x phase
sum((beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1]) > (beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2]), na.rm = TRUE) / 3400 * 100 #experiment x group (in learning phase)
sum((beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1]) > (beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100 #experiment x group (in transfer phase)
# Exp 1 vs Exp 3
sum(((beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1]) - (beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1])) > ((beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3]) - (beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3])), na.rm = TRUE) / 3400 * 100 #experiment x group x phase
sum((beta_mu[ ,1,2,1] - beta_mu[ ,1,1,1]) > (beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3]), na.rm = TRUE) / 3400 * 100 #experiment x group (in learning phase)
sum((beta_mu[ ,2,2,1] - beta_mu[ ,2,1,1]) > (beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 #experiment x group (in transfer phase)
# Exp 1 vs Exp 2
sum(((beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2]) - (beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2])) > ((beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3]) - (beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3])), na.rm = TRUE) / 3400 * 100 #experiment x group x phase
sum((beta_mu[ ,1,2,2] - beta_mu[ ,1,1,2]) > (beta_mu[ ,1,2,3] - beta_mu[ ,1,1,3]), na.rm = TRUE) / 3400 * 100 #experiment x group (in learning phase)
sum((beta_mu[ ,2,2,2] - beta_mu[ ,2,1,2]) > (beta_mu[ ,2,2,3] - beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100 #experiment x group (in transfer phase)
# Main effect of experiment
# Exp 1 vs Exp 2
sum((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,1,1,1] + beta_mu[ ,2,1,1]) > (beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,1,1,1] + beta_mu[ ,2,1,1]) - (beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2])) / 3400
quantile((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,1,1,1] + beta_mu[ ,2,1,1]) - (beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2]),probs=c(.025,.975))
# Exp 1 vs Exp 3
sum((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,2,1,1] + beta_mu[ ,1,1,1]) > (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,2,1,1] + beta_mu[ ,1,1,1]) - (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3])) / 3400
quantile((beta_mu[ ,1,2,1] + beta_mu[ ,2,2,1] + beta_mu[ ,2,1,1] + beta_mu[ ,1,1,1]) - (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3]),probs=c(.025,.975))
# Exp 2 vs Exp 3
sum((beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2]) > (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2]) - (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3])) / 3400
quantile((beta_mu[ ,1,2,2] + beta_mu[ ,2,2,2] + beta_mu[ ,1,1,2] + beta_mu[ ,2,1,2]) - (beta_mu[ ,1,2,3] + beta_mu[ ,2,2,3] + beta_mu[ ,1,1,3] + beta_mu[ ,2,1,3]),probs=c(.025,.975))
# Main effect of group
# high vs low
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
       beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) > 
      (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3] + 
         beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
       beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) - 
      (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3] + 
         beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3])) / 3400
quantile((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
            beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) - 
           (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3] + 
              beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]),probs=c(.025,.975))
# high vs low (learning phase)
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3]) > 
      (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3]) - 
      (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3])) / 3400
quantile((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3]) - 
           (beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3]),probs=c(.025,.975))
# high vs low (transfer phase)
sum((beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) > 
      (beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) - 
      (beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3])) / 3400
quantile((beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3]) - 
           (beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]),probs=c(.025,.975))
# Main effect of phase
# learning vs transfer
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
       beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3]) > 
      (beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3] +
         beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]), na.rm = TRUE) / 3400 * 100
sum((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
       beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3]) - 
      (beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3] +
         beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3])) / 3400
quantile((beta_mu[ ,1,2,1] + beta_mu[ ,1,2,2] + beta_mu[ ,1,2,3] + 
            beta_mu[ ,1,1,1] + beta_mu[ ,1,1,2] + beta_mu[ ,1,1,3]) - 
           (beta_mu[ ,2,2,1] + beta_mu[ ,2,2,2] + beta_mu[ ,2,2,3] +
              beta_mu[ ,2,1,1] + beta_mu[ ,2,1,2] + beta_mu[ ,2,1,3]),probs=c(.025,.975))





##### Compare Models #####
loo::loo_compare(loo_fit_RW, loo_fit_2R)
