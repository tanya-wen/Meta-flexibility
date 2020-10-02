data {
  int<lower = 0> nSortingRules; //number of bandit arms
  int<lower = 0> nTrials; //number of trials
  int<lower = 1> ruleChoice[nTrials]; //index of which arm was pulled
  int<lower = 0> result[nTrials]; //outcome of bandit arm pull
}

parameters {
  real<lower = 0, upper = 1> alpha_R; //learning rate for Rewarded outcome
  real<lower = 0, upper = 1> alpha_U; //learning rate for Unrewarded outcome
  real beta; //softmax parameter - inverse temperature
}

transformed parameters {
  vector<lower=0, upper=1>[nSortingRules] Q[nTrials]; // value function for each arm
  real delta[nTrials]; // prediction error
  for (trial in 1:nTrials) {
    //set initial Q and delta for each trial
    if (trial == 1) {
      //if first trial, initialize Q and delta values as specified
      for (a in 1:nSortingRules) {
        Q[1, a] = 0.5; //where 1 refers to it being the first trial
      }
    } else {
      //otherwise, carry forward Q and delta from last trial to serve as initial value
      for (a in 1:nSortingRules) {
        Q[trial, a] = Q[trial - 1, a];
      }
    }
    //calculate prediction error and update Q (based on specified beta)
    delta[trial] = result[trial] - Q[trial, ruleChoice[trial]];
    //update Q value based on prediction error (delta) and learning rate (alpha)
    if (result[trial] == 1) {
      Q[trial, ruleChoice[trial]] = Q[trial, ruleChoice[trial]] + alpha_R * delta[trial];
    } else {
      Q[trial, ruleChoice[trial]] = Q[trial, ruleChoice[trial]] + alpha_U * delta[trial];
    }
  }
}

model {
  // priors
  beta ~ normal(0, 5);
  alpha_R ~ beta(1, 1);
  alpha_U ~ beta(1, 1);
  for (trial in 1:nTrials) {
    //returns the probability of having made the choice you made, given your beta and your Qs
    //(as you would have had given that beta value and the deterministic function in transformed parameters.)
    target += log_softmax(Q[trial] * beta)[ruleChoice[trial]];
  }
}
