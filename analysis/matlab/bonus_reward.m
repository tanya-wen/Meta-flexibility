% calculate reward
clear all; close all; clc;

files = dir('/Users/tanyawen/Box/Home Folder tw260/Private/meta-flexibility/Pilots/mturk/pilot2/*.log');

nsubj = 48;
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
    
end


%find(ismember(workerId,lower('A1D9ZWU1M46SAF')))