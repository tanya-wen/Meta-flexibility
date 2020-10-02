// Hierarchical Two-Learning-Rates Model

// function for converting log_lik_raw (all trials) to log_lik (only trials with responses)
functions {
  vector convert_log_lik(vector log_lik_raw, int madeChoiceTrials, int TotalTrials) {
    int valid_trial_counter;
    vector[madeChoiceTrials] log_lik;
    valid_trial_counter = 0;
    for (i in 1:TotalTrials){
      if (!is_nan(log_lik_raw[i])){
        valid_trial_counter = valid_trial_counter + 1;
        log_lik[valid_trial_counter] = log_lik_raw[i];
      }
    }
    return log_lik;
  }
}

// Expected Input Data of Model
data {
  int<lower=0> nSubjects; // the number of subjects
  int<lower=0> TotalTrials; // total number of trials across all subjects
  int<lower=0> madeChoiceTrials; // total number of trials where a choice is made
  int<lower=0> Subject[TotalTrials]; // on each trial, which subject made the choice? ** need to be continuous vector of integars starting from 1
  int<lower=0> TrialNum[TotalTrials]; // trial number for each subject
  int<lower=0, upper = 2> choices[TotalTrials]; // all choices *** lower bound changed to 0 to accommodate missed trials
  int<lower=0, upper = 1> rewards[TotalTrials]; //all rewards
  int<lower=0, upper = 1> group[nSubjects]; //group identity of each subjects
}

// Parameters being Estimated by the Model
parameters {
  // population level
  real eta_R_mu; // hyperparameter for the mean of eta (needed for alphas), for rewarded trials
  real<lower=0> eta_R_sigma; // hyperparameter for the standard deviation of eta (needed for alphas), for unrewarded trials
  real eta_U_mu; // hyperparameter for the mean of eta (needed for alphas), for rewarded trials
  real<lower=0> eta_U_sigma; // hyperparameter for the standard deviation of eta (needed for alphas), for unrewarded trials
  real beta_mu; // hyperparameter for the mean of the distribution of beta parameters
  real<lower=0> beta_sigma; // hyperparameter for the standard deviation of the distribution of beta parameters
  
  // subject level
  vector[nSubjects] eta_R_raw; // how many standard deviations is the subject eta from the population eta, for rewarded trials
  vector[nSubjects] eta_U_raw; // how many standard deviations is the subject eta from the population eta, for unrewarded trials
  vector[nSubjects] beta_raw; // how many standard deviations is the subject beta from the population beta
  
  // group level
  real group_effect_eta_R; //estimate of how much group identity affects subject eta value, for rewarded trials
  real group_effect_eta_U; //estimate of how much group identity affects subject eta value, for unrewarded trials
  real group_effect_beta; //estimate of how much group identity affects subject beta value
  
  // misc
  real starting_utility; // initial expected reward for either arm; same for every subject and each arm
}

// Transformed parameters - parameters that are kept track of/calculated but are not being fit
transformed parameters {

  // Q value - learned from reward
  vector[2] Q[TotalTrials];
  
  // indivudal subject's eta and beta, drawn from population distribution (defined by pop means and sigmas)
  vector[nSubjects] eta_R;
  vector[nSubjects] eta_U;
  vector[nSubjects] beta;
  for (s in 1:nSubjects){
    eta_R[s] = eta_R_mu + group[s] * group_effect_eta_R + eta_R_sigma * eta_R_raw[s]; 
    eta_U[s] = eta_U_mu + group[s] * group_effect_eta_U + eta_U_sigma * eta_U_raw[s]; 
    beta[s] = beta_mu + group[s] * group_effect_beta + beta_sigma * beta_raw[s]; 
  }
  
  for (t in 1:TotalTrials){
    
    if (TrialNum[t]==1){ // first trial for a given subject
      Q[t][1] = starting_utility; // initial expected utilities for both arms
      Q[t][2] = starting_utility;
    } else{
      Q[t][1] = Q[t-1][1]; // inherit previous values
      Q[t][2] = Q[t-1][2];
      if (choices[t-1] != 0){ // if the previous trial was not a missed trial
        if (rewards[t-1] == 1) {
          Q[t][choices[t-1]] = Q[t-1][choices[t-1]] + inv_logit(eta_R[Subject[t]]) * (rewards[t-1] - Q[t-1][choices[t-1]]);
        } else {
          Q[t][choices[t-1]] = Q[t-1][choices[t-1]] + inv_logit(eta_U[Subject[t]]) * (rewards[t-1] - Q[t-1][choices[t-1]]);
        }
      }
    }
  }
}

// The model to be estimated
model {
  // population level
  eta_R_mu ~ normal(0,5); 
  eta_R_sigma ~ normal(0,1); 
  eta_U_mu ~ normal(0,5); 
  eta_U_sigma ~ normal(0,1); 
  beta_mu ~ normal(5,10); 
  beta_sigma ~ normal(0,5); 
  
  //subject level
  beta_raw ~ normal(0,1);
  eta_R_raw ~ normal(0,1);
  eta_U_raw ~ normal(0,1);
  
  //group level
  // group_effect_eta_R ~ 
  // group_effect_eta_U ~ 
  // group_effect_beta ~ 

  //misc
  starting_utility ~ normal(0.5,0.5);
  
  for (t in 1:TotalTrials){
    if (choices[t] != 0){ // adding this to avoid issues with missed trials
      target += log_softmax(beta[Subject[t]] * Q[t])[choices[t]]; // the probability of the choices on each trial given utilities
    }
  }
}

// Generated after model fitting, turns eta into alpha (learning rate between 0 and 1)
generated quantities{
  vector[nSubjects] alpha_R;
  vector[nSubjects] alpha_U;
  real alpha_R_mu;
  real alpha_U_mu;
  real alpha_R_sigma;
  real alpha_U_sigma;
  vector[TotalTrials] raw_log_lik; // log likelihood for model comparison; one value per trial
  vector[madeChoiceTrials] log_lik; // actual log lik, excluding missing-choice trials
  
  // get alpha for each subject
  for (s in 1:nSubjects){
    alpha_R[s] = inv_logit(eta_R[s]);
    alpha_U[s] = inv_logit(eta_U[s]);
  }

  // caluclate mean and sigma of subject alphas
  alpha_R_mu = mean(alpha_R);
  alpha_R_sigma = sd(alpha_R);
  alpha_U_mu = mean(alpha_U);
  alpha_U_sigma = sd(alpha_U);
  
  // get log likelihood of each trial
  for (t in 1:TotalTrials){
    if (choices[t] != 0){ // check for missing-choice trials
      raw_log_lik[t] = bernoulli_logit_lpmf(choices[t] - 1 | beta[Subject[t]] * (Q[t][2]-Q[t][1])); 
      // bernoulli_logit_lpmf(choices[t] - 1 | beta0 + beta1*(p))
      // beta0 baseline probability; beta1 inverse temperature
    } 
  }
  
  // remove missing-choice trials (NaNs)
  log_lik = convert_log_lik(raw_log_lik, madeChoiceTrials, TotalTrials);
}
