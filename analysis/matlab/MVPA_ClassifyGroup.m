clear all; close all; clc;

files = dir('/Users/tanyawen/Box/Home Folder tw260/Private/meta-flexibility/Pilots/mturk/version1/pilot2/*.log');

nsubj = 47;
bad_subj_list = [];
subj_ind = 1; low_ind = 1; high_ind = 1;
for subj = 1:nsubj
    subject_is_good = 1;
    
    % load data from each subject
    data = readtable(files(subj).name,'FileType','text');
    task_ind = find(~cellfun(@isempty,regexp(data.practice,'false')));
    part1_ind = task_ind(1:numel(task_ind)/2);
    part2_ind = task_ind(numel(task_ind)/2+1:end);
    
    subject_total_acc(subj) = mean(~cellfun(@isempty,regexp(data.response_acc(task_ind),'true')));
    % mark bad subjects
    if subject_total_acc(subj) < 0.65
        bad_subj_list = [bad_subj_list,subj];
        subject_is_good = 0;
    end
    
    while subject_is_good
        %% Obtain which volatility group this participant is in
        volatility{subj_ind} = data.volatility{41};
        
        %% Obtain rules
        rule(subj_ind,:) = data.type(task_ind);
        reward_validity(subj_ind,:) = data.reward_validity(task_ind);
        subj_accuracy(subj_ind,:) = data.response_acc(task_ind);
        subj_RT(subj_ind,:) = cellfun(@str2double,data.response_time(task_ind));
        subj_RT(subj_RT==0) = NaN;
        for i = 2:numel(task_ind)
            if strcmp(rule(subj_ind,i),rule(subj_ind,i-1)) == 0
                switchtype{subj_ind,i} = 'switch';
            else
                switchtype{subj_ind,i} = 'repeat';
            end
        end
        for i = 2:numel(task_ind)
            if strcmp(subj_accuracy(subj_ind,i),subj_accuracy(subj_ind,i-1)) == 0
                if (ismember(subj_accuracy(subj_ind,i-1),'false').*ismember(reward_validity(subj_ind,i-1),'1')) || (ismember(subj_accuracy(subj_ind,i-1),'true').*ismember(reward_validity(subj_ind,i-1),'0'))
                    subswitch{subj_ind,i} = 'switch';
                else subswitch{subj_ind,i} = 'random error';
                end
            else
                subswitch{subj_ind,i} = 'repeat';
            end
        end

   
        subj_ind = subj_ind + 1;
        break
    end
end


%% MVPA on transfer task
transfer_ind = 122:240;

for subj = 1:size(subswitch,1)
    
    test_dat = subj;
    train_dat = setdiff(1:size(subswitch,1),test_dat);
    
    test_sub_switch = double(~cellfun(@isempty,regexp(subswitch(test_dat,transfer_ind),'switch')));
    train_sub_switch = double(~cellfun(@isempty,regexp(subswitch(train_dat,transfer_ind),'switch')));
    % missing_values = find(~cellfun(@isempty,regexp(subswitch(:,transfer_ind),'random error')));
    % train_sub_switch(missing_values) = NaN;
    
    Mdl = fitcsvm(train_sub_switch,double(~cellfun(@isempty,regexp(volatility(train_dat),'low'))));
    [predictlabels(subj),postprobs(subj,:)] = predict(Mdl,test_sub_switch);
    
end

truelabels = double(~cellfun(@isempty,regexp(volatility,'low')));

acc_mean = mean(1-abs(predictlabels-truelabels));
acc_std = std(1-abs(predictlabels-truelabels));

[H,P,CI,STATS] = ttest(1-abs(predictlabels-truelabels),0.5)




