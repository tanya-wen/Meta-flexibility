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
        subj_response(subj_ind,:) = data.response(task_ind);
        subj_accuracy(subj_ind,:) = double(~cellfun(@isempty,regexp(data.response_acc(task_ind),'true')));
        subj_RT(subj_ind,:) = cellfun(@str2double,data.response_time(task_ind));
        subj_RT(subj_RT==0) = NaN;
        
        subj_ind = subj_ind + 1;
        break
    end
end


%% divide transfer task into blocks
blocks = {142:151,162:171,182:191,202:211,222:231; 
    132:141,152:161,172:181,192:201,212:221}';
block_int = {142,162,182,202,222;
    132,152,172,192,212}';

subj_ind = 1;
for subj = 1:nsubj
    if ~ismember(subj,bad_subj_list)
        
        for block_ind = 1:length(blocks)
            
            for bin_ind = 1:2
                
            after_invalid = find(~cellfun(@isempty,regexp(reward_validity(subj_ind,blocks{block_ind,bin_ind}),'0')));
            before_invalid = after_invalid - 1;
            
            after_invalid_resp = subj_response(subj_ind,block_int{block_ind,bin_ind}+after_invalid);
            before_invalid_resp = subj_response(subj_ind,block_int{block_ind,bin_ind}+before_invalid);
            
            cum = [];
            for i = 1:numel(after_invalid_resp)
                cum = [cum, isequal(after_invalid_resp,before_invalid_resp)];
            end
            binned_switchLikelihood(subj_ind,block_ind,bin_ind) = mean(cum);
            
            end
            
        end
        subj_ind = subj_ind + 1;
        
        sub_switchLikelihood = squeeze(nanmean(binned_switchLikelihood,2));
        
    end
end

mean_switchLikelihood = mean(sub_switchLikelihood);
se_switchLikelihood = std(sub_switchLikelihood)/sqrt(subj_ind-1-1);


low_subs = find(ismember(volatility,'low'));
high_subs = find(ismember(volatility,'high'));

low_mean_switchLikelihood = mean(sub_switchLikelihood(low_subs,:));
low_se_switchLikelihood = std(sub_switchLikelihood(low_subs,:))/sqrt(numel(low_subs)-1);
high_mean_switchLikelihood = mean(sub_switchLikelihood(high_subs,:));
high_se_switchLikelihood = std(sub_switchLikelihood(high_subs,:))/sqrt(numel(high_subs)-1);

%% plot learning rate
% all subjects
figure(1)
errorbar(mean_switchLikelihood,se_switchLikelihood,'k');
xlim([0 3])

figure(2)
% low-volatility group
errorbar(low_mean_switchLikelihood,low_se_switchLikelihood,'b');
xlim([0 3])
hold on
% high-volatility group
errorbar(high_mean_switchLikelihood,high_se_switchLikelihood,'r');
xlim([0 3])
ylim([0 1])
legend('low-volatility','high-volatility')
ylabel('% of correct choices')
xlabel('trial number')
set(gcf,'color','w')
box off

[H,P,CI,STATS] = ttest2(sub_switchLikelihood(:,1),sub_switchLikelihood(:,2));

