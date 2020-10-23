library(ggplot2)
library(reshape2)
data_out <- "/Users/rmgeddert/Box/meta-flexibility/simulated_data" #the folder where you want the data to be outputted

main_df <- data.frame()

for (sub in 1:100) {
  
  #parameter specifications
  nTrials <- 120
  nArms <- 2 
  banditArms <- c(1:nArms)
  armProbabilities1 <- c(0.8, 0.2) 
  armProbabilities2 <- c(0.2, 0.8)
  alpha <- ifelse(sub > 50, .01, .99) #learning rate
  beta <- 3 #inverse temperature
  Qi <- 0.5 #initial Q values
  currentQs <- vector(length = length(banditArms)) #current Q values for given trial
  trialQs <- matrix(data = NA, nrow = nTrials, ncol = nArms) #Qs values for all trials
  choiceProbs <- vector(length = length(banditArms)) #current choice probabilities for given trial
  trialChoiceProbs <- matrix(data = NA, nrow = nTrials, ncol = nArms) #choice probabilities for all trials
  choices <- vector(length = nTrials) #stores choices made at each trial
  rewards <- vector(length = nTrials) #stores rewards received at each trial
  
  #create array of rewards for each rule
  trialRewardValidities <- sample(c(rep(0, .2 * nTrials), rep(1, .8 * nTrials)))
  
  #loop through trial reward validities and built reward arrays
  rule1_reward = c()
  rule2_reward = c()
  for (i in 1:length(trialRewardValidities)) {
    if ((i %% 40) > 0 && (i %% 40) <= 20) {
      if (trialRewardValidities[i] == 1){
        rule1_reward <- append(rule1_reward, 1)
        rule2_reward <- append(rule2_reward, 0)
      } else {
        rule1_reward <- append(rule1_reward, 0)
        rule2_reward <- append(rule2_reward, 1)
      }
    } else {
      if (trialRewardValidities[i] == 1){
        rule1_reward <- append(rule1_reward, 0)
        rule2_reward <- append(rule2_reward, 1)
      } else {
        rule1_reward <- append(rule1_reward, 1)
        rule2_reward <- append(rule2_reward, 0)
      }
    }
  }
  
  #assign initial Q values
  for (arm in banditArms) {
    currentQs[arm] <- Qi
  }
  
  #simulation
  for (trial in 1:nTrials) {
    
    #calculate sumExp for softmax function
    sumExp <- 0
    for (arm in banditArms) {
      sumExp <- sumExp + exp(beta * currentQs[arm])
    }
    
    #calculate choice probabilities
    for (arm in banditArms) {
      choiceProbs[arm] = exp(beta * currentQs[arm]) / sumExp
    }
    
    #save choice probabilities in matrix for later visualization
    trialChoiceProbs[trial,] <- choiceProbs
    
    # choose action given choice probabilities, save in choices vector
    choices[trial] <- sample(banditArms, size = 1, replace = FALSE, prob = choiceProbs)
    
    # Predetermined trial validities
    if (choices[trial] == 1){
      rewards[trial] <- rule1_reward[trial]
    } else {
      rewards[trial] <- rule2_reward[trial]
    }
    
    #given reward outcome, update Q values
    currentQs[choices[trial]] <- currentQs[choices[trial]] + alpha * (rewards[trial] - currentQs[choices[trial]])
    
    #save Q values in matrix of all Q-values for later visualization
    trialQs[trial,] <- currentQs
  }
  
  ##### Save Data ####
  #combine choices and rewards into dataframe
  sub_df <- data.frame(choices, rewards)
  sub_df <- sub_df %>% 
    mutate(subject = sub) %>% 
    mutate(group = ifelse(sub > 50, 2, 1)) %>% 
    mutate(madeChoice = 1)
  sub_df$trialCount <- as.numeric(row.names(sub_df))
  
  main_df = rbind(main_df, sub_df)
  
}

#save out data df as csv
fileName <- paste(data_out, paste("RW_hierarchical_simulated_data.csv"),sep = "/")
write.csv(main_df,fileName, row.names = FALSE)
