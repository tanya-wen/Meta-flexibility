% calculate reward
clear all; close all; clc;

files = dir('C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/mturk data/experiment2/*.log');

nsubj = 94;bad_subj_list = [];
for subj = 1:nsubj
    
    % load data from each subject
    data = readtable(files(subj).name,'FileType','text');
    workerId{subj} = data.workerId{1};
    assignmentId{subj} = data.assignmentId{1};
    
    task_ind = [find(~cellfun(@isempty,regexp(data.practice,'true')));find(~cellfun(@isempty,regexp(data.practice,'false')))];
    
    maintask_ind = find(~cellfun(@isempty,regexp(data.practice,'false')));
    subject_total_acc(subj) = mean(~cellfun(@isempty,regexp(data.response_acc(maintask_ind),'true')));
    
    subject_bonus(subj) = 0.01*(sum(~cellfun(@isempty,regexp(data.response_acc(task_ind),'true')).*~cellfun(@isempty,regexp(data.reward_validity(task_ind),'1')))...
        + sum(~cellfun(@isempty,regexp(data.response_acc(task_ind),'false')).*~cellfun(@isempty,regexp(data.reward_validity(task_ind),'0'))));
    
    
    if subject_total_acc(subj) < 0.65
        bad_subj_list = [bad_subj_list,subj];
        subject_is_good = 0;
    end
end


% average bonus
good_subjs = setdiff(1:94,bad_subj_list);
mean(subject_bonus(good_subjs))
std(subject_bonus(good_subjs))
