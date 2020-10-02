data {
  int<lower = 0> nSortingRules; //number of bandit arms
  int<lower = 0> nTrials; //number of trials
  int<lower = 1> ruleChoice[nTrials]; //index of which arm was pulled
  int<lower = 0> result[nTrials]; //outcome of bandit arm pull
}

parameters {
  real<lower = 0, upper = 1> alpha; //learning rate
  real beta; //softmax parameter - inverse temperature
  real phi; // choice trace weight parameter. Controls the tendency to repeat (when positive) or avoid (when negative) recently chosen options. 
  real<lower = 0, upper = 1> theta; // decay parameter of choices (choices are assumed to decay expon). Used to update C.
}

transformed parameters {
  vector<lower=0, upper=1>[nSortingRules] Q[nTrials]; // value function for each arm
  real delta[nTrials]; // prediction error
  vector [nSortingRules] C[nTrials]; // C is choice history, a trace that quantifies how frequently an was chosen recently.
  real d; // which rule was chosen (transform 1 & 2 to 0 & 1)
  for (trial in 1:nTrials) {
    //set initial Q and delta for each trial
    if (trial == 1) {
      //if first trial, initialize Q and delta values as specified
      for (a in 1:nSortingRules) {
        Q[1, a] = 0.5; //where 1 refers to it being the first trial
        delta[1] = 0;
        C[1,a] = 0;
      }
    } else {
      //otherwise, carry forward Q and delta from last trial to serve as initial value
      for (a in 1:nSortingRules) {
        Q[trial, a] = Q[trial - 1, a];
        delta[trial] = 0;
        C[trial,a] = C[trial-1,a];
      }
    }
    //calculate prediction error and update Q (based on specified beta)
    delta[trial] = result[trial] - Q[trial, ruleChoice[trial]];
    //update Q value based on prediction error (delta) and learning rate (alpha)
    Q[trial, ruleChoice[trial]] = Q[trial, ruleChoice[trial]] + alpha * delta[trial];
    // update C based on theta
    for (a in 1:nSortingRules) {
      if (ruleChoice[trial] == a) {
        d = 1;
      } else {
        d = 0;
      }
      C[trial, a] = (1-theta) * C[trial,a] + theta*d;
    }
  }
}

model {
  // priors
  beta ~ normal(0, 5);
  alpha ~ beta(1, 1);
  phi ~normal(-5, 5);
  theta ~beta(1, 1);
  for (trial in 1:nTrials) {
    //returns the probability of having made the choice you made, given your beta and your Qs
    //(as you would have had given that beta value and the deterministic function in transformed parameters.)
    target += log_softmax((Q[trial] + phi * C[trial]) * beta)[ruleChoice[trial]];
  }
}
