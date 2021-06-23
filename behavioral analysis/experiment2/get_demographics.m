% get participant demographics info
clear all; close all; clc;

files = dir('C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/mturk data/experiment2/*.log');

nsubj = 94;
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
        
        if isequal(volatility{subj_ind},'low') == 1
            age_low{low_ind} = str2num(data.age{285});
            gender_low{low_ind} = data.gender{285};
            low_ind = low_ind + 1;
        elseif isequal(volatility{subj_ind},'high') == 1
            age_high{high_ind} = str2num(data.age{285});
            gender_high{high_ind} = data.gender{285};
            high_ind = high_ind + 1;
        end
        
        subj_ind = subj_ind + 1;
        break
    end
end

mean(cell2mat(age_low))
std(cell2mat(age_low))
min(cell2mat(age_low))
max(cell2mat(age_low))
mean(cell2mat(age_high))
std(cell2mat(age_high))
min(cell2mat(age_high))
max(cell2mat(age_high))

sum(ismember(gender_low,'Male'))
sum(ismember(gender_low,'Female'))
sum(ismember(gender_high,'Male'))
sum(ismember(gender_high,'Female'))
