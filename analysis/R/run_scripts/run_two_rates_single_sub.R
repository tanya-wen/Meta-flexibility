library("rstan") # observe startup messages
library("tidyverse")
setwd("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility")

# choose which Experiment to analyze
exp_num = 2;

#read the list of behavioral files
subFiles = list.files(path=sprintf("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility/experiment%i/",exp_num), pattern="*.log")

# create lists to store data
subject_total_acc = list();
volatility = list();
sub_alphaR_learning = list();
sub_alphaU_learning = list();
sub_beta_learning = list();
sub_alphaR_transfer = list();
sub_alphaU_transfer = list();
sub_beta_transfer = list();

# loop through subjects
for (subj in 1:length(subFiles)) {
  # read subject data
  sub_dat = read.csv(file.path(sprintf("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility/experiment%i/",exp_num),subFiles[subj]));
  # calculate subject accuracy
  subject_total_acc[subj] = mean(as.integer(as.logical(sub_dat$response_acc[41:280])),na.rm=TRUE)
  # analyze good subjects only
  if (subject_total_acc[subj] >= 0.65) {
    #calculate picked_rule and result (tidy verse; pipe)
    sub_dat <- sub_dat %>%
      filter(!is.na(type)) %>%
      filter(practice == "false") %>%
      mutate(picked_rule = ifelse(as.character(type) == type[1], ifelse(as.character(answer) == as.character(response), 1, 2), 
                                  ifelse(as.character(answer) == as.character(response), 2, 1))) %>% 
      mutate(result = ifelse(reward_validity == 1, ifelse(as.character(answer) == as.character(response), 1, 0), 
                             ifelse(as.character(answer) == as.character(response), 0, 1)))
    # get subject volatility group
    volatility[subj] = sub_dat$volatility[1];
    ## learning phase ##
    # inputs for the model
    model_data_learning = list(nSortingRules = 2,
                        nTrials = 120,
                        ruleChoice = sub_dat$picked_rule[1:120],
                        result = sub_dat$result[1:120])
    my_model_learning = stan_model(file = "RL_variant.stan")
    fit_learning = optimizing(object = my_model_learning, data = model_data_learning)
    #get alpha and beta estimates
    sub_alphaR_learning[subj] = fit_learning$par[1];
    sub_alphaU_learning[subj] = fit_learning$par[2];
    sub_beta_learning[subj] = fit_learning$par[3];
    ## transfer phase ##
    # inputs for the model
    model_data_transfer = list(nSortingRules = 2,
                       nTrials = 119,
                       ruleChoice = sub_dat$picked_rule[122:240],
                       result = sub_dat$result[122:240])
    my_model_transfer = stan_model(file = "RL_variant.stan")
    fit_transfer = optimizing(object = my_model_transfer, data = model_data_transfer)
    #get alpha and beta estimates
    sub_alphaR_transfer[subj] = fit_transfer$par[1];
    sub_alphaU_transfer[subj] = fit_transfer$par[2];
    sub_beta_transfer[subj] = fit_transfer$par[3];
  }
}
# number of good subjects
n_good_sub = sum(subject_total_acc >= 0.65);

# get indices of subjects in low/high volatility group
low_volaility_ind = which("low"==volatility);
high_volaility_ind = which("high"==volatility);

# group t-test
## learning phase ##
t.test(as.numeric(sub_alphaR_learning[low_volaility_ind]), as.numeric(sub_alphaR_learning[high_volaility_ind]))
t.test(as.numeric(sub_alphaU_learning[low_volaility_ind]), as.numeric(sub_alphaU_learning[high_volaility_ind]))
t.test(as.numeric(sub_beta_learning[low_volaility_ind]), as.numeric(sub_beta_learning[high_volaility_ind]))
## transfer phase ##
t.test(as.numeric(sub_alphaR_transfer[low_volaility_ind]), as.numeric(sub_alphaR_transfer[high_volaility_ind]))
t.test(as.numeric(sub_alphaU_transfer[low_volaility_ind]), as.numeric(sub_alphaU_transfer[high_volaility_ind]))
t.test(as.numeric(sub_beta_transfer[low_volaility_ind]), as.numeric(sub_beta_transfer[high_volaility_ind]))

#anova
anova_dat_R <- data.frame(PID = rep(seq(from = 1, to = n_good_sub, by = 1), 2),
                       dat = as.numeric(c(sub_alphaR_learning[low_volaility_ind],sub_alphaR_learning[high_volaility_ind],sub_alphaR_transfer[low_volaility_ind],sub_alphaR_transfer[high_volaility_ind])),
                       phase = c(rep("learning",1,n_good_sub),rep("transfer",1,n_good_sub)),
                       group = c(rep("low",1,length(low_volaility_ind)),rep("high",1,length(high_volaility_ind)),rep("low",1,length(low_volaility_ind)),rep("high",1,length(high_volaility_ind))));
anova_dat_R <- within(anova_dat_R, {
  phase <- factor(phase)
  group <- factor(group)
})
anova_model_R <- aov(dat ~ phase * group + Error(PID / (phase * group)), data=anova_dat_R)
summary(anova_model_R)
boxplot(dat~phase * group, data=anova_dat_R, 
        col=(c("gold","darkgreen")),
        main="Alpha-rewarded")

anova_dat_U <- data.frame(PID = rep(seq(from = 1, to = n_good_sub, by = 1), 2),
                        dat = as.numeric(c(sub_alphaU_learning[low_volaility_ind],sub_alphaU_learning[high_volaility_ind],sub_alphaU_transfer[low_volaility_ind],sub_alphaU_transfer[high_volaility_ind])),
                        phase = c(rep("learning",1,n_good_sub),rep("transfer",1,n_good_sub)),
                        group = c(rep("low",1,length(low_volaility_ind)),rep("high",1,length(high_volaility_ind)),rep("low",1,length(low_volaility_ind)),rep("high",1,length(high_volaility_ind))));
anova_dat_U <- within(anova_dat_U, {
  phase <- factor(phase)
  group <- factor(group)
})
anova_model_U <- aov(dat ~ phase * group + Error(PID / (phase * group)), data=anova_dat_U)
summary(anova_model_U)
boxplot(dat~phase * group, data=anova_dat_U, 
        col=(c("gold","darkgreen")),
        main="Alpha-rewarded")
