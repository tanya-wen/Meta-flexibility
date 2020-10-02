library(ggplot2)
library(reshape2)
data_out <- "/Users/tanyawen/Box/Extra_Space_for_Tanya/meta-flexibility" #the folder where you want the data to be outputted

#parameter specifications
nTrials <- 120
nArms <- 2 
banditArms <- c(1:nArms)
armProbabilities1 <- c(0.8, 0.2) 
armProbabilities2 <- c(0.2, 0.8)
alpha <- .5 #learning rate
beta <- 5 #inverse temperature
currentQ <- 0.5 #current Q values for given trial
trialQs <- matrix(data = NA, nrow = nTrials, ncol = 1) #Qs values for all trials
choiceProbs <- vector(length = length(banditArms)) #current choice probabilities for given trial
trialChoiceProbs <- matrix(data = NA, nrow = nTrials, ncol = nArms) #choice probabilities for all trials
choices <- vector(length = nTrials) #stores choices made at each trial
activeRules <- vector(length = nTrials) #stores activeRules received at each trial

#create array of rewards for each rule
trialRewardValidities <- sample(c(rep(0, .2 * nTrials), rep(1, .8 * nTrials)))

#loop through trial reward validities and build reward arrays
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

#simulation
for (trial in 1:nTrials) {
  #get current Q value based on active rule tracker
  rule1_Q = 1 - currentQ 
  rule2_Q = currentQ
  
  #calculate probabilities using logistic regression
  rule1_prob = (1 + exp(beta * (rule2_Q - rule1_Q))) ** (-1)
  rule2_prob = 1 - rule1_prob
  
  #save arm probabilities into a single variable
  choiceProbs = c(rule1_prob, rule2_prob)
  
  #save choice probabilities in matrix for later visualization
  trialChoiceProbs[trial,] <- choiceProbs
  
  # choose action given choice probabilities, save in choices vector
  choices[trial] <- sample(banditArms, size = 1, replace = FALSE, prob = choiceProbs)
  
  # Stochastic Reward
  # #given bandit arm choice, get reward outcome (based on armProbabilities)
  # if ((i %% 40) > 0 && (i %% 40) <= 20){
  #   rewards[trial] <- rbinom(1,size = 1,prob = armProbabilities1[choices[trial]])
  # } else {
  #   rewards[trial] <- rbinom(1,size = 1,prob = armProbabilities2[choices[trial]])
  # }
  
  # Predetermined trial validities
  if (choices[trial] == 1){
    if (rule1_reward[trial] == 1){
      trialRule <- 1
    } else {
      trialRule <- 2
    }
  } else {
    if (rule2_reward[trial] == 1){
      trialRule <- 2
    } else {
      trialRule <- 1
    }
  }
  activeRules[trial] <- trialRule
  
  #given reward outcome, update Q values
  currentQ <- currentQ + alpha * (trialRule - currentQ - 1)
  
  #save Q values in matrix of all Q-values for later visualization
  trialQs[trial,] <- currentQ
}

##### Save Data ####
#combine choices and activeRules into dataframe
df <- data.frame(choices, activeRules)

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

#plot Q value over time
ggplot(data=Qvalues_long, aes(x = trialCount, y = value, color = variable)) +
  geom_point(size = 0.5) +
  geom_vline(xintercept = seq(0, nTrials, by=20)) +
  ggtitle("Q value by Trial") +
  theme(legend.position = "none")

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

#plot arm probabilities over time
ggplot(data=ChoiceProbs_long, aes(x = trialCount, y = value, color = variable)) +
  geom_point(size = 0.5) +
  ggtitle("Probability of Choosing Arm by Trial") +
  geom_vline(xintercept = seq(0, nTrials, by=20)) +
  ylim(0,1)

##### Plot Reward Validities #####
reward_structure_df <- data.frame(matrix(unlist(rule1_reward), nrow=length(rule1_reward), byrow=T))

colnames(reward_structure_df)[1] <- "trialReward"

reward_structure_df$trialCount <- as.numeric(row.names(reward_structure_df))

ggplot(data=reward_structure_df, aes(x = trialCount, y = trialReward)) +
  geom_point(size = 0.5) +
  geom_vline(xintercept = seq(0, nTrials, by=20)) +
  ggtitle("Trial Reward Structure")

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

