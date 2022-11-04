% behavioral results breakdown
% response correct - feedback positive 
% response correct - feedback negative 
% response incorrect - feeback positive 
% response incorrect - feedback negative 

clear all; close all; clc;

files = dir('C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/mturk data/experiment3/*.log');
fig_path = 'C:/Users/Tanya Wen/Box/Home Folder tw260/Private/meta-flexibility/manuscript/figures';

nsubj = numel(files);
bad_subj_list = [];
subj_ind = 1; low_ind = 1; high_ind = 1;
for subj = 1:nsubj
    subject_is_good = 1;
    
    % load data from each subject
    data = readtable(files(subj).name,'FileType','text');
    task_ind = find(~cellfun(@isempty,regexp(data.practice,'false')));
    learning_ind = task_ind(1:numel(task_ind)/2);
    transfer_ind = task_ind(numel(task_ind)/2+1:end);
    
    subject_total_acc(subj) = mean(~cellfun(@isempty,regexp(data.response_acc(task_ind),'true')));
    subject_learning_acc(subj) = mean(~cellfun(@isempty,regexp(data.response_acc(learning_ind),'true')));
    subject_transfer_acc(subj) = mean(~cellfun(@isempty,regexp(data.response_acc(transfer_ind),'true')));
    % mark bad subjects
    if subject_total_acc(subj) < 0.65 
        bad_subj_list = [bad_subj_list,subj];
        subject_is_good = 0;
    end
    
    
    while subject_is_good
        %% Obtain which volatility group this participant is in
        volatility{subj_ind} = data.volatility{41};
        
        %% Obtain behavioral results
        subj_accuracy(subj_ind,:) = data.response_acc(task_ind);
        subj_RT(subj_ind,:) = cellfun(@str2double,data.response_time(task_ind));
        subj_RT(subj_RT==0) = NaN;
        
        %% get behavior breakdown
        answer = data.answer(task_ind);
        response = data.response(task_ind);
        reward_validity = data.reward_validity(task_ind);
        
        rC_fp_trials = strcmpi(answer,response).*str2double(reward_validity); % response correct - feedback positive 
        rC_fn_trials = strcmpi(answer,response).*(1-str2double(reward_validity)); % response correct - feedback negative
        ri_fp_trials = (1-strcmpi(answer,response)).*(1-str2double(reward_validity)); % response incorrect - feedback positive 
        ri_fn_trials = (1-strcmpi(answer,response)).*str2double(reward_validity); % response incorrect - feedback negative 
        
        rC_fp_learning(subj_ind) = sum(rC_fp_trials(1:120)); % response correct - feedback positive 
        rC_fn_learning(subj_ind) = sum(rC_fn_trials(1:120)); % response correct - feedback negative
        ri_fp_learning(subj_ind) = sum(ri_fp_trials(1:120)); % response incorrect - feedback positive 
        ri_fn_learning(subj_ind) = sum(ri_fn_trials(1:120)); % response incorrect - feedback negative 
        
        rC_fp_transfer(subj_ind) = sum(rC_fp_trials(121:240)); % response correct - feedback positive
        rC_fn_transfer(subj_ind) = sum(rC_fn_trials(121:240)); % response correct - feedback negative
        ri_fp_transfer(subj_ind) = sum(ri_fp_trials(121:240)); % response incorrect - feedback positive 
        ri_fn_transfer(subj_ind) = sum(ri_fn_trials(121:240)); % response incorrect - feedback negative 
        
        subj_ind = subj_ind + 1;
        break
    end
end
        
low_subs = find(ismember(volatility,'low'));
high_subs = find(ismember(volatility,'high'));

bar_colors = [254,178,76; 240,59,32] / 255;
% plot results
bar_input = [mean(rC_fp_learning(low_subs)),mean(rC_fn_learning(low_subs)),mean(ri_fp_learning(low_subs)),mean(ri_fn_learning(low_subs));
    mean(rC_fp_learning(high_subs)),mean(rC_fn_learning(high_subs)),mean(ri_fp_learning(high_subs)),mean(ri_fn_learning(high_subs))] / 120;
errorbar_input = [std(rC_fp_learning(low_subs)),std(rC_fn_learning(low_subs)),std(ri_fp_learning(low_subs)),std(ri_fn_learning(low_subs));
    std(rC_fp_learning(high_subs)),std(rC_fn_learning(high_subs)),std(ri_fp_learning(high_subs)),std(ri_fn_learning(high_subs))]/ 120 /sqrt(subj_ind-1);
[bar_xtick,hb,he] = errorbar_groups(bar_input,errorbar_input, 'bar_colors', bar_colors);
ax = gca;
ax.FontSize = 18;
ax.YLim = [0, 0.7];
xticklabels({'CP','CN','IP','IN'})
ylabel('proportion of trials')
set(gcf,'color','w');
legend({'low-volatility', 'high-volatility'})
print(gcf,fullfile(fig_path,'BehavBreakdown_Exp3learning.eps'),'-depsc2','-painters');
[H,P,CI,STATS] = ttest2(ri_fp_learning(low_subs)./ri_fn_learning(low_subs), ri_fp_learning(high_subs)./ri_fn_learning(high_subs))
[H,P,CI,STATS] = ttest2(rC_fp_learning(low_subs)./rC_fn_learning(low_subs), rC_fp_learning(high_subs)./rC_fn_learning(high_subs))

bar_input = [mean(rC_fp_transfer(low_subs)),mean(rC_fn_transfer(low_subs)),mean(ri_fp_transfer(low_subs)),mean(ri_fn_transfer(low_subs));
    mean(rC_fp_transfer(high_subs)),mean(rC_fn_transfer(high_subs)),mean(ri_fp_transfer(high_subs)),mean(ri_fn_transfer(high_subs))] / 120;
errorbar_input = [std(rC_fp_transfer(low_subs)),std(rC_fn_transfer(low_subs)),std(ri_fp_transfer(low_subs)),std(ri_fn_transfer(low_subs));
    std(rC_fp_transfer(high_subs)),std(rC_fn_transfer(high_subs)),std(ri_fp_transfer(high_subs)),std(ri_fn_transfer(high_subs))]/ 120 /sqrt(subj_ind-1);
[bar_xtick,hb,he] = errorbar_groups(bar_input,errorbar_input, 'bar_colors', bar_colors);
ax = gca;
ax.FontSize = 18;
ax.YLim = [0, 0.7];
xticklabels({'CP','CN','IP','IN'})
ylabel('proportion of trials')
set(gcf,'color','w');
legend({'low-volatility', 'high-volatility'})
print(gcf,fullfile(fig_path,'BehavBreakdown_Exp3transfer.eps'),'-depsc2','-painters');
[H,P,CI,STATS] = ttest2(ri_fp_transfer(low_subs)./ri_fn_transfer(low_subs), ri_fp_transfer(high_subs)./ri_fn_transfer(high_subs))
[H,P,CI,STATS] = ttest2(rC_fp_transfer(low_subs)./rC_fn_transfer(low_subs), rC_fp_transfer(high_subs)./rC_fn_transfer(high_subs))

