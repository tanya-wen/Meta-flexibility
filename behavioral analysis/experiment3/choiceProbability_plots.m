clear all; close all; clc;

files = dir('/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/meta-flexibility/Pilots/mturk/short/version4/*.log');
addpath('/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/software/fdr_bh')
fig_path = '/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/meta-flexibility/manuscript/figures';

nsubj = 101;
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
        subj_RT(subj_ind,:) = data.response_time(task_ind); %cellfun(@str2double,data.response_time(task_ind));
        subj_RT(subj_RT==0) = NaN;
        
        subj_ind = subj_ind + 1;
        break
    end
end

low_subs = find(ismember(volatility,'low'));
high_subs = find(ismember(volatility,'high'));

%% divide learning phase into blocks
blocks_low = {1:30,31:60,61:90,91:120};
blocks_high = {1:10,11:20,21:30,31:40,41:50,51:60,61:70,71:80,81:90,91:100,101:110,111:120};
subj_ind = 1;
for subj = 1:nsubj
    
    if ~ismember(subj,bad_subj_list)
        
        if ismember(subj_ind,low_subs)
            
            for block_ind = 1:numel(blocks_low)
                
                blocked_ChoiceAcc_low(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks_low{block_ind});
                
            end
            
            sub_ChoiceAcc_low_before = squeeze(mean(blocked_ChoiceAcc_low(:,:,26:30),2));
            sub_ChoiceAcc_low_after = squeeze(mean(blocked_ChoiceAcc_low(:,2:end,1:5),2));
            
        elseif ismember(subj_ind,high_subs)
                
            for block_ind = 1:numel(blocks_high)
                
                blocked_ChoiceAcc_high(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks_high{block_ind});
                
            end
            
            sub_ChoiceAcc_high_before = squeeze(mean(blocked_ChoiceAcc_high(:,:,6:10),2));
            sub_ChoiceAcc_high_after = squeeze(mean(blocked_ChoiceAcc_high(:,2:end,1:5),2));
                
        end
            
        subj_ind = subj_ind + 1;
        
        
    end
end

low_mean_ChoiceAcc_before = mean(sub_ChoiceAcc_low_before(low_subs,:));
low_se_ChoiceAcc_before = std(sub_ChoiceAcc_low_before(low_subs,:))/sqrt(numel(low_subs));
low_mean_ChoiceAcc_after = 1 - mean(sub_ChoiceAcc_low_after(low_subs,:));
low_se_ChoiceAcc_after = std(sub_ChoiceAcc_low_after(low_subs,:))/sqrt(numel(low_subs));

high_mean_ChoiceAcc_before = mean(sub_ChoiceAcc_high_before(high_subs,:));
high_se_ChoiceAcc_before = std(sub_ChoiceAcc_high_before(high_subs,:))/sqrt(numel(high_subs));
high_mean_ChoiceAcc_after = 1 - mean(sub_ChoiceAcc_high_after(high_subs,:));
high_se_ChoiceAcc_after = std(sub_ChoiceAcc_high_after(high_subs,:))/sqrt(numel(high_subs));


% plot learning rate
figure('Renderer', 'painters', 'Position', [10 10 450 300]); hold on
% low-volatility group
errorbar([low_mean_ChoiceAcc_before, low_mean_ChoiceAcc_after],...
    [low_se_ChoiceAcc_before, low_se_ChoiceAcc_after],...
    'o-','MarkerSize',3,'Color',[254, 178, 76]/255,'LineWidth',1.5);
% high-volatility group
errorbar([high_mean_ChoiceAcc_before, high_mean_ChoiceAcc_after],...
    [high_se_ChoiceAcc_before, high_se_ChoiceAcc_after],...
    'o-','MarkerSize',3,'Color',[240, 59, 32]/255,'LineWidth',1.5);
xline(5.5,'LineWidth',1);
ax = gca;
ax.FontSize = 14;
ax.YLim = [0 1];
ax.XLim = [0 11];
xticks([1, 3, 5, 6, 8, 10])
xticklabels({'-5', '-3', '-1', '+1', '+3', '+5'})
legend('low-volatility','high-volatility')
ylabel('choice probability')
xlabel('trials after rule change')
title({'Experiment 3','learning phase'})
set(gcf,'color','w')
box off
print(gcf,fullfile(fig_path,'ChoiceProb_Exp3learning.eps'),'-depsc2','-painters');

% [H,P,CI,STATS] = ttest2(sub_ChoiceAcc_low(low_subs,:),sub_ChoiceAcc_high(high_subs,:));
% [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(P);

% average +5 and -5 trials from task switch point
% group (high vs. low) x time (before vs. after)

anova_prob = [[mean(sub_ChoiceAcc_low_before(low_subs,:),2); mean(sub_ChoiceAcc_high_before(high_subs,:),2)], ...
    [mean(1-sub_ChoiceAcc_low_after(low_subs,:),2); mean(1-sub_ChoiceAcc_high_after(high_subs,:),2)]]; 
group_names = [repmat({'low'},1,numel(low_subs)), repmat({'high'},1,numel(high_subs))]';
t = table(group_names,anova_prob(:,1),anova_prob(:,2),...
    'VariableNames',{'group','before','after'});
boundary = table(['B' 'A']','VariableNames',{'boundary'});
rm = fitrm(t,'before-after~group','WithinDesign', boundary);
ranovatable = ranova(rm, 'WithinModel','boundary');

[H,P,CI,STATS] = ttest2(mean(sub_ChoiceAcc_low_before(low_subs,:),2),mean(sub_ChoiceAcc_high_before(high_subs,:),2))
[H,P,CI,STATS] = ttest2(mean(1-sub_ChoiceAcc_low_after(low_subs,:),2),mean(1-sub_ChoiceAcc_high_after(high_subs,:),2))


%% divide transfer phase into blocks
blocks = {121:140,141:160,161:180,181:200,201:220,221:240};
subj_ind = 1;
for subj = 1:nsubj
    if ~ismember(subj,bad_subj_list)
        
        for block_ind = 1:numel(blocks)
            
            blocked_ChoiceAcc(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks{block_ind});
            
        end
        subj_ind = subj_ind + 1;
        
        sub_ChoiceAcc_before = squeeze(mean(blocked_ChoiceAcc(:,:,16:20),2));
        sub_ChoiceAcc_after = squeeze(mean(blocked_ChoiceAcc(:,2:end,1:5),2));
        
    end
end

low_mean_ChoiceAcc_before = mean(sub_ChoiceAcc_before(low_subs,:));
low_se_ChoiceAcc_before = std(sub_ChoiceAcc_before(low_subs,:))/sqrt(numel(low_subs));
low_mean_ChoiceAcc_after = 1 - mean(sub_ChoiceAcc_after(low_subs,:));
low_se_ChoiceAcc_after = std(sub_ChoiceAcc_after(low_subs,:))/sqrt(numel(low_subs));

high_mean_ChoiceAcc_before = mean(sub_ChoiceAcc_before(high_subs,:));
high_se_ChoiceAcc_before = std(sub_ChoiceAcc_before(high_subs,:))/sqrt(numel(high_subs));
high_mean_ChoiceAcc_after = 1 - mean(sub_ChoiceAcc_after(high_subs,:));
high_se_ChoiceAcc_after = std(sub_ChoiceAcc_after(high_subs,:))/sqrt(numel(high_subs));


% plot learning rate
figure('Renderer', 'painters', 'Position', [10 10 450 300]); hold on
% low-volatility group
errorbar([low_mean_ChoiceAcc_before, low_mean_ChoiceAcc_after],...
    [low_se_ChoiceAcc_before, low_se_ChoiceAcc_after],...
    'o-','MarkerSize',3,'Color',[254, 178, 76]/255,'LineWidth',1.5);
% high-volatility group
errorbar([high_mean_ChoiceAcc_before, high_mean_ChoiceAcc_after],...
    [high_se_ChoiceAcc_before, high_se_ChoiceAcc_after],...
    'o-','MarkerSize',3,'Color',[240, 59, 32]/255,'LineWidth',1.5);
xline(5.5,'LineWidth',1);
ax = gca;
ax.FontSize = 14;
ax.YLim = [0 1];
ax.XLim = [0 11];
xticks([1, 3, 5, 6, 8, 10])
xticklabels({'-5', '-3', '-1', '+1', '+3', '+5'})
legend('low-volatility','high-volatility')
ylabel('choice probability')
xlabel('trials after rule change')
title({'Experiment 3','transfer phase'})
set(gcf,'color','w')
box off
print(gcf,fullfile(fig_path,'ChoiceProb_Exp3transfer.eps'),'-depsc2','-painters');


% average +5 and -5 trials from task switch point
% group (high vs. low) x time (before vs. after)

anova_prob = [[mean(sub_ChoiceAcc_before(low_subs,:),2); mean(sub_ChoiceAcc_before(high_subs,:),2)], ...
    [mean(1-sub_ChoiceAcc_after(low_subs,:),2); mean(1-sub_ChoiceAcc_after(high_subs,:),2)]]; 
group_names = [repmat({'low'},1,numel(low_subs)), repmat({'high'},1,numel(high_subs))]';
t = table(group_names,anova_prob(:,1),anova_prob(:,2),...
    'VariableNames',{'group','before','after'});
boundary = table(['B' 'A']','VariableNames',{'boundary'});
rm = fitrm(t,'before-after~group','WithinDesign', boundary);
ranovatable = ranova(rm, 'WithinModel','boundary');

[H,P,CI,STATS] = ttest2(mean(sub_ChoiceAcc_before(low_subs,:),2),mean(sub_ChoiceAcc_before(high_subs,:),2))
[H,P,CI,STATS] = ttest2(mean(1-sub_ChoiceAcc_after(low_subs,:),2),mean(1-sub_ChoiceAcc_after(high_subs,:),2))



%% phase (learning vs. transfer) x group (high vs. low) x time (before vs. after)
anova_prob = [[mean(sub_ChoiceAcc_low_before(low_subs,:),2); mean(sub_ChoiceAcc_high_before(high_subs,:),2)], ...
    [mean(1-sub_ChoiceAcc_low_after(low_subs,:),2); mean(1-sub_ChoiceAcc_high_after(high_subs,:),2)], ...
    [mean(sub_ChoiceAcc_before(low_subs,:),2); mean(sub_ChoiceAcc_before(high_subs,:),2)], ...
    [mean(1-sub_ChoiceAcc_after(low_subs,:),2); mean(1-sub_ChoiceAcc_after(high_subs,:),2)]]; 
group_names = [repmat({'low'},1,numel(low_subs)), repmat({'high'},1,numel(high_subs))]';
t = table(group_names,anova_prob(:,1),anova_prob(:,2),anova_prob(:,3),anova_prob(:,4),...
    'VariableNames',{'group','LearingBefore','LearningAfter','TransferBefore', 'TransferAfter'});
within = table(['L' 'L' 'T' 'T']',['B' 'A' 'B' 'A']','VariableNames',{'phase','boundary'});
rm = fitrm(t,'LearingBefore,LearningAfter,TransferBefore,TransferAfter~group','WithinDesign', within);
ranovatable = ranova(rm,'WithinModel','phase*boundary');



%% compare 1~5 trials before rule change with 1 trial after rule change
% accuracy over time (low-volatility)
[tval,adj_p] = comparisons_between_bars(1:6, [sub_ChoiceAcc_low_before(low_subs,:),1-sub_ChoiceAcc_low_after(low_subs,1)])
% accuracy over time (low-volatility)
[tval,adj_p] = comparisons_between_bars(1:6, [sub_ChoiceAcc_high_before(high_subs,:),1-sub_ChoiceAcc_high_after(high_subs,1)])



