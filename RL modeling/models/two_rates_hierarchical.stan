// Big Hierarchical Two Rates Model

data {
  int<lower=1> nSubjects; 
  int<lower=1, upper=2> nChoices;
  int<lower=1, upper=2> nGroups;
  int<lower=1, upper=2> nPhases;
  int<lower=1, upper=3> nExperiments; 
  int<lower=0> nTrials; //all trial count
  int<lower=0> madeChoiceTrials; //trial count excluding no response nTrials
  int<lower=0> subject[nTrials]; //which subject does each trial belong to
  int<lower=0> trialNum[nTrials]; //within subject trial count
  int<lower=1, upper =3> experiment[nSubjects]; 
  int<lower=1, upper =2> group[nSubjects]; 
  int<lower=1, upper =2> phase[nTrials]; 
  int<lower=0, upper =2> choices[nTrials]; 
  int<lower=0, upper =1> rewards[nTrials]; 
}

parameters {
  //eta (positive feedback trials)
  real eta_P_mu_mu;
  real<lower=0> eta_P_mu_sigma;
  real eta_P_mu_raw[nPhases,nGroups,nExperiments];
  real<lower=0> eta_P_sigma;
  vector[nSubjects] eta_P_raw;
  
  //eta (negative feedback trials)
  real eta_N_mu_mu;
  real<lower=0> eta_N_mu_sigma;
  real eta_N_mu_raw[nPhases,nGroups,nExperiments];
  real<lower=0> eta_N_sigma;
  vector[nSubjects] eta_N_raw;
  
  //beta
  real beta_mu_mu;
  real<lower=0> beta_mu_sigma;
  real beta_mu_raw[nPhases,nGroups,nExperiments];
  real<lower=0> beta_sigma;
  vector[nSubjects] beta_raw;
  
  // misc
  vector[5] starting_utility; 
}

transformed parameters {
  real eta_P_mu[nPhases,nGroups,nExperiments];
  real eta_N_mu[nPhases,nGroups,nExperiments];
  real beta_mu[nPhases,nGroups,nExperiments];
  vector[nPhases] eta_P[nSubjects];
  vector[nPhases] eta_N[nSubjects];
  vector[nPhases] beta[nSubjects];
  vector[nChoices] Q[nTrials];
  
  vector[nTrials] raw_log_lik;
  vector[madeChoiceTrials] log_lik;
  
  { // Opening bracket to start a "block".
  // Variables declared in this block cannot be seen outside of the block.
  int cnt = 0; // Variable declarations must be at the top of a block.
  int idx = 0; // we need to seperately index starting utility
  
  for (p in 1:nPhases) {
    for (g in 1:nGroups) {
      for (ex in 1:nExperiments) {
        eta_P_mu[p,g,ex] = eta_P_mu_mu + eta_P_mu_sigma * eta_P_mu_raw[p,g,ex];
        eta_N_mu[p,g,ex] = eta_N_mu_mu + eta_N_mu_sigma * eta_N_mu_raw[p,g,ex];
        beta_mu[p,g,ex] = beta_mu_mu + beta_mu_sigma * beta_mu_raw[p,g,ex];
      }
    }
  }
  
  
  for (s in 1:nSubjects){
    for (p in 1:nPhases){
      eta_P[s, p] = eta_P_mu[p, group[s], experiment[s]] + eta_P_raw[s] * eta_P_sigma;
      eta_N[s, p] = eta_N_mu[p, group[s], experiment[s]] + eta_N_raw[s] * eta_N_sigma;
      beta[s, p] = beta_mu[p, group[s], experiment[s]] + beta_raw[s] * beta_sigma;
    }
  }
  
  for (t in 1:nTrials){
   if (trialNum[t]==1 && experiment[subject[t]]==1) { // first trial for a phase for a given subject
      Q[t][1] = starting_utility[1]; // Experiment 1, phase 1
      Q[t][2] = starting_utility[1];
    } else if (trialNum[t]==1 && experiment[subject[t]]==2) {
      Q[t][1] = starting_utility[2]; // Experiment 2, phase 1
      Q[t][2] = starting_utility[2];
    } else if (trialNum[t]==2 && experiment[subject[t]]==2) {
      Q[t][1] = starting_utility[3]; // Experiment 2, phase 2
      Q[t][2] = starting_utility[3];
    } else if (trialNum[t]==1 && experiment[subject[t]]==3) {
      Q[t][1] = starting_utility[4]; // Experiment 3, phase 1
      Q[t][2] = starting_utility[4];
    } else if (trialNum[t]==2 && experiment[subject[t]]==3) {
      Q[t][1] = starting_utility[5]; // Experiment 3, phase 2
      Q[t][2] = starting_utility[5];
    } else {
      Q[t][1] = Q[t-1][1]; // inherit previous values
      Q[t][2] = Q[t-1][2];
      if (choices[t-1] != 0){ // if the previous trial was not a missed trial
      if (rewards[t-1] == 1) {
        Q[t][choices[t-1]] = Q[t-1][choices[t-1]] + inv_logit(eta_P[ subject[t], phase[t]] ) * (rewards[t-1] - Q[t-1][choices[t-1]]);
      } else {
        Q[t][choices[t-1]] = Q[t-1][choices[t-1]] + inv_logit(eta_N[ subject[t], phase[t]] ) * (rewards[t-1] - Q[t-1][choices[t-1]]);
      }
      }
    }
     if (choices[t] != 0){
      raw_log_lik[t] = bernoulli_logit_lpmf(choices[t] - 1 | beta[subject[t], phase[t]] * (Q[t][2]-Q[t][1]));
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
  for (p in 1:nPhases) {
    for (g in 1:nGroups) {
      for (ex in 1:nExperiments) {
        eta_P_mu_raw[p,g,ex] ~ normal(0,1);
      }
    }
  }
  eta_P_sigma ~ normal(0,1);
  eta_P_raw ~ normal(0,1);
  
  //eta (negative feedback)
  eta_N_mu_mu ~ normal(0,1);
  eta_N_mu_sigma ~ normal(0,1);
  for (p in 1:nPhases) {
    for (g in 1:nGroups) {
      for (ex in 1:nExperiments) {
        eta_N_mu_raw[p,g,ex] ~ normal(0,1); 
      }
    }
  }
  eta_N_sigma ~ normal(0,1);
  eta_N_raw ~ normal(0,1);
  
  //beta 
  beta_mu_mu ~ normal(5,5);
  beta_mu_sigma ~ normal(0,5);
  for (p in 1:nPhases) {
    for (g in 1:nGroups) {
      for (ex in 1:nExperiments) {
        beta_mu_raw[p,g,ex] ~ normal(0,1); 
      }
    }
  }
  beta_sigma~ normal(0,5);
  beta_raw ~ normal(0,1);

  //misc
  for (idx in 1:5) {
    starting_utility[idx] ~ normal(0.5,0.5);
  }
  
  for (t in 1:nTrials){
    if (choices[t] != 0){ // adding this to avoid issues with missed trials
      target += log_softmax( beta[subject[t], phase[t]] * Q[t])[choices[t]]; // the probability of the choices on each trial given utilities
    }
  }
}

generated quantities{
  vector[nPhases] alpha_P[nSubjects]; 
  vector[nPhases] alpha_N[nSubjects]; 
  real alpha_P_mu[nPhases,nGroups,nExperiments];
  real alpha_N_mu[nPhases,nGroups,nExperiments];
  
  // subject alphas
  for (s in 1:nSubjects){
    for (p in 1:nPhases){
      alpha_P[s, p] = inv_logit(eta_P[s, p]);
      alpha_N[s, p] = inv_logit(eta_N[s, p]);
    }
  }
  
  // mean alphas by condition
  for (p in 1:nPhases) {
    for (g in 1:nGroups) {
      for (ex in 1:nExperiments) {
        alpha_P_mu[p,g,ex] = inv_logit(eta_P_mu[p,g,ex]);
        alpha_N_mu[p,g,ex] = inv_logit(eta_N_mu[p,g,ex]);
      }
    }
  }
}

