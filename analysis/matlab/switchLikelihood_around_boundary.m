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


%% analyze transfer data
%% divide transfer task into blocks
boundary_points = {141,161,181,201,221};
boundary_trials = {138:144,158:164,178:184,198:204,218:224};
boundary_int = {138,158,178,198,218};
non_boundary_trials = {125:137,145:157,164:177,185:197,205:217,224:237};
non_boundary_int = {125,145,164,185,205,224};

subj_ind = 1;
for subj = 1:nsubj
    if ~ismember(subj,bad_subj_list)
        
        % boundary trials
        for bound_ind = 1:length(boundary_int)
            
            after_invalid = find(~cellfun(@isempty,regexp(reward_validity(subj_ind,boundary_trials{bound_ind}),'0')));
            before_invalid = after_invalid - 1;
            
            after_invalid_resp = subj_response(subj_ind,boundary_int{bound_ind}+after_invalid);
            before_invalid_resp = subj_response(subj_ind,boundary_int{bound_ind}+before_invalid);
            
            cum = [];
            for i = 1:numel(after_invalid_resp)
                cum = [cum, isequal(after_invalid_resp,before_invalid_resp)];
            end
            bound_switchLikelihood(subj_ind,bound_ind) = mean(cum);
            
        end
        
        % non-boundary trials
        for nbound_ind = 1:length(non_boundary_int)
            
            after_invalid = find(~cellfun(@isempty,regexp(reward_validity(subj_ind,non_boundary_trials{nbound_ind}),'0')));
            before_invalid = after_invalid - 1;
            
            after_invalid_resp = subj_response(subj_ind,non_boundary_int{nbound_ind}+after_invalid);
            before_invalid_resp = subj_response(subj_ind,non_boundary_int{nbound_ind}+before_invalid);
            
            cum = [];
            for i = 1:numel(after_invalid_resp)
                cum = [cum, isequal(after_invalid_resp,before_invalid_resp)];
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
errorbar([mean_bound_switchLikelihood,mean_nbound_switchLikelihood], [se_bound_switchLikelihood,se_nbound_switchLikelihood], 'k');
xlim([0 3])
xticks([1 2])
xticklabels({'boundary', 'non-boundary'})

figure(2)
title('transfer phase')
% low-volatility group
errorbar([low_mean_bound_switchLikelihood,low_mean_nbound_switchLikelihood], [low_se_bound_switchLikelihood,low_se_nbound_switchLikelihood], 'b');
hold on
% high-volatility group
errorbar([high_mean_bound_switchLikelihood,high_mean_nbound_switchLikelihood], [high_se_bound_switchLikelihood,high_se_nbound_switchLikelihood], 'r');
xlim([0 3])
xticks([1 2])
xticklabels({'boundary', 'non-boundary'})
ylim([0 0.6])
legend('low-volatility','high-volatility')
ylabel('% of correct choices')
set(gcf,'color','w')
box off

% t-test
[H,P,CI,STATS] = ttest2(sub_bound_switchLikelihood,sub_nbound_switchLikelihood);

% ANOVA
anova_switchLikelihood_transfer = [[sub_bound_switchLikelihood(low_subs);sub_bound_switchLikelihood(high_subs)],...
    [sub_nbound_switchLikelihood(low_subs);sub_nbound_switchLikelihood(high_subs)]]; % (boundary vs. no-boundary) * (low-volatility vs. high-volatility)
group_names = [repmat({'low'},1,numel(low_subs)), repmat({'high'},1,numel(high_subs)), repmat({'low'},1,numel(low_subs)), repmat({'high'},1,numel(high_subs))]';
t = table(group_names,[anova_switchLikelihood_transfer(:,1);anova_switchLikelihood_transfer(:,2)],[anova_switchLikelihood_transfer(:,1);anova_switchLikelihood_transfer(:,2)],...
    'VariableNames',{'group','bound','nbound'});
boundary = table([1 2]','VariableNames',{'boundary'});
rm = fitrm(t,'bound-nbound~group','WithinDesign', boundary);
ranovatable_transfer = ranova(rm);



%% analyze learning phase data
%% divide learning task into blocks
low_boundary_points = {31,61,91};
low_boundary_trials = {28:34,58:64,88:94};
low_boundary_int = {28,58,88};
low_non_boundary_trials = {5:27,35:57,65:87,95:117};
low_non_boundary_int = {5,35,65,95};

high_boundary_points = {11,21,31,41,51,61,71,81,91,101,111};
high_boundary_trials = {8:14,18:24,28:34,38:44,48:54,58:64,68:74,78:84,88:94,98:104,108:114};
high_boundary_int = {8,18,28,38,48,58,68,78,88,98,108};
high_non_boundary_trials = {5:7,15:17,25:27,35:37,45:47,55:57,65:67,75:77,85:87,95:97,105:107,115:117};
high_non_boundary_int = {5,15,25,35,45,55,65,75,85,95,105,115};

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
                    
                    after_invalid = find(~cellfun(@isempty,regexp(reward_validity(low_subj_ind,low_boundary_trials{low_bound_ind}),'0')));
                    before_invalid = after_invalid - 1;
                    
                    after_invalid_resp = subj_response(low_subj_ind,low_boundary_int{low_bound_ind}+after_invalid);
                    before_invalid_resp = subj_response(low_subj_ind,low_boundary_int{low_bound_ind}+before_invalid);
                    
                    cum = [];
                    for i = 1:numel(after_invalid_resp)
                        cum = [cum, isequal(after_invalid_resp,before_invalid_resp)];
                    end
                    low_bound_switchLikelihood(low_subj_ind,low_bound_ind) = mean(cum);
                    
                end
                
                % non-boundary trials
                for nbound_ind = 1:length(low_non_boundary_int)
                    
                    after_invalid = find(~cellfun(@isempty,regexp(reward_validity(low_subj_ind,low_non_boundary_trials{nbound_ind}),'0')));
                    before_invalid = after_invalid - 1;
                    
                    after_invalid_resp = subj_response(low_subj_ind,low_non_boundary_int{nbound_ind}+after_invalid);
                    before_invalid_resp = subj_response(low_subj_ind,low_non_boundary_int{nbound_ind}+before_invalid);
                    
                    cum = [];
                    for i = 1:numel(after_invalid_resp)
                        cum = [cum, isequal(after_invalid_resp,before_invalid_resp)];
                    end
                    low_nbound_switchLikelihood(low_subj_ind,nbound_ind) = mean(cum);
                    
                end
                
                low_subj_ind = low_subj_ind + 1;
                
            %% low volatility group
            case "high"
                
                % boundary trials
                for high_bound_ind = 1:length(high_boundary_int)
                    
                    after_invalid = find(~cellfun(@isempty,regexp(reward_validity(high_subj_ind,high_boundary_trials{high_bound_ind}),'0')));
                    before_invalid = after_invalid - 1;
                    
                    after_invalid_resp = subj_response(high_subj_ind,high_boundary_int{high_bound_ind}+after_invalid);
                    before_invalid_resp = subj_response(high_subj_ind,high_boundary_int{high_bound_ind}+before_invalid);
                    
                    cum = [];
                    for i = 1:numel(after_invalid_resp)
                        cum = [cum, isequal(after_invalid_resp,before_invalid_resp)];
                    end
                    high_bound_switchLikelihood(high_subj_ind,high_bound_ind) = mean(cum);
                    
                end
                
                % non-boundary trials
                for nbound_ind = 1:length(high_non_boundary_int)
                    
                    after_invalid = find(~cellfun(@isempty,regexp(reward_validity(high_subj_ind,high_non_boundary_trials{nbound_ind}),'0')));
                    before_invalid = after_invalid - 1;
                    
                    after_invalid_resp = subj_response(high_subj_ind,high_non_boundary_int{nbound_ind}+after_invalid);
                    before_invalid_resp = subj_response(high_subj_ind,high_non_boundary_int{nbound_ind}+before_invalid);
                    
                    cum = [];
                    for i = 1:numel(after_invalid_resp)
                        cum = [cum, isequal(after_invalid_resp,before_invalid_resp)];
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
% low-volatility group
errorbar([low_mean_bound_switchLikelihood,low_mean_nbound_switchLikelihood], [low_se_bound_switchLikelihood,low_se_nbound_switchLikelihood], 'b');
hold on
% high-volatility group
errorbar([high_mean_bound_switchLikelihood,high_mean_nbound_switchLikelihood], [high_se_bound_switchLikelihood,high_se_nbound_switchLikelihood], 'r');
xlim([0 3])
xticks([1 2])
xticklabels({'boundary', 'non-boundary'})
ylim([0 0.6])
legend('low-volatility','high-volatility')
ylabel('% of correct choices')
set(gcf,'color','w')
box off

% ANOVA
anova_switchLikelihood_learning = [[low_sub_bound_switchLikelihood;high_sub_bound_switchLikelihood],...
    [low_sub_nbound_switchLikelihood;high_sub_nbound_switchLikelihood]]; % (boundary vs. no-boundary) * (low-volatility vs. high-volatility)
group_names = [repmat({'low'},1,numel(low_subs)), repmat({'high'},1,numel(high_subs)), repmat({'low'},1,numel(low_subs)), repmat({'high'},1,numel(high_subs))]';
t = table(group_names,[anova_switchLikelihood_learning(:,1);anova_switchLikelihood_learning(:,2)],[anova_switchLikelihood_learning(:,1);anova_switchLikelihood_learning(:,2)],...
    'VariableNames',{'group','bound','nbound'});
boundary = table([1 2]','VariableNames',{'boundary'});
rm = fitrm(t,'bound-nbound~group','WithinDesign', boundary);
ranovatable_learning = ranova(rm);

%% Three-way ANOVA: phase(learning vs. transfer) x group(low vs. high) x position(boundary vs. non-boundary)
t = table(group_names,[anova_switchLikelihood_learning(:,1);anova_switchLikelihood_learning(:,2)],[anova_switchLikelihood_learning(:,1);anova_switchLikelihood_learning(:,2)],...
[anova_switchLikelihood_transfer(:,1);anova_switchLikelihood_transfer(:,2)],[anova_switchLikelihood_transfer(:,1);anova_switchLikelihood_transfer(:,2)],...
'VariableNames',{'group','bound_l','nbound_l','bound_t','nbound_t'});
within = table(['L' 'L' 'T' 'T']',['B' 'N' 'B' 'N']','VariableNames',{'phase','boundary'});
rm = fitrm(t,'bound_l,nbound_l,bound_t,nbound_t~group','WithinDesign',within);
ranovatable = ranova(rm,'WithinModel','phase*boundary');

