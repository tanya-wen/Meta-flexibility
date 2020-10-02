data {
  int<lower = 0> nSortingRules; //number of bandit arms
  int<lower = 0> nTrials; //number of trials
  int<lower = 1> ruleChoice[nTrials]; //index of which arm was pulled
  int<lower = 0> activeRule[nTrials]; //outcome of bandit arm pull
}

parameters {
  real<lower = 0, upper = 1> alpha; //learning rate
  real beta; //softmax parameter - inverse temperature
}

transformed parameters {
  real Q[nTrials]; // value function for each arm
  vector<lower=0, upper=1>[nSortingRules] armQs[nTrials];
  real delta[nTrials]; // prediction error
  for (trial in 1:nTrials) {
    //set initial Q and delta for each trial
    if (trial == 1) {
      //if first trial, initialize Q and delta values as specified
        Q[1] = 0.5; //where 1 refers to it being the first trial
    } else {
      //otherwise, carry forward Q and delta from last trial to serve as initial value
        Q[trial] = Q[trial - 1];
    }
    //calculate prediction error and update Q (based on specified beta)
    delta[trial] = activeRule[trial] - Q[trial] - 1; # minus extra 1 because active reward is coded as 1 & 2 instead of 0 & 1
    //update Q value based on prediction error (delta) and learning rate (alpha)
    Q[trial] = Q[trial] + alpha * delta[trial];
    armQs[trial,1] = 1-Q[trial];
    armQs[trial,2] = Q[trial];
  }
}

model {
  // priors
  beta ~ normal(0, 5);
  alpha ~ beta(1, 1);
  for (trial in 1:nTrials) {
    //returns the probability of having made the choice you made, given your beta and your Qs
    //(as you would have had given that beta value and the deterministic function in transformed parameters.)
    target += log_softmax(armQs[trial] * beta)[ruleChoice[trial]];
  }
}
