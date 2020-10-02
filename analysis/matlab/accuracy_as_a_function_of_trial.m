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
        subj_accuracy(subj_ind,:) = double(~cellfun(@isempty,regexp(data.response_acc(task_ind),'true')));
        subj_RT(subj_ind,:) = cellfun(@str2double,data.response_time(task_ind));
        subj_RT(subj_RT==0) = NaN;
        
        subj_ind = subj_ind + 1;
        break
    end
end


%% divide transfer task into blocks
blocks = {121:140,141:160,161:180,181:200,201:220,221:240};
subj_ind = 1;
for subj = 1:nsubj
    if ~ismember(subj,bad_subj_list)
        
        for block_ind = 1:numel(blocks)
            
            blocked_LearningRate(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks{block_ind});
            
        end
        subj_ind = subj_ind + 1;
        
        sub_LearningRate = squeeze(mean(blocked_LearningRate,2));
        
    end
end

mean_LearningRate = mean(sub_LearningRate);
se_LearningRate = std(sub_LearningRate)/sqrt(subj_ind-1-1);


low_subs = find(ismember(volatility,'low'));
high_subs = find(ismember(volatility,'high'));

low_mean_LearningRate = mean(sub_LearningRate(low_subs,:));
low_se_LearningRate = std(sub_LearningRate(low_subs,:))/sqrt(numel(low_subs)-1);
high_mean_LearningRate = mean(sub_LearningRate(high_subs,:));
high_se_LearningRate = std(sub_LearningRate(high_subs,:))/sqrt(numel(high_subs)-1);

%% plot learning rate
% all subjects
figure(1)
errorbar(mean_LearningRate,se_LearningRate,'k');
xlim([0 21])

figure(2)
% low-volatility group
errorbar(low_mean_LearningRate,low_se_LearningRate,'b');
xlim([0 21])
hold on
% high-volatility group
errorbar(high_mean_LearningRate,high_se_LearningRate,'r');
xlim([0 21])
ylim([0 1])
legend('low-volatility','high-volatility')
ylabel('% of correct choices')
xlabel('trial number')
set(gcf,'color','w')
box off

[H,P,CI,STATS] = ttest2(sub_LearningRate(low_subs,:),sub_LearningRate(high_subs,:));

