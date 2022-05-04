library(ggplot2)
library(reshape2)
library("rstan") # observe startup messages
library("tidyverse")
setwd("C:/Users/Tanya Wen/Box/Extra_Space_for_Tanya/meta-flexibility/short")

data_out <- "C:/Users/Tanya Wen/Box/Extra_Space_for_Tanya/meta-flexibility/short/simulated_data" #the folder where you want the data to be outputted


# volatility = 20

  

  alpha_mu_sim <- c()
  low_alpha_sim <- c()
  high_alpha_sim <- c()
  beta_mu_sim <- c()
  alpha_mu_fit <-c()
  low_alpha_fit <- c()
  high_alpha_fit <- c()
  beta_mu_fit <- c()
  
  d = c(0, 0.2, 0.4, 0.6, 0.8) # range of group differences
  group1_alphas = c(0.5, 0.4, 0.3, 0.2, 0.1) # low-volatility group
  group2_alphas = c(0.5, 0.6, 0.7, 0.8, 0.9) # high-volatility group

  
  for (iter in 1:5) {
    print(paste('iter:',iter))
    
    main_df <- data.frame()
    alpha <- c()
    beta <- c()

  
  # each group has 40 subjects
  for (sub in 1:80) {
    
    # ------------------------ #
    # parameter specifications #
    # ------------------------ #
    
    nTrials <- 120 
    nChoices <- 2 
    banditArms <- c(1:nChoices)
    armProbabilities1 <- c(0.8, 0.2) 
    armProbabilities2 <- c(0.2, 0.8)
    
    if (sub <= 40) {
      alpha <- c(alpha, rnorm(1, mean = group1_alphas[iter], sd = 0.03)); #learning rate: sample from normal distribution
    } else if (sub > 40) {
      alpha <- c(alpha, rnorm(1, mean = group2_alphas[iter], sd = 0.03)); #learning rate: sample from normal distribution
    }
    beta <- c(beta, rnorm(1, mean = 4.17, sd = 0.21)); #inverse temperature: sample from normal distribution
    
    starting_utility <- rnorm(1,mean=0.5,sd=0.5) #initial Q values (sample from beta distribution)
    currentQs <- vector(length = length(banditArms)) #current Q values for given trial
    trialQs <- matrix(data = NA, nrow = nTrials, ncol = nChoices) #Qs values for all trials
    choiceProbs <- vector(length = length(banditArms)) #current choice probabilities for given trial
    trialChoiceProbs <- matrix(data = NA, nrow = nTrials, ncol = nChoices) #choice probabilities for all trials
    choices <- vector(length = nTrials) #stores choices made at each trial
    rewards <- vector(length = nTrials) #stores rewards received at each trial
    
    
    # ------------------------------------- #
    # create array of rewards for each rule #
    # ------------------------------------- #
    
    # generate feedback validity
    trialRewardValidities <- sample(c(rep(0, .2 * nTrials), rep(1, .8 * nTrials)))
    
    #loop through trial reward validities and built reward arrays
    rule1_reward = c()
    rule2_reward = c()
    rule = c()
    
    
    # volatility = 20
    for (i in 1:nTrials) { 
      if ((i %% 40) > 0 && (i %% 40) <= 20) { 
        if (trialRewardValidities[i] == 1){ # valid feedback
          rule1_reward <- append(rule1_reward, 1)
          rule2_reward <- append(rule2_reward, 0)
          rule <- append(rule,1)
        } else {
          rule1_reward <- append(rule1_reward, 0)
          rule2_reward <- append(rule2_reward, 1)
          rule <- append(rule,2)
        }
      } else {
        if (trialRewardValidities[i] == 1){ # invalid feedback
          rule1_reward <- append(rule1_reward, 0)
          rule2_reward <- append(rule2_reward, 1)
          rule <- append(rule,2)
        } else {
          rule1_reward <- append(rule1_reward, 1)
          rule2_reward <- append(rule2_reward, 0)
          rule <- append(rule,1)
        }
      }
    }

    
    
    # ------------------------ #
    #       simulation         #
    # ------------------------ #
    
    #assign initial Q values
    for (arm in banditArms) {
      currentQs[arm] <- starting_utility
    }
    
    #simulation
    for (trial in 1:nTrials) {
      
      #calculate sumExp for softmax function
      sumExp <- 0
      for (arm in banditArms) {
        sumExp <- sumExp + exp(beta[sub] * currentQs[arm])
      }
      
      #calculate choice probabilities
      for (arm in banditArms) {
        choiceProbs[arm] = exp(beta[sub] * currentQs[arm]) / sumExp
      }
      
      #save choice probabilities in matrix for later visualization
      trialChoiceProbs[trial,] <- choiceProbs
      
      # choose action given choice probabilities, save in choices vector
      choices[trial] <- sample(banditArms, size = 1, replace = FALSE, prob = choiceProbs)
      
      # Predetermined trial vadilities
      if (choices[trial] == 1){
        rewards[trial] <- rule1_reward[trial]
      } else {
        rewards[trial] <- rule2_reward[trial]
      }
      
      #given reward outcome, update Q values
      currentQs[choices[trial]] <- currentQs[choices[trial]] + alpha[sub] * (rewards[trial] - currentQs[choices[trial]])
      
      #save Q values in matrix of all Q-values for later visualization
      trialQs[trial,] <- currentQs
    }
    
    #combine choices, rule rewards into dataframe
    sub_df <- data.frame(choices, rule, rewards)
    sub_df <- sub_df %>% 
      mutate(subject = sub) %>% 
      mutate(group = ifelse(sub<=40,1,2)) %>% 
      mutate(madeChoice = 1) 
    sub_df$trialCount <- as.numeric(row.names(sub_df))
    
    main_df = rbind(main_df, sub_df)
  } # end of subject loop
  
  # get simulated alpha_mu
  alpha_mu_sim <- c(alpha_mu_sim, mean(alpha[41:80])-mean(alpha[1:40]))
  low_alpha_sim <- c(low_alpha_sim, mean(alpha[1:40]))
  high_alpha_sim <- c(high_alpha_sim, mean(alpha[41:80]))
  beta_mu_sim <- c(beta_mu_sim, mean(beta[41:80])-mean(beta[1:40]))
  
  #save out data df as csv
  # fileName <- paste(data_out, paste(sprintf("RW_simulated_%s.csv", volatility)),sep = "/")
  # write.csv(main_df,fileName, row.names = FALSE)
  
  
  # ------------------------ #
  #    Fit Simulated Data    #
  # ------------------------ #
  
  # allSubjects = read.csv("/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility/simulated_data/RW_hierarchical_simulated_data.csv")
  allSubjects = main_df;
  allSubjects_group <- allSubjects %>% 
    select(subject, group) %>% 
    group_by(subject) %>% 
    summarise(group = mean(group))
  
  # create list object for passing data to stan models
  data_for_model <- list(nSubjects = length(unique(allSubjects$subject)),
                         nTrials = nrow(allSubjects), 
                         nChoices = 2,
                         nGroups = 2,
                         madeChoiceTrials = sum(allSubjects$madeChoice), # excluding trials where no choice is made
                         subject = allSubjects$subject, # continuous subject index, different from subject number
                         trialNum = allSubjects$trialCount,
                         choices = allSubjects$choices, 
                         rewards = allSubjects$rewards,
                         group = allSubjects_group$group
  )
  
  model_fit_RW <- stan(
    file = "models/resc_wagner_ParameterRecovery.stan",  # Stan program
    data = data_for_model,    # named list of data
    chains = 4,             # number of Markov chains
    warmup = 150,          # number of warmup iterations per chain
    iter = 400,            # total number of iterations per chain
    cores = 4             # number of cores (could use one per chain)
  )
  
  alpha_mu = rstan::extract(model_fit_RW, pars = 'alpha_mu', permuted = TRUE)$alpha_mu;
  beta_mu = rstan::extract(model_fit_RW, pars = 'beta_mu', permuted = TRUE)$beta_mu;
  
  alpha_mu_fit <- c(alpha_mu_fit, mean(alpha_mu[,2])-mean(alpha_mu[,1]))
  low_alpha_fit <- c(low_alpha_fit, mean(alpha_mu[,1]))
  high_alpha_fit <- c(high_alpha_fit, mean(alpha_mu[,2]))
  beta_mu_fit <- c(beta_mu_fit, mean(beta_mu[,2])-mean(beta_mu[,1]))
  
  } # end of iteration loop
  
  # --------------------------------- #
  # Compare simulated vs. fitted data #
  # --------------------------------- #
  agreement_alphas <- cor(alpha_mu_sim, alpha_mu_fit)
  print(agreement_alphas)
  plot(alpha_mu_sim, alpha_mu_fit, main="Correlation between simulated and fitted alpha differences", xlab="simulated", ylab="fitted")
  
  agreement_betas <- cor(beta_mu_sim, beta_mu_fit)
  plot(beta_mu_sim, beta_mu_fit, main="Correlation between simulated and fitted beta differences", xlab="simulated", ylab="fitted")
  print(agreement_betas)
  
  fitted_alpha_beta_corr <- cor(alpha_mu_fit, beta_mu_fit)
  plot(alpha_mu_fit, beta_mu_fit, main="Correlation between fitted alpha and beta differences", xlab="alpha", ylab="beta")
  print(fitted_alpha_beta_corr)
  
  save(alpha_mu_sim, alpha_mu_fit, beta_mu_sim, beta_mu_fit, file ="parameter_recovery.RData")
  


