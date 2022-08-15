clear all; close all; clc;
addpath(genpath('/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/meta-flexibility/Pilots/mturk/short'))
fig_path = '/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/meta-flexibility/manuscript/figures';

exp1results = exp1results_func();
exp2results = exp2results_func();
exp3results = exp3results_func();


phase1_low_after = [exp1results.phase1_low_after;exp2results.phase1_low_after;exp3results.phase1_low_after];
phase1_high_after = [exp1results.phase1_high_after;exp2results.phase1_high_after;exp3results.phase1_high_after];
phase2_low_after = [exp1results.phase2_low_after;exp2results.phase2_low_after;exp3results.phase2_low_after];
phase2_high_after = [exp1results.phase2_high_after;exp2results.phase2_high_after;exp3results.phase2_high_after];

% plot learning rates
% learning
figure('Renderer', 'painters', 'Position', [10 10 400 300]); hold on
t = tiledlayout(1,1,'TileSpacing','compact');
bgAx = axes(t,'XTick',[],'YTick',[],'Box','off');

ax1 = axes(t); % low-volatility group
errorbar(ax1, 1:3, mean(phase1_low_after),...
    std(phase1_low_after)/sqrt(size(phase1_low_after,1)),...
    'o-','MarkerSize',3,'Color',[254, 178, 76]/255,'LineWidth',1.5);
ax1.Box = 'off';
ax1.FontSize = 14;
ax1.YLim = [0 1];
ax1.XLim = [0 4];
xticks([1, 2, 3])
xticklabels({'31', '61', '91'})
xline(ax1,4.5,':');
ax1.Color = 'none';

% high-volatility group
ax3 = axes(t);
ax3.Layout.Tile = 1;
errorbar(ax3, 1:11, mean(phase1_high_after),...
    std(phase1_high_after)/sqrt(size(phase1_high_after,1)),...
    'o-','MarkerSize',3,'Color',[240, 59, 32]/255,'LineWidth',1.5);
ax3.Visible = 'off';
ax3.Box = 'off';
ax3.FontSize = 14;
ax3.YLim = [0 1];
ax3.XLim = [0 12];
ax3.Color = 'none';

ylabel(ax1,'mean accuracy of 1-5 trials after switch')
xlabel(ax1,'learning phase')
set(gcf,'color','w')
print(gcf,fullfile(fig_path,'ChoiceProb_AllExperiments_learning.eps'),'-depsc2','-painters');

% transfer
figure('Renderer', 'painters', 'Position', [10 10 400 300]); hold on
t = tiledlayout(1,1,'TileSpacing','compact');
bgAx = axes(t,'XTick',[],'YTick',[],'Box','off');

ax2 = axes(t);
ax2.Layout.Tile = 1;
errorbar(ax2, 4:8, mean(phase2_low_after),...
    std(phase2_low_after)/sqrt(size(phase2_low_after,1)),...
    'o-','MarkerSize',3,'Color',[254, 178, 76]/255,'LineWidth',1.5);
ax2.YAxis.Visible = 'off';
ax2.Box = 'off';
ax2.FontSize = 14;
ax2.YLim = [0 1];
ax2.XLim = [3 9];
xticks([4,5,6,7,8])
xticklabels({'141', '161', '181', '201', '221'})
ax2.Color = 'none';

ax4 = axes(t);
ax4.Layout.Tile = 1;
errorbar(ax4, 12:16, mean(phase2_high_after),...
    std(phase2_high_after)/sqrt(size(phase1_high_after,1)),...
    'o-','MarkerSize',3,'Color',[240, 59, 32]/255,'LineWidth',1.5);
ax4.YAxis.Visible = 'off';
ax4.Visible = 'off';
ax4.Box = 'off';
ax4.FontSize = 14;
ax4.YLim = [0 1];
ax4.XLim = [11 17];
ax4.Color = 'none';


xlabel(ax2,'transfer phase')
set(gcf,'color','w')
print(gcf,fullfile(fig_path,'ChoiceProb_AllExperiments_transfer.eps'),'-depsc2','-painters');

% main effect of volatility group
[H,P,CI,STATS] = ttest2(mean([phase1_low_after,phase2_low_after],2), mean([phase1_high_after,phase2_high_after],2));
% accuracy over time (low-volatility)
[tval,adj_p] = comparisons_between_bars(1:8, [phase1_low_after,phase2_low_after])
% accuracy over time (high-volatility)
[tval,adj_p] = comparisons_between_bars(1:16, [phase1_high_after,phase2_high_after])

%% functions below

function results = exp1results_func()

files = dir('/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/meta-flexibility/Pilots/mturk/short/version1/pilot2/*.log');
addpath('/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/software/fdr_bh')
fig_path = '/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/meta-flexibility/manuscript/figures';

nsubj = 88;
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
blocks_low = {31:60,61:90,91:120};
blocks_high = {11:20,21:30,31:40,41:50,51:60,61:70,71:80,81:90,91:100,101:110,111:120};
subj_ind = 1;
for subj = 1:nsubj
    
    if ~ismember(subj,bad_subj_list)
        
        if ismember(subj_ind,low_subs)
            
            for block_ind = 1:numel(blocks_low)
                
                blocked_ChoiceAcc_low(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks_low{block_ind});
                
            end
            
            sub_ChoiceAcc_low = squeeze(mean(blocked_ChoiceAcc_low(:,:,1:5),3));
            
        elseif ismember(subj_ind,high_subs)
                
            for block_ind = 1:numel(blocks_high)
                
                blocked_ChoiceAcc_high(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks_high{block_ind});
                
            end
            
            sub_ChoiceAcc_high = squeeze(mean(blocked_ChoiceAcc_high(:,:,1:5),3));
                
        end
            
        subj_ind = subj_ind + 1;
        
        
    end
end

low_mean_ChoiceAcc = mean(sub_ChoiceAcc_low(low_subs,:));
low_se_ChoiceAcc = std(sub_ChoiceAcc_low(low_subs,:))/sqrt(numel(low_subs));
high_mean_ChoiceAcc = mean(sub_ChoiceAcc_high(high_subs,:));
high_se_ChoiceAcc = std(sub_ChoiceAcc_high(high_subs,:))/sqrt(numel(high_subs));


%% divide transfer phase into blocks
blocks = {141:160,161:180,181:200,201:220,221:240};
subj_ind = 1;
for subj = 1:nsubj
    if ~ismember(subj,bad_subj_list)
        
        for block_ind = 1:numel(blocks)
            
            blocked_ChoiceAcc(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks{block_ind});
            
        end
        subj_ind = subj_ind + 1;
        
        sub_ChoiceAcc = squeeze(mean(blocked_ChoiceAcc(:,:,1:5),3));
        
    end
end

mean_ChoiceAcc = mean(sub_ChoiceAcc);
se_ChoiceAcc = std(sub_ChoiceAcc)/sqrt(subj_ind-1);

low_mean_ChoiceAcc = mean(sub_ChoiceAcc(low_subs,:));
low_se_ChoiceAcc = std(sub_ChoiceAcc(low_subs,:))/sqrt(numel(low_subs));
high_mean_ChoiceAcc = mean(sub_ChoiceAcc(high_subs,:));
high_se_ChoiceAcc = std(sub_ChoiceAcc(high_subs,:))/sqrt(numel(high_subs));



%% final outputs

results.phase1_low_after = sub_ChoiceAcc_low(low_subs,:);
results.phase1_high_after = sub_ChoiceAcc_high(high_subs,:);
results.phase2_low_after = sub_ChoiceAcc(low_subs,:); 
results.phase2_high_after = sub_ChoiceAcc(high_subs,:);


end






function results = exp2results_func()

files = dir('/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/meta-flexibility/Pilots/mturk/short/version2/*.log');
addpath('/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/software/fdr_bh')
fig_path = '/Users/tanyawen/Library/CloudStorage/Box-Box/Home Folder tw260/Private/meta-flexibility/manuscript/figures';

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
blocks_low = {31:60,61:90,91:120};
blocks_high = {11:20,21:30,31:40,41:50,51:60,61:70,71:80,81:90,91:100,101:110,111:120};
subj_ind = 1;
for subj = 1:nsubj
    
    if ~ismember(subj,bad_subj_list)
        
        if ismember(subj_ind,low_subs)
            
            for block_ind = 1:numel(blocks_low)
                
                blocked_ChoiceAcc_low(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks_low{block_ind});
                
            end
            
            sub_ChoiceAcc_low = squeeze(mean(blocked_ChoiceAcc_low(:,:,1:5),3));
            
        elseif ismember(subj_ind,high_subs)
                
            for block_ind = 1:numel(blocks_high)
                
                blocked_ChoiceAcc_high(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks_high{block_ind});
                
            end
            
            sub_ChoiceAcc_high = squeeze(mean(blocked_ChoiceAcc_high(:,:,1:5),3));
                
        end
            
        subj_ind = subj_ind + 1;
        
        
    end
end

low_mean_ChoiceAcc = mean(sub_ChoiceAcc_low(low_subs,:));
low_se_ChoiceAcc = std(sub_ChoiceAcc_low(low_subs,:))/sqrt(numel(low_subs));
high_mean_ChoiceAcc = mean(sub_ChoiceAcc_high(high_subs,:));
high_se_ChoiceAcc = std(sub_ChoiceAcc_high(high_subs,:))/sqrt(numel(high_subs));


%% divide transfer phase into blocks
blocks = {141:160,161:180,181:200,201:220,221:240};
subj_ind = 1;
for subj = 1:nsubj
    if ~ismember(subj,bad_subj_list)
        
        for block_ind = 1:numel(blocks)
            
            blocked_ChoiceAcc(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks{block_ind});
            
        end
        subj_ind = subj_ind + 1;
        
        sub_ChoiceAcc = squeeze(mean(blocked_ChoiceAcc(:,:,1:5),3));
        
    end
end

mean_ChoiceAcc = mean(sub_ChoiceAcc);
se_ChoiceAcc = std(sub_ChoiceAcc)/sqrt(subj_ind-1);

low_mean_ChoiceAcc = mean(sub_ChoiceAcc(low_subs,:));
low_se_ChoiceAcc = std(sub_ChoiceAcc(low_subs,:))/sqrt(numel(low_subs));
high_mean_ChoiceAcc = mean(sub_ChoiceAcc(high_subs,:));
high_se_ChoiceAcc = std(sub_ChoiceAcc(high_subs,:))/sqrt(numel(high_subs));


%% final outputs
results.phase1_low_after = sub_ChoiceAcc_low(low_subs,:);
results.phase1_high_after = sub_ChoiceAcc_high(high_subs,:);
results.phase2_low_after = sub_ChoiceAcc(low_subs,:); 
results.phase2_high_after = sub_ChoiceAcc(high_subs,:);


end





function results = exp3results_func()


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
blocks_low = {31:60,61:90,91:120};
blocks_high = {11:20,21:30,31:40,41:50,51:60,61:70,71:80,81:90,91:100,101:110,111:120};
subj_ind = 1;
for subj = 1:nsubj
    
    if ~ismember(subj,bad_subj_list)
        
        if ismember(subj_ind,low_subs)
            
            for block_ind = 1:numel(blocks_low)
                
                blocked_ChoiceAcc_low(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks_low{block_ind});
                
            end
            
            sub_ChoiceAcc_low = squeeze(mean(blocked_ChoiceAcc_low(:,:,1:5),3));
            
        elseif ismember(subj_ind,high_subs)
                
            for block_ind = 1:numel(blocks_high)
                
                blocked_ChoiceAcc_high(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks_high{block_ind});
                
            end
            
            sub_ChoiceAcc_high = squeeze(mean(blocked_ChoiceAcc_high(:,:,1:5),3));
                
        end
            
        subj_ind = subj_ind + 1;
        
        
    end
end

low_mean_ChoiceAcc = mean(sub_ChoiceAcc_low(low_subs,:));
low_se_ChoiceAcc = std(sub_ChoiceAcc_low(low_subs,:))/sqrt(numel(low_subs));
high_mean_ChoiceAcc = mean(sub_ChoiceAcc_high(high_subs,:));
high_se_ChoiceAcc = std(sub_ChoiceAcc_high(high_subs,:))/sqrt(numel(high_subs));


%% divide transfer phase into blocks
blocks = {141:160,161:180,181:200,201:220,221:240};
subj_ind = 1;
for subj = 1:nsubj
    if ~ismember(subj,bad_subj_list)
        
        for block_ind = 1:numel(blocks)
            
            blocked_ChoiceAcc(subj_ind,block_ind,:) = subj_accuracy(subj_ind,blocks{block_ind});
            
        end
        subj_ind = subj_ind + 1;
        
        sub_ChoiceAcc = squeeze(mean(blocked_ChoiceAcc(:,:,1:5),3));
        
    end
end

mean_ChoiceAcc = mean(sub_ChoiceAcc);
se_ChoiceAcc = std(sub_ChoiceAcc)/sqrt(subj_ind-1);

low_mean_ChoiceAcc = mean(sub_ChoiceAcc(low_subs,:));
low_se_ChoiceAcc = std(sub_ChoiceAcc(low_subs,:))/sqrt(numel(low_subs));
high_mean_ChoiceAcc = mean(sub_ChoiceAcc(high_subs,:));
high_se_ChoiceAcc = std(sub_ChoiceAcc(high_subs,:))/sqrt(numel(high_subs));


%% final outputs
results.phase1_low_after = sub_ChoiceAcc_low(low_subs,:);
results.phase1_high_after = sub_ChoiceAcc_high(high_subs,:);
results.phase2_low_after = sub_ChoiceAcc(low_subs,:); 
results.phase2_high_after = sub_ChoiceAcc(high_subs,:);


end
