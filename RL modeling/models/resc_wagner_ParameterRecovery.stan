// Big Hierarchical Rescorla Wagner Model
data {
  int<lower=1> nSubjects; 
  int<lower=1, upper=2> nChoices;
  int<lower=1, upper=2> nGroups;
  int<lower=0> nTrials; //all trial count
  int<lower=0> madeChoiceTrials; //trial count excluding no response nTrials
  int<lower=0> subject[nTrials]; //which subject does each trial belong to
  int<lower=0> trialNum[nTrials]; //within subject trial count
  int<lower=1, upper =2> group[nSubjects]; 
  int<lower=0, upper =2> choices[nTrials]; 
  int<lower=0, upper =1> rewards[nTrials]; 
}

parameters {
  //eta
  real eta_mu_mu;
  real<lower=0> eta_mu_sigma;
  real eta_mu_raw[nGroups];
  real<lower=0> eta_sigma;
  real eta_raw[nSubjects];
  
  //beta
  real beta_mu_mu;
  real<lower=0> beta_mu_sigma;
  real beta_mu_raw[nGroups];
  real<lower=0> beta_sigma;
  real beta_raw[nSubjects];
  
  // misc
  real starting_utility; // initial expected reward for either arm

}

transformed parameters {
  real eta_mu[nGroups];
  real beta_mu[nGroups];
  real eta[nSubjects];
  real beta[nSubjects];
  vector[nChoices] Q[nTrials];
  vector[madeChoiceTrials] log_lik;
  
  { // Opening bracket to start a "block".
  // Variables declared in this block cannot be seen outside of the block.
  int cnt = 0; // Variable declarations must be at the top of a block.
  
  vector[nTrials] raw_log_lik;
  

  for (g in 1:nGroups) {
    eta_mu[g] = eta_mu_mu + eta_mu_sigma * eta_mu_raw[g];
    beta_mu[g] = beta_mu_mu + beta_mu_sigma * beta_mu_raw[g];
  }

  
  
  for (s in 1:nSubjects){
      eta[s] = eta_mu[group[s]] + eta_raw[s] * eta_sigma;
      beta[s] = beta_mu[group[s]] + beta_raw[s] * beta_sigma;
  }
  
  for (t in 1:nTrials){
    if (trialNum[t]==1) { 
      Q[t][1] = starting_utility; 
      Q[t][2] = starting_utility;
    } else {
      Q[t][1] = Q[t-1][1]; // inherit previous values
      Q[t][2] = Q[t-1][2];
      if (choices[t-1] != 0){ // if the previous trial was not a missed trial
      Q[t][choices[t-1]] = Q[t-1][choices[t-1]] + inv_logit( eta[ subject[t]] ) * (rewards[t-1] - Q[t-1][choices[t-1]]);
      }
    }
    if (choices[t] != 0){
      raw_log_lik[t] = bernoulli_logit_lpmf(choices[t] - 1 | beta[subject[t]] * (Q[t][2]-Q[t][1]));
    }
    if (!is_nan(raw_log_lik[t])){
      cnt = cnt + 1;
      log_lik[cnt] = raw_log_lik[t];
    }
  }
  
  } // End block
  
}

// The model to be estimated
model {
  //eta
  eta_mu_mu ~ normal(0,1);
  eta_mu_sigma ~ normal(0,1);
  for (g in 1:2) {
    eta_mu_raw[g] ~ normal(0,1);
  }
  eta_sigma ~ normal(0,1);
  eta_raw ~ normal(0,1);

  
  //beta 
  beta_mu_mu ~ normal(5,5);
  beta_mu_sigma ~ normal(0,5);
  for (g in 1:2) {
    beta_mu_raw[g] ~ normal(0,1);
  }
  beta_sigma~ normal(0,5);
  beta_raw ~ normal(0,1);

  
  //misc
  starting_utility ~ normal(0.5,0.5);
  
  for (t in 1:nTrials){
    if (choices[t] != 0){ // adding this to avoid issues with missed trials
    target += log_softmax( beta[subject[t]] * Q[t])[choices[t]]; // the probability of the choices on each trial given utilities
    }
  }
}

generated quantities{
  real alpha[nSubjects]; 
  real alpha_mu[nGroups];
  
  // subject alphas
  for (s in 1:nSubjects){
    alpha[s] = inv_logit(eta[s]);
  }
  
  // mean alphas by condition
  for (g in 1:nGroups) {
    alpha_mu[g] = inv_logit(eta_mu[g]);
  }
}
