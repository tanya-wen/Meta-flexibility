library(ggplot2)
library(reshape2)
data_out <- "/Users/tanyawen/Box/Home Folder tw260/Private/model fitting" #the folder where you want the data to be outputted

#parameter specifications
nTrials <- 120
nArms <- 2 
banditArms <- c(1:nArms)
armProbabilities1 <- c(0.8, 0.2) 
armProbabilities2 <- c(0.2, 0.8)
alpha <- .478 #learning rate
beta <- 4.993 #inverse temperature
phi <- 0.5 #autocorrelation parameter
theta <- 0.1 #choice history decay
Qi <- 0.5 #initial Q values
currentC <- vector(length = length(banditArms)) # choice history for each arm
currentQs <- vector(length = length(banditArms)) #current Q values for given trial
Ci <- 0 #initial choice value
trialQs <- matrix(data = NA, nrow = nTrials, ncol = nArms) #Qs values for all trials
choiceProbs <- vector(length = length(banditArms)) #current choice probabilities for given trial
trialChoiceProbs <- matrix(data = NA, nrow = nTrials, ncol = nArms) #choice probabilities for all trials
choices <- vector(length = nTrials) #stores choices made at each trial
rewards <- vector(length = nTrials) #stores rewards received at each trial
trialCs <- matrix(data = NA, nrow = nTrials, ncol = nArms) #Choice history

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
  currentCs[arm] <- Ci
}

#simulation
for (trial in 1:nTrials) {
  
  #calculate sumExp for softmax function
  sumExp <- 0
  for (arm in banditArms) {
    sumExp <- sumExp + exp(beta * (currentQs[arm] + phi * currentC))
  }
  
  #calculate choice probabilities
  for (arm in banditArms) {
    choiceProbs[arm] = exp(beta * (currentQs[arm] + phi * currentC)) / sumExp
  }
  
  #save choice probabilities in matrix for later visualization
  trialChoiceProbs[trial,] <- choiceProbs
  
  # choose action given choice probabilities, save in choices vector
  choices[trial] <- sample(banditArms, size = 1, replace = FALSE, prob = choiceProbs)
  
  # Stochastic Reward
  # #given bandit arm choice, get reward outcome (based on armProbabilities)
  # if ((trial %% 40) <= 20){
  #   rewards[trial] <- rbinom(1,size = 1,prob = armProbabilities1[choices[trial]])
  # } else {
  #   rewards[trial] <- rbinom(1,size = 1,prob = armProbabilities2[choices[trial]])
  # }
  
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
  
  # give action chosen, update choice history value
  for (arm in banditArms) {
    currentCs[arm] <- (1-theta) * currentCs[arm] + theta* iselse(choices[trial]==arm,1,0)
  }
  
  #save C values in matrix of C values for visualization
  trialCs[choices[trial]] <- currentCs
}

##### Save Data ####
#combine choices and rewards into dataframe
df <- data.frame(choices, rewards)

#save out data df as csv
fileName <- paste(data_out, "Generated_Data.csv",sep = "/")
write.csv(df,fileName, row.names = FALSE)

##### Plot Trial Qs #####
#turn trialQs matrix into dataframe
Qvalues_df <- as.data.frame(trialQs)

#add column names
for (i in 1:length(Qvalues_df)){
  colnames(Qvalues_df)[i] <- paste("Arm", i, sep="")
}

#add column of trial counts
Qvalues_df$trialCount <- as.numeric(row.names(Qvalues_df))

#turn df into long format for plotting
Qvalues_long <- melt(Qvalues_df, id = "trialCount")

#plot Q values over time
ggplot(data=Qvalues_long, aes(x = trialCount, y = value, color = variable)) +
  geom_point(size = 0.5) +
  geom_vline(xintercept = seq(0, nTrials, by=20)) +
  ggtitle("Q values by Trial")

##### Plot Trial Choice Probs #####
#turn trial choice probs into dataframe
ChoiceProbs_df <- as.data.frame(trialChoiceProbs)

#add column names
for (i in 1:length(ChoiceProbs_df)){
  colnames(ChoiceProbs_df)[i] <- paste("Arm", i, sep="")
}

#add column of trial counts
ChoiceProbs_df$trialCount <- as.numeric(row.names(ChoiceProbs_df))

#turn df into long format for plotting
ChoiceProbs_long <- melt(ChoiceProbs_df, id = "trialCount")

#plot Q values over time
ggplot(data=ChoiceProbs_long, aes(x = trialCount, y = value, color = variable)) +
  geom_point(size = 0.5) +
  ggtitle("Probability of Choosing Arm by Trial") +
  geom_vline(xintercept = seq(0, nTrials, by=20)) +
  ylim(0,1)

##### Plot Trial Choices #####
choice_df <- data.frame(matrix(unlist(choices), nrow=length(choices), byrow=T))

colnames(choice_df)[1] <- "trialChoice"

choice_df$trialCount <- as.numeric(row.names(choice_df))

ggplot(data=choice_df, aes(x = trialCount, y = trialChoice)) +
  geom_point(size = 0.5) +
  geom_vline(xintercept = seq(0, nTrials, by=20)) +
  ggtitle("Agent Choices")

##### Accuracy #####
indexer1 = c(1:20, 41:60, 81:100) #, 121:140, 161:180, 201:220)
indexer2 = c(21:40, 61:80, 101:120) #, 141:160, 181:200, 221:240)

n_correct_1_blocks = sum(choices[indexer1] == 1)
n_correct_2_blocks = sum(choices[indexer2] == 2)

accuracy = (n_correct_1_blocks + n_correct_2_blocks) / nTrials

print(n_correct_1_blocks)
print(n_correct_2_blocks)
print(accuracy)

##### Plot Reward Validities #####
reward_structure_df <- data.frame(matrix(unlist(rule1_reward), nrow=length(rule1_reward), byrow=T))

colnames(reward_structure_df)[1] <- "trialReward"

reward_structure_df$trialCount <- as.numeric(row.names(reward_structure_df))

ggplot(data=reward_structure_df, aes(x = trialCount, y = trialReward)) +
  geom_point(size = 0.5) +
  geom_vline(xintercept = seq(0, nTrials, by=20)) +
  ggtitle("Trial Reward Structure")