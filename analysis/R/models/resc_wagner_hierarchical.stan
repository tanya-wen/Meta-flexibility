// Hierarchical Rescorla Wagner Model

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
  real eta_mu; // hyperparameter for the mean of eta (needed for alphas)
  real<lower=0> eta_sigma; // hyperparameter for the standard deviation of eta (needed for alphas)
  real beta_mu; // hyperparameter for the mean of the distribution of beta parameters
  real<lower=0> beta_sigma; // hyperparameter for the standard deviation of the distribution of beta parameters
  
  // subject level
  vector[nSubjects] eta_raw; // how many standard deviations is the subject eta from the population eta
  vector[nSubjects] beta_raw; // how many standard deviations is the subject beta from the population beta
  
  // group level
  real group_effect_eta; //estimate of how much group identity affects subject eta value
  real group_effect_beta; //estimate of how much group identity affects subject beta value
  
  // misc
  real starting_utility; // initial expected reward for either arm; same for every subject and each arm
}

// Transformed parameters - parameters that are kept track of/calculated but are not being fit
transformed parameters {

  // Q value - learned from reward
  vector[2] Q[TotalTrials];
  
  // indivudal subject's eta and beta, drawn from population distribution (defined by pop means and sigmas)
  vector[nSubjects] eta;
  vector[nSubjects] beta;
  for (s in 1:nSubjects){
    eta[s] = eta_mu + group[s] * group_effect_eta + eta_sigma * eta_raw[s]; 
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
       Q[t][choices[t-1]] = Q[t-1][choices[t-1]] + inv_logit(eta[Subject[t]]) * (rewards[t-1] - Q[t-1][choices[t-1]]);
      }
    }
  }
}

// The model to be estimated
model {
  // population level
  eta_mu ~ normal(0,5); 
  eta_sigma ~ normal(0,1); 
  beta_mu ~ normal(5,10); 
  beta_sigma ~ normal(0,5); 
  
  //subject level
  beta_raw ~ normal(0,1);
  eta_raw ~ normal(0,1);
  
  //group level
  //group_effect_eta ~ 
  //group_effect_beta ~ 

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
  vector[nSubjects] alpha;
  real alpha_mu;
  real alpha_sigma;
  vector[TotalTrials] raw_log_lik; // log likelihood for model comparison; one value per trial
  vector[madeChoiceTrials] log_lik; // actual log lik, excluding missing-choice trials
  
  // get alpha for each subject
  for (s in 1:nSubjects){
    alpha[s] = inv_logit(eta[s]);
  }

  // caluclate mean and sigma of subject alphas
  alpha_mu = mean(alpha);
  alpha_sigma = sd(alpha);
  
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
