// Big Hierarchical Two Rates Model

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
  //eta (positive feedback trials)
  real eta_P_mu_mu;
  real<lower=0> eta_P_mu_sigma;
  real eta_P_mu_raw[nGroups];
  real<lower=0> eta_P_sigma;
  vector[nSubjects] eta_P_raw;
  
  //eta (negative feedback trials)
  real eta_N_mu_mu;
  real<lower=0> eta_N_mu_sigma;
  real eta_N_mu_raw[nGroups];
  real<lower=0> eta_N_sigma;
  vector[nSubjects] eta_N_raw;
  
  //beta
  real beta_mu_mu;
  real<lower=0> beta_mu_sigma;
  real beta_mu_raw[nGroups];
  real<lower=0> beta_sigma;
  vector[nSubjects] beta_raw;
  
  // misc
  real starting_utility; 
}

transformed parameters {
  real eta_P_mu[nGroups];
  real eta_N_mu[nGroups];
  real beta_mu[nGroups];
  real eta_P[nSubjects];
  real eta_N[nSubjects];
  real beta[nSubjects];
  vector[nChoices] Q[nTrials];
  
  vector[nTrials] raw_log_lik;
  vector[madeChoiceTrials] log_lik;
  
  { // Opening bracket to start a "block".
  // Variables declared in this block cannot be seen outside of the block.
  int cnt = 0; // Variable declarations must be at the top of a block.
  int idx = 0; // we need to seperately index starting utility
  
  for (g in 1:nGroups) {
    eta_P_mu[g] = eta_P_mu_mu + eta_P_mu_sigma * eta_P_mu_raw[g];
    eta_N_mu[g] = eta_N_mu_mu + eta_N_mu_sigma * eta_N_mu_raw[g];
    beta_mu[g] = beta_mu_mu + beta_mu_sigma * beta_mu_raw[g];
  }
  
  
  for (s in 1:nSubjects){
      eta_P[s] = eta_P_mu[group[s]] + eta_P_raw[s] * eta_P_sigma;
      eta_N[s] = eta_N_mu[group[s]] + eta_N_raw[s] * eta_N_sigma;
      beta[s] = beta_mu[group[s]] + beta_raw[s] * beta_sigma;
  }
  
  for (t in 1:nTrials){
   if (trialNum[t]==1) { // first trial for a phase for a given subject
      Q[t][1] = starting_utility; 
      Q[t][2] = starting_utility;
    } else {
      Q[t][1] = Q[t-1][1]; // inherit previous values
      Q[t][2] = Q[t-1][2];
      if (choices[t-1] != 0){ // if the previous trial was not a missed trial
      if (rewards[t-1] == 1) {
        Q[t][choices[t-1]] = Q[t-1][choices[t-1]] + inv_logit(eta_P[ subject[t]] ) * (rewards[t-1] - Q[t-1][choices[t-1]]);
      } else {
        Q[t][choices[t-1]] = Q[t-1][choices[t-1]] + inv_logit(eta_N[ subject[t]] ) * (rewards[t-1] - Q[t-1][choices[t-1]]);
      }
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
  //eta (positive feedback)
  eta_P_mu_mu ~ normal(0,1);
  eta_P_mu_sigma ~ normal(0,1);
  for (g in 1:nGroups) {
    eta_P_mu_raw[g] ~ normal(0,1);
  }

  eta_P_sigma ~ normal(0,1);
  eta_P_raw ~ normal(0,1);
  
  //eta (negative feedback)
  eta_N_mu_mu ~ normal(0,1);
  eta_N_mu_sigma ~ normal(0,1);
  for (g in 1:nGroups) {
    eta_N_mu_raw[g] ~ normal(0,1); 
  }

  eta_N_sigma ~ normal(0,1);
  eta_N_raw ~ normal(0,1);
  
  //beta 
  beta_mu_mu ~ normal(5,5);
  beta_mu_sigma ~ normal(0,5);
  for (g in 1:nGroups) {
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
  real alpha_P[nSubjects]; 
  real alpha_N[nSubjects]; 
  real alpha_P_mu[nGroups];
  real alpha_N_mu[nGroups];
  
  // subject alphas
  for (s in 1:nSubjects){
      alpha_P[s] = inv_logit(eta_P[s]);
      alpha_N[s] = inv_logit(eta_N[s]);
  }
  
  // mean alphas by condition
  for (g in 1:nGroups) {
    alpha_P_mu[g] = inv_logit(eta_P_mu[g]);
    alpha_N_mu[g] = inv_logit(eta_N_mu[g]);
  }
  
}

