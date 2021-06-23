clear all; close all; clc;

% how likely are people to switch after an error?

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
        
        %% Obtain rules
        rule(subj_ind,:) = data.type(task_ind);
        reward_validity(subj_ind,:) = data.reward_validity(task_ind);
        subj_response(subj_ind,:) = data.response(task_ind);
        subj_accuracy(subj_ind,:) = data.response_acc(task_ind);
        subj_RT(subj_ind,:) = cellfun(@str2double,data.response_time(task_ind));
        subj_RT(subj_RT==0) = NaN;
        % get picked_rule
        answer = data.answer(task_ind);
        response = data.response(task_ind);
        type = data.type;
        for i = 1:numel(task_ind)
            if strcmp(answer{i},response{i}) == 1
                if strcmp(type{i},type{1}) == 1
                    picked_rule{subj_ind,i} = type{1};
                else picked_rule{subj_ind,i} = type{21};
                end
            elseif strcmp(answer{i},response{i}) == 0
                if strcmp(type{i},type{1}) == 1
                    picked_rule{subj_ind,i} = type{21};
                else picked_rule{subj_ind,i} = type{1};
                end
            else picked_rule{subj_ind,i} = 'none';
            end
        end
        
        subj_ind = subj_ind + 1;
        break
    end
end


%% analyze transfer data
%% divide transfer task into blocks
boundary_points = {140,160,180,200,220};
boundary_trials = {137:143,157:163,177:183,197:203,217:223}; 
boundary_int = {137,157,177,197,217};
non_boundary_trials = {124:136,144:156,164:176,184:196,204:216,224:236};
non_boundary_int = {124,144,164,184,204,224};

subj_ind = 1;
for subj = 1:nsubj
    if ~ismember(subj,bad_subj_list)
        
        % boundary trials
        for bound_ind = 1:length(boundary_int)
            
            is_error = find(ismember(subj_accuracy(subj_ind,boundary_trials{bound_ind}),'true').*ismember(reward_validity(subj_ind,boundary_trials{bound_ind}),'0') + ismember(subj_accuracy(subj_ind,boundary_trials{bound_ind}),'false').*ismember(reward_validity(subj_ind,boundary_trials{bound_ind}),'1'));
            
            is_error_resp = picked_rule(subj_ind,boundary_int{bound_ind}+is_error-1);
            after_error_resp = picked_rule(subj_ind,boundary_int{bound_ind}+is_error);
            
            cum = [];
            for i = 1:numel(is_error_resp)
                cum = [cum, ~isequal(is_error_resp{i},after_error_resp{i})];
            end
            bound_switchLikelihood(subj_ind,bound_ind) = mean(cum);
            
        end
        
        % non-boundary trials
        for nbound_ind = 1:length(non_boundary_int)
            
            is_error = find(ismember(subj_accuracy(subj_ind,non_boundary_trials{nbound_ind}),'true').*ismember(reward_validity(subj_ind,non_boundary_trials{nbound_ind}),'0') + ismember(subj_accuracy(subj_ind,non_boundary_trials{nbound_ind}),'false').*ismember(reward_validity(subj_ind,non_boundary_trials{nbound_ind}),'1'));
            
            is_error_resp = picked_rule(subj_ind,non_boundary_int{nbound_ind}+is_error-1);
            after_error_resp = picked_rule(subj_ind,non_boundary_int{nbound_ind}+is_error);
            
            cum = [];
            for i = 1:numel(is_error_resp)
                cum = [cum, ~isequal(is_error_resp{i},after_error_resp{i})];
            end
            nbound_switchLikelihood(subj_ind,nbound_ind) = mean(cum);
            
        end
        
        subj_ind = subj_ind + 1;
        
        
    end
end

sub_bound_switchLikelihood = nanmean(bound_switchLikelihood,2);
sub_nbound_switchLikelihood = nanmean(nbound_switchLikelihood,2);

mean_bound_switchLikelihood = mean(sub_bound_switchLikelihood);
se_bound_switchLikelihood = std(sub_bound_switchLikelihood)/sqrt(subj_ind-1-1);
mean_nbound_switchLikelihood = mean(sub_nbound_switchLikelihood);
se_nbound_switchLikelihood = nanstd(sub_nbound_switchLikelihood)/sqrt(subj_ind-1-1);

low_subs = find(ismember(volatility,'low'));
high_subs = find(ismember(volatility,'high'));

low_mean_bound_switchLikelihood = mean(sub_bound_switchLikelihood(low_subs));
low_se_bound_switchLikelihood = std(sub_bound_switchLikelihood(low_subs))/sqrt(numel(low_subs)-1);
high_mean_bound_switchLikelihood = mean(sub_bound_switchLikelihood(high_subs));
high_se_bound_switchLikelihood = std(sub_bound_switchLikelihood(high_subs))/sqrt(numel(high_subs)-1);
low_mean_nbound_switchLikelihood = mean(sub_nbound_switchLikelihood(low_subs));
low_se_nbound_switchLikelihood = std(sub_nbound_switchLikelihood(low_subs))/sqrt(numel(low_subs)-1);
high_mean_nbound_switchLikelihood = mean(sub_nbound_switchLikelihood(high_subs));
high_se_nbound_switchLikelihood = std(sub_nbound_switchLikelihood(high_subs))/sqrt(numel(high_subs)-1);

% plot learning rate
% all subjects
figure(1)
title('all subjects - transfer phase')
hold on
errorbar([mean_bound_switchLikelihood,mean_nbound_switchLikelihood], [se_bound_switchLikelihood,se_nbound_switchLikelihood], 'k');
xlim([0 3])
xticks([1 2])
xticklabels({'boundary', 'non-boundary'})

figure(2)
title('transfer phase')
hold on
% low-volatility group
errorbar([low_mean_bound_switchLikelihood,low_mean_nbound_switchLikelihood], [low_se_bound_switchLikelihood,low_se_nbound_switchLikelihood], 'b');
% high-volatility group
errorbar([high_mean_bound_switchLikelihood,high_mean_nbound_switchLikelihood], [high_se_bound_switchLikelihood,high_se_nbound_switchLikelihood], 'r');
xlim([0 3])
xticks([1 2])
xticklabels({'boundary', 'non-boundary'})
ylim([0 1])
legend('low-volatility','high-volatility')
ylabel('switch likelihood')
set(gcf,'color','w')
box off

% t-test
[H,P,CI,STATS] = ttest2(sub_bound_switchLikelihood,sub_nbound_switchLikelihood);

% ANOVA
anova_switchLikelihood_transfer = [[sub_bound_switchLikelihood(low_subs);sub_bound_switchLikelihood(high_subs)],...
    [sub_nbound_switchLikelihood(low_subs);sub_nbound_switchLikelihood(high_subs)]]; % (boundary vs. no-boundary) * (low-volatility vs. high-volatility)
group_names = [repmat({'low'},1,numel(low_subs)), repmat({'high'},1,numel(high_subs))]';
t = table(group_names,[sub_bound_switchLikelihood(low_subs);sub_bound_switchLikelihood(high_subs)],[sub_nbound_switchLikelihood(low_subs);sub_nbound_switchLikelihood(high_subs)],...
    'VariableNames',{'group','bound','nbound'});
boundary = table([1 2]','VariableNames',{'boundary'});
rm = fitrm(t,'bound-nbound~group','WithinDesign', boundary);
ranovatable_transfer = ranova(rm);



%% analyze learning phase data
%% divide learning task into blocks
low_boundary_points = {30,60,90};
low_boundary_trials = {27:33,57:63,87:93}; 
low_boundary_int = {27,57,87};
low_non_boundary_trials = {4:26,34:56,64:86,94:116};
low_non_boundary_int = {4,34,64,94};

high_boundary_points = {10,20,30,40,50,60,70,80,90,100,110};
high_boundary_trials = {7:13,17:23,27:33,37:43,47:53,57:63,67:73,77:83,87:93,97:103,107:113};
high_boundary_int = {7,17,27,37,47,57,67,77,87,97,107};
high_non_boundary_trials = {4:6,14:16,24:26,34:36,44:46,54:56,64:66,74:76,84:86,94:96,104:106,114:116};
high_non_boundary_int = {4,14,24,34,44,54,64,74,84,94,104,114};

low_subj_ind = 1;
high_subj_ind = 1;
subj_ind = 1;
for subj = 1:nsubj
    if ~ismember(subj,bad_subj_list)
        
        switch volatility{subj_ind}
            
            %% low volatility group
            case "low"
                % boundary trials
                for low_bound_ind = 1:length(low_boundary_int)
                    
                    is_error = find(ismember(subj_accuracy(subj_ind,low_boundary_trials{low_bound_ind}),'true').*ismember(reward_validity(subj_ind,low_boundary_trials{low_bound_ind}),'0') + ismember(subj_accuracy(subj_ind,low_boundary_trials{low_bound_ind}),'false').*ismember(reward_validity(subj_ind,low_boundary_trials{low_bound_ind}),'1'));
                    
                    is_error_resp = picked_rule(low_subj_ind,low_boundary_int{low_bound_ind}+is_error-1);
                    after_error_resp = picked_rule(low_subj_ind,low_boundary_int{low_bound_ind}+is_error);
                    
                    cum = [];
                    for i = 1:numel(is_error_resp)
                        cum = [cum, ~isequal(is_error_resp{i},after_error_resp{i})];
                    end
                    low_bound_switchLikelihood(low_subj_ind,low_bound_ind) = mean(cum);
                    
                end
                
                % non-boundary trials
                for nbound_ind = 1:length(low_non_boundary_int)
                    
                    is_error = find(ismember(subj_accuracy(subj_ind,low_non_boundary_trials{nbound_ind}),'true').*ismember(reward_validity(subj_ind,low_non_boundary_trials{nbound_ind}),'0') + ismember(subj_accuracy(subj_ind,low_non_boundary_trials{nbound_ind}),'false').*ismember(reward_validity(subj_ind,low_non_boundary_trials{nbound_ind}),'1'));
                    
                    is_error_resp = picked_rule(low_subj_ind,low_non_boundary_int{nbound_ind}+is_error-1);
                    after_error_resp = picked_rule(low_subj_ind,low_non_boundary_int{nbound_ind}+is_error);
                    
                    cum = [];
                    for i = 1:numel(is_error_resp)
                        cum = [cum, ~isequal(is_error_resp{i},after_error_resp{i})];
                    end
                    low_nbound_switchLikelihood(low_subj_ind,nbound_ind) = mean(cum);
                    
                end
                
                low_subj_ind = low_subj_ind + 1;
                
            %% low volatility group
            case "high"
                
                % boundary trials
                for high_bound_ind = 1:length(high_boundary_int)
                    
                    is_error = find(ismember(subj_accuracy(subj_ind,high_boundary_trials{high_bound_ind}),'true').*ismember(reward_validity(subj_ind,high_boundary_trials{high_bound_ind}),'0') + ismember(subj_accuracy(subj_ind,high_boundary_trials{high_bound_ind}),'false').*ismember(reward_validity(subj_ind,high_boundary_trials{high_bound_ind}),'1'));
                    
                    is_error_resp = picked_rule(high_subj_ind,high_boundary_int{high_bound_ind}+is_error-1);
                    after_error_resp = picked_rule(high_subj_ind,high_boundary_int{high_bound_ind}+is_error);
                    
                    cum = [];
                    for i = 1:numel(is_error_resp)
                        cum = [cum, ~isequal(is_error_resp{i},after_error_resp{i})];
                    end
                    high_bound_switchLikelihood(high_subj_ind,high_bound_ind) = mean(cum);
                    
                end
                
                % non-boundary trials
                for nbound_ind = 1:length(high_non_boundary_int)
                    
                    is_error = find(ismember(subj_accuracy(subj_ind,high_non_boundary_trials{nbound_ind}),'true').*ismember(reward_validity(subj_ind,high_non_boundary_trials{nbound_ind}),'0') + ismember(subj_accuracy(subj_ind,high_non_boundary_trials{nbound_ind}),'false').*ismember(reward_validity(subj_ind,high_non_boundary_trials{nbound_ind}),'1'));
                    
                    is_error_resp = picked_rule(high_subj_ind,high_non_boundary_int{nbound_ind}+is_error-1);
                    after_error_resp = picked_rule(high_subj_ind,high_non_boundary_int{nbound_ind}+is_error);
                    
                    cum = [];
                    for i = 1:numel(is_error_resp)
                        cum = [cum, ~isequal(is_error_resp{i},after_error_resp{i})];
                    end
                    high_nbound_switchLikelihood(high_subj_ind,nbound_ind) = mean(cum);
                    
                end
                
                high_subj_ind = high_subj_ind + 1;
        end
        
        
        subj_ind = subj_ind + 1;
    end
end

low_subs = find(ismember(volatility,'low'));
high_subs = find(ismember(volatility,'high'));

low_sub_bound_switchLikelihood = nanmean(low_bound_switchLikelihood,2);
low_sub_nbound_switchLikelihood = nanmean(low_nbound_switchLikelihood,2);
high_sub_bound_switchLikelihood = nanmean(high_bound_switchLikelihood,2);
high_sub_nbound_switchLikelihood = nanmean(high_nbound_switchLikelihood,2);

low_mean_bound_switchLikelihood = mean(low_sub_bound_switchLikelihood);
low_se_bound_switchLikelihood = std(low_sub_bound_switchLikelihood)/sqrt(numel(low_subs)-1);
low_mean_nbound_switchLikelihood = mean(low_sub_nbound_switchLikelihood);
low_se_nbound_switchLikelihood = nanstd(low_sub_nbound_switchLikelihood)/sqrt(numel(low_subs)-1);
high_mean_bound_switchLikelihood = mean(high_sub_bound_switchLikelihood);
high_se_bound_switchLikelihood = std(high_sub_bound_switchLikelihood)/sqrt(numel(high_subs)-1);
high_mean_nbound_switchLikelihood = mean(high_sub_nbound_switchLikelihood);
high_se_nbound_switchLikelihood = nanstd(high_sub_nbound_switchLikelihood)/sqrt(numel(high_subs)-1);

% plot learning rate
figure(3)
title('learning phase')
hold on
% low-volatility group
errorbar([low_mean_bound_switchLikelihood,low_mean_nbound_switchLikelihood], [low_se_bound_switchLikelihood,low_se_nbound_switchLikelihood], 'b');
% high-volatility group
errorbar([high_mean_bound_switchLikelihood,high_mean_nbound_switchLikelihood], [high_se_bound_switchLikelihood,high_se_nbound_switchLikelihood], 'r');
xlim([0 3])
xticks([1 2])
xticklabels({'boundary', 'non-boundary'})
ylim([0 1])
legend('low-volatility','high-volatility')
ylabel('switch likelihood')
set(gcf,'color','w')
box off

% ANOVA
anova_switchLikelihood_learning = [[low_sub_bound_switchLikelihood;high_sub_bound_switchLikelihood],...
    [low_sub_nbound_switchLikelihood;high_sub_nbound_switchLikelihood]]; % (boundary vs. no-boundary) * (low-volatility vs. high-volatility)
group_names = [repmat({'low'},1,numel(low_subs)), repmat({'high'},1,numel(high_subs))]';
t = table(group_names,[low_sub_bound_switchLikelihood;high_sub_bound_switchLikelihood],[low_sub_nbound_switchLikelihood;high_sub_nbound_switchLikelihood],...
    'VariableNames',{'group','bound','nbound'});
boundary = table([1 2]','VariableNames',{'boundary'});
rm = fitrm(t,'bound-nbound~group','WithinDesign', boundary);
ranovatable_learning = ranova(rm);

%% Three-way ANOVA: phase(learning vs. transfer) x group(low vs. high) x position(boundary vs. non-boundary)
t = table(group_names,[low_sub_bound_switchLikelihood;high_sub_bound_switchLikelihood],...
[low_sub_nbound_switchLikelihood;high_sub_nbound_switchLikelihood],...
[sub_bound_switchLikelihood(low_subs);sub_bound_switchLikelihood(high_subs)],...
[sub_nbound_switchLikelihood(low_subs);sub_nbound_switchLikelihood(high_subs)],...
'VariableNames',{'group','bound_l','nbound_l','bound_t','nbound_t'});
within = table(['L' 'L' 'T' 'T']',['B' 'N' 'B' 'N']','VariableNames',{'phase','boundary'});
rm = fitrm(t,'bound_l,nbound_l,bound_t,nbound_t~group','WithinDesign',within);
ranovatable = ranova(rm,'WithinModel','phase*boundary');

% post hoc ttests
% main effect of phase
[H,P,CI,STATS] = ttest([low_sub_bound_switchLikelihood; low_sub_nbound_switchLikelihood; high_sub_bound_switchLikelihood;high_sub_nbound_switchLikelihood],...
    [sub_bound_switchLikelihood(low_subs); sub_nbound_switchLikelihood(low_subs); sub_bound_switchLikelihood(high_subs); sub_nbound_switchLikelihood(high_subs)]);
% main effect of boundary
[H,P,CI,STATS] = ttest([sub_bound_switchLikelihood(low_subs); low_sub_bound_switchLikelihood; sub_bound_switchLikelihood(high_subs); high_sub_bound_switchLikelihood],...
    [sub_nbound_switchLikelihood(low_subs); low_sub_nbound_switchLikelihood; sub_nbound_switchLikelihood(high_subs); high_sub_nbound_switchLikelihood]);
% phase x group interaction
[H,P,CI,STATS] = ttest2([low_sub_bound_switchLikelihood - sub_bound_switchLikelihood(low_subs);
    low_sub_nbound_switchLikelihood - sub_nbound_switchLikelihood(low_subs)], ...
    [high_sub_bound_switchLikelihood - sub_bound_switchLikelihood(high_subs);
    high_sub_nbound_switchLikelihood - sub_nbound_switchLikelihood(high_subs)]);
[H,P,CI,STATS] = ttest2([low_sub_bound_switchLikelihood;low_sub_nbound_switchLikelihood], ...
    [high_sub_bound_switchLikelihood;high_sub_nbound_switchLikelihood])
[H,P,CI,STATS] = ttest2([sub_bound_switchLikelihood(low_subs);sub_nbound_switchLikelihood(low_subs)], ...
    [sub_bound_switchLikelihood(high_subs);sub_nbound_switchLikelihood(high_subs)])

