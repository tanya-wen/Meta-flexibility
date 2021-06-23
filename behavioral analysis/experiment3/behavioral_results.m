clear all; close all; clc;

files = dir('C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/mturk data/experiment3/*.log');

nsubj = 101;
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
        
        %% Obtain rules
        rule(subj_ind,:) = data.type(task_ind);
        reward_validity(subj_ind,:) = data.reward_validity(task_ind);
        subj_accuracy(subj_ind,:) = data.response_acc(task_ind);
        subj_RT(subj_ind,:) = cellfun(@str2double,data.response_time(task_ind));
        subj_RT(subj_RT==0) = NaN;
        
        %% get picked_rule
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
        

        %% get switch vs. repeat
        subswitch{subj_ind,1} = 'first';
        for i = 2:numel(task_ind)
            if strcmp(picked_rule{subj_ind,i},picked_rule{subj_ind,i-1}) == 0
                subswitch{subj_ind,i} = 'switch';
            else
                subswitch{subj_ind,i} = 'repeat';
            end
        end
        
        
        %% plot results
        figure(subj_ind);
        rule_yaxis = ~cellfun(@isempty,(regexp(rule(subj_ind,:),rule{subj_ind,1})));
        plot(1:240,rule_yaxis,'k')
        ylim([-1,2])
        hold on
        for x = 1:240
            plot(x,abs(double(isequal(subj_accuracy{subj_ind,x},'true'))-double(~isequal(rule{subj_ind,x},rule{subj_ind,1}))),...
                'o','MarkerEdgeColor',[0,0,0],'MarkerFaceColor',...
                1-isequal(double(isequal(subj_accuracy{subj_ind,x},'true')),str2double(reward_validity{subj_ind,x})).*[1,1,1]);
        end
        close;
        

        %% errors and switches
        if isequal(volatility{subj_ind},'low') == 1
            low_Nerrors(low_ind) = sum(ismember(subj_accuracy(subj_ind,:),'false'));
            low_ACC(low_ind) = sum(ismember(subj_accuracy(subj_ind,:),'true'))/240;
            low_ACC_learning(low_ind) = sum(ismember(subj_accuracy(subj_ind,1:120),'true'))/120;
            low_ACC_transfer(low_ind) = sum(ismember(subj_accuracy(subj_ind,121:240),'true'))/120;
            low_Nswitches(low_ind) = sum(double(ismember(subswitch(subj_ind,:),'switch')));
            low_switchRT(low_ind) = nanmedian(subj_RT(subj_ind,ismember(subswitch(subj_ind,:),'switch')));
        elseif isequal(volatility{subj_ind},'high') == 1
            high_Nerrors(high_ind) = sum(ismember(subj_accuracy(subj_ind,:),'false'));
            high_ACC(high_ind) = sum(ismember(subj_accuracy(subj_ind,:),'true'))/240;
            high_ACC_learning(high_ind) = sum(ismember(subj_accuracy(subj_ind,1:120),'true'))/120;
            high_ACC_transfer(high_ind) = sum(ismember(subj_accuracy(subj_ind,121:240),'true'))/120;
            high_Nswitches(high_ind) = sum(double(ismember(subswitch(subj_ind,:),'switch')));
            high_switchRT(high_ind) = nanmedian(subj_RT(subj_ind,ismember(subswitch(subj_ind,:),'switch')));
        end
        
        %% learning rate
        transfer_ind_bins = {121:160,161:200,201:240};
        %% real errors with negative feedback
        real_errors_ind{subj_ind} = find(ismember(subj_accuracy(subj_ind,:),'false').*ismember(reward_validity(subj_ind,:),'1'));
        first_real_errors_ind{subj_ind} = real_errors_ind{subj_ind}(find(diff(real_errors_ind{subj_ind})~=1)+1) + 1; % +1 is because we want to see if people switched AFTER an error
        if ismember(241,first_real_errors_ind{subj_ind})
            first_real_errors_ind{subj_ind}(end) = [];
        end
        if isequal(volatility{subj_ind},'low') == 1
            % all trials
            low_1st_real_errors_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,first_real_errors_ind{subj_ind}),'switch')))/numel(first_real_errors_ind{subj_ind});
            % learning phase
            learning_1st_real_errors_ind{subj_ind} = first_real_errors_ind{subj_ind}(first_real_errors_ind{subj_ind} <= 120);
            learning_low_1st_real_errors_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,learning_1st_real_errors_ind{subj_ind}),'switch')))/numel(learning_1st_real_errors_ind{subj_ind}); 
            % transfer phase
            transfer_1st_real_errors_ind{subj_ind} = first_real_errors_ind{subj_ind}(first_real_errors_ind{subj_ind} > 120);
            transfer_low_1st_real_errors_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,transfer_1st_real_errors_ind{subj_ind}),'switch')))/numel(transfer_1st_real_errors_ind{subj_ind});
            % transfer binned results
            for bin = 1:numel(transfer_ind_bins)
                transfer_1st_real_errors_bin{subj_ind,bin} = intersect(first_real_errors_ind{subj_ind}, transfer_ind_bins{bin});
                transfer_low_1st_real_errors_switches_bin(low_ind,bin) = sum(double(ismember(subswitch(subj_ind,transfer_1st_real_errors_bin{subj_ind,bin}),'switch')))/numel(transfer_1st_real_errors_bin{subj_ind,bin});
            end
        elseif isequal(volatility{subj_ind},'high') == 1
            % all trials
            high_1st_real_errors_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,first_real_errors_ind{subj_ind}),'switch')))/numel(first_real_errors_ind{subj_ind});
            % learning phase
            learning_1st_real_errors_ind{subj_ind} = first_real_errors_ind{subj_ind}(first_real_errors_ind{subj_ind} <= 120);
            learning_high_1st_real_errors_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,learning_1st_real_errors_ind{subj_ind}),'switch')))/numel(learning_1st_real_errors_ind{subj_ind});
            % transfer phase
            transfer_1st_real_errors_ind{subj_ind} = first_real_errors_ind{subj_ind}(first_real_errors_ind{subj_ind} > 120);
            transfer_high_1st_real_errors_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,transfer_1st_real_errors_ind{subj_ind}),'switch')))/numel(transfer_1st_real_errors_ind{subj_ind});
            % transfer binned results
            for bin = 1:numel(transfer_ind_bins)
                transfer_1st_real_errors_bin{subj_ind,bin} = intersect(first_real_errors_ind{subj_ind}, transfer_ind_bins{bin});
                transfer_high_1st_real_errors_switches_bin(high_ind,bin) = sum(double(ismember(subswitch(subj_ind,transfer_1st_real_errors_bin{subj_ind,bin}),'switch')))/numel(transfer_1st_real_errors_bin{subj_ind,bin});
            end
        end
            
        %% negative feedbacks on correct trials
        invalid_errors_ind{subj_ind} = find(ismember(subj_accuracy(subj_ind,:),'true').*ismember(reward_validity(subj_ind,:),'0'));
        first_invalid_errors_ind{subj_ind} = invalid_errors_ind{subj_ind}(find(diff(invalid_errors_ind{subj_ind})~=1)+1) + 1; % +1 is because we want to see if people switched AFTER an error
        if ismember(241,first_invalid_errors_ind{subj_ind})
            first_invalid_errors_ind{subj_ind}(end) = [];
        end
        if isequal(volatility{subj_ind},'low') == 1
            % all trials
            low_1st_invalid_errors_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,first_invalid_errors_ind{subj_ind}),'switch')))/numel(first_invalid_errors_ind{subj_ind});
            % learning phase
            learning_1st_invalid_errors_ind{subj_ind} = first_invalid_errors_ind{subj_ind}(first_invalid_errors_ind{subj_ind} <= 120);
            learning_low_1st_invalid_errors_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,learning_1st_invalid_errors_ind{subj_ind}),'switch')))/numel(learning_1st_invalid_errors_ind{subj_ind});
            % transfer phase
            transfer_1st_invalid_errors_ind{subj_ind} = first_invalid_errors_ind{subj_ind}(first_invalid_errors_ind{subj_ind} > 120);
            transfer_low_1st_invalid_errors_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,transfer_1st_invalid_errors_ind{subj_ind}),'switch')))/numel(transfer_1st_invalid_errors_ind{subj_ind});
            % transfer binned results
            for bin = 1:numel(transfer_ind_bins)
                transfer_1st_invalid_errors_bin{subj_ind,bin} = intersect(first_invalid_errors_ind{subj_ind}, transfer_ind_bins{bin});
                transfer_low_1st_invalid_errors_switches_bin(low_ind,bin) = sum(double(ismember(subswitch(subj_ind,transfer_1st_invalid_errors_bin{subj_ind,bin}),'switch')))/numel(transfer_1st_invalid_errors_bin{subj_ind,bin});
            end
        elseif isequal(volatility{subj_ind},'high') == 1
            % all trials
            high_1st_invalid_errors_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,first_invalid_errors_ind{subj_ind}),'switch')))/numel(first_invalid_errors_ind{subj_ind});
            % learning phase
            learning_1st_invalid_errors_ind{subj_ind} = first_invalid_errors_ind{subj_ind}(first_invalid_errors_ind{subj_ind} <= 120);
            learning_high_1st_invalid_errors_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,learning_1st_invalid_errors_ind{subj_ind}),'switch')))/numel(learning_1st_invalid_errors_ind{subj_ind});
            % transfer phase
            transfer_1st_invalid_errors_ind{subj_ind} = first_invalid_errors_ind{subj_ind}(first_invalid_errors_ind{subj_ind} > 120);
            transfer_high_1st_invalid_errors_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,transfer_1st_invalid_errors_ind{subj_ind}),'switch')))/numel(transfer_1st_invalid_errors_ind{subj_ind});
            % transfer binned results
            for bin = 1:numel(transfer_ind_bins)
                transfer_1st_invalid_errors_bin{subj_ind,bin} = intersect(first_invalid_errors_ind{subj_ind}, transfer_ind_bins{bin});
                transfer_high_1st_invalid_errors_switches_bin(high_ind,bin) = sum(double(ismember(subswitch(subj_ind,transfer_1st_invalid_errors_bin{subj_ind,bin}),'switch')))/numel(transfer_1st_invalid_errors_bin{subj_ind,bin});
            end
        end
        
        %% all negative feedbacks 
        neg_feedback_ind{subj_ind} = find((ismember(subj_accuracy(subj_ind,:),'false').*ismember(reward_validity(subj_ind,:),'1')) + (ismember(subj_accuracy(subj_ind,:),'true').*ismember(reward_validity(subj_ind,:),'0')));
        first_neg_feedback_ind{subj_ind} = neg_feedback_ind{subj_ind}(find(diff(neg_feedback_ind{subj_ind})~=1)+1) + 1; % +1 is because we want to see if people switched AFTER an error
        if ismember(241,first_neg_feedback_ind{subj_ind})
            first_neg_feedback_ind{subj_ind}(end) = [];
        end
        if isequal(volatility{subj_ind},'low') == 1
            % all trials
            low_1st_neg_feedback_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,first_neg_feedback_ind{subj_ind}),'switch')))/numel(first_neg_feedback_ind{subj_ind});
            % learning phase
            learning_1st_neg_feedback_ind{subj_ind} = first_neg_feedback_ind{subj_ind}(first_neg_feedback_ind{subj_ind} <= 120);
            learning_low_1st_neg_feedback_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,learning_1st_neg_feedback_ind{subj_ind}),'switch')))/numel(learning_1st_neg_feedback_ind{subj_ind});
            % transfer phase
            transfer_1st_neg_feedback_ind{subj_ind} = first_neg_feedback_ind{subj_ind}(first_neg_feedback_ind{subj_ind} > 120);
            transfer_low_1st_neg_feedback_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,transfer_1st_neg_feedback_ind{subj_ind}),'switch')))/numel(transfer_1st_neg_feedback_ind{subj_ind});
            % transfer binned results
            for bin = 1:numel(transfer_ind_bins)
                transfer_1st_neg_feedback_bin{subj_ind,bin} = intersect(first_neg_feedback_ind{subj_ind}, transfer_ind_bins{bin});
                transfer_low_1st_neg_feedback_switches_bin(low_ind,bin) = sum(double(ismember(subswitch(subj_ind,transfer_1st_neg_feedback_bin{subj_ind,bin}),'switch')))/numel(transfer_1st_neg_feedback_bin{subj_ind,bin});
            end
            
            low_ind = low_ind+1;
        elseif isequal(volatility{subj_ind},'high') == 1
            % all trials
            high_1st_neg_feedback_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,first_neg_feedback_ind{subj_ind}),'switch')))/numel(first_neg_feedback_ind{subj_ind});
            % learning phase
            learning_1st_neg_feedback_ind{subj_ind} = first_neg_feedback_ind{subj_ind}(first_neg_feedback_ind{subj_ind} <= 120);
            learning_high_1st_neg_feedback_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,learning_1st_neg_feedback_ind{subj_ind}),'switch')))/numel(learning_1st_neg_feedback_ind{subj_ind});
            % transfer phase
            transfer_1st_neg_feedback_ind{subj_ind} = first_neg_feedback_ind{subj_ind}(first_neg_feedback_ind{subj_ind} > 120);
            transfer_high_1st_neg_feedback_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,transfer_1st_neg_feedback_ind{subj_ind}),'switch')))/numel(transfer_1st_neg_feedback_ind{subj_ind});
            % transfer binned results
            for bin = 1:numel(transfer_ind_bins)
                transfer_1st_neg_feedback_bin{subj_ind,bin} = intersect(first_neg_feedback_ind{subj_ind}, transfer_ind_bins{bin});
                transfer_high_1st_neg_feedback_switches_bin(high_ind,bin) = sum(double(ismember(subswitch(subj_ind,transfer_1st_neg_feedback_bin{subj_ind,bin}),'switch')))/numel(transfer_1st_neg_feedback_bin{subj_ind,bin});
            end
            
            high_ind = high_ind+1;
        end
        
        subj_ind = subj_ind + 1;
        break
    end
end


%% statistical analysis

% all trials
[H,P,CI,STATS] = ttest2(low_Nerrors,high_Nerrors);
[H,P,CI,STATS] = ttest2(low_Nswitches,high_Nswitches);
[H,P,CI,STATS] = ttest2(low_switchRT,high_switchRT);
% transfer phase 
[H,P,CI,STATS] = ttest2(transfer_low_1st_real_errors_switches,transfer_high_1st_real_errors_switches);
[H,P,CI,STATS] = ttest2(transfer_low_1st_invalid_errors_switches,transfer_high_1st_invalid_errors_switches);
[H,P,CI,STATS] = ttest2(transfer_low_1st_neg_feedback_switches,transfer_high_1st_neg_feedback_switches);

%% plot RT over time
low_subs = find(ismember(volatility,'low'));
high_subs = find(ismember(volatility,'high'));
[H,P,CI,STATS] = ttest2(nanmedian(subj_RT(low_subs,121:240),2),nanmean(subj_RT(high_subs,121:240),2));
mean(low_ACC)  
std(low_ACC)
mean(high_ACC)
std(high_ACC)
[H,P,CI,STATS] = ttest2(low_ACC,high_ACC)
[H,P,CI,STATS] = ttest2([low_ACC_learning,high_ACC_learning],[low_ACC_transfer,high_ACC_transfer])
[H,P,CI,STATS] = ttest2(low_ACC_learning,high_ACC_learning)
[H,P,CI,STATS] = ttest2(low_ACC_transfer,high_ACC_transfer)
%anova
anova_acc = [[low_ACC_learning'; high_ACC_learning'], ...
    [low_ACC_transfer'; high_ACC_transfer']];
group_names = [repmat({'low'},1,numel(low_subs)), repmat({'high'},1,numel(high_subs))]';
t_acc = table(group_names, [low_ACC_learning'; high_ACC_learning'], ...
    [low_ACC_transfer'; high_ACC_transfer'],'VariableNames',{'group' 'learning','transfer'});
phase = table([1 2]','VariableNames',{'phase'});
rm_acc = fitrm(t_acc,'learning-transfer~group','WithinDesign',phase);
ranovatable_acc = ranova(rm_acc);



figure(99); hold on
x = 1:240; x = x';
y1 = nanmean(subj_RT(low_subs,:))';
dy1 = nanstd(subj_RT(low_subs,:))'/sqrt(sum(ismember(volatility,'low'))-1);
fill([x;flipud(x)],[y1-dy1;flipud(y1+dy1)],[.3 .3 .6],'linestyle','none','FaceAlpha',0.1);
plot(x,y1,'Color',[.3 .3 .6])
y2 = nanmean(subj_RT(high_subs,:))';
dy2 = nanstd(subj_RT(high_subs,:))'/sqrt(sum(ismember(volatility,'high'))-1);
fill([x;flipud(x)],[y2-dy2;flipud(y2+dy2)],[.3 .6 .3],'linestyle','none','FaceAlpha',0.1);
plot(x,y2,'Color',[.3 .6 .3])


%% plot entire transfer phase
mean_Nerrors = [mean(low_Nerrors),mean(high_Nerrors)];
se_Nerrors = [std(low_Nerrors)/sqrt(numel(low_Nerrors)-1),std(high_Nerrors)/sqrt(numel(high_Nerrors)-1)];
figure(1); hold on
bar(mean_Nerrors)
errorbar(mean_Nerrors,se_Nerrors,'.k')
xticks([1,2])
xticklabels({'low volatility group','high volatility group'})
ylabel('numer of incorrect responses')
set(gcf,'color','w')
[H,P,CI,STATS] = ttest2(low_Nerrors,high_Nerrors);
title(sprintf('t = %1.2f, p = %1.2f', STATS.tstat, P));


mean_Nswitches = [mean(low_Nswitches),mean(high_Nswitches)];
se_Nswitches = [std(low_Nswitches)/sqrt(numel(low_Nswitches)-1),std(high_Nswitches)/sqrt(numel(high_Nswitches)-1)];
figure(2); hold on
bar(mean_Nswitches)
errorbar(mean_Nswitches,se_Nswitches,'.k')
xticks([1,2])
xticklabels({'low volatility group','high volatility group'})
ylabel('numer of switches')
set(gcf,'color','w')
[H,P,CI,STATS] = ttest2(low_Nswitches,high_Nswitches);
title(sprintf('t = %1.2f, p = %1.2f', STATS.tstat, P));


mean_1st_real_errors_switches = [mean(transfer_low_1st_real_errors_switches),mean(transfer_high_1st_real_errors_switches)];
se_1st_real_errors_switches = [std(transfer_low_1st_real_errors_switches)/sqrt(numel(transfer_low_1st_real_errors_switches)-1),std(transfer_high_1st_real_errors_switches)/sqrt(numel(transfer_high_1st_real_errors_switches)-1)];
figure(3); hold on
bar(mean_1st_real_errors_switches)
errorbar(mean_1st_real_errors_switches,se_1st_real_errors_switches,'.k')
xticks([1,2])
xticklabels({'low volatility group','high volatility group'})
ylabel('% of switches after real error')
set(gcf,'color','w')
[H,P,CI,STATS] = ttest2(transfer_low_1st_real_errors_switches,transfer_high_1st_real_errors_switches);
title(sprintf('t = %1.2f, p = %1.2f', STATS.tstat, P));


mean_1st_invalid_errors_switches = [mean(transfer_low_1st_invalid_errors_switches),mean(transfer_high_1st_invalid_errors_switches)];
se_1st_invalid_errors_switches = [std(transfer_low_1st_invalid_errors_switches)/sqrt(numel(transfer_low_1st_invalid_errors_switches)-1),std(transfer_high_1st_invalid_errors_switches)/sqrt(numel(transfer_high_1st_invalid_errors_switches)-1)];
figure(4); hold on
bar(mean_1st_invalid_errors_switches)
errorbar(mean_1st_invalid_errors_switches,se_1st_real_errors_switches,'.k')
xticks([1,2])
xticklabels({'low volatility group','high volatility group'})
ylabel('% of switches after invalid feedback')
set(gcf,'color','w')
[H,P,CI,STATS] = ttest2(transfer_low_1st_invalid_errors_switches,transfer_high_1st_invalid_errors_switches);
title(sprintf('t = %1.2f, p = %1.2f', STATS.tstat, P));


mean_1st_neg_feedback_switches = [mean(transfer_low_1st_neg_feedback_switches),mean(transfer_high_1st_neg_feedback_switches)];
se_1st_neg_feedback_switches = [std(transfer_low_1st_neg_feedback_switches)/sqrt(numel(transfer_low_1st_neg_feedback_switches)-1),std(transfer_high_1st_neg_feedback_switches)/sqrt(numel(transfer_high_1st_neg_feedback_switches)-1)];
figure(5); hold on
bar(mean_1st_neg_feedback_switches)
errorbar(mean_1st_neg_feedback_switches,se_1st_neg_feedback_switches,'.k')
xticks([1,2])
xticklabels({'low volatility group','high volatility group'})
ylabel('% of switches after negative feedback')
set(gcf,'color','w')
[H,P,CI,STATS] = ttest2(transfer_low_1st_neg_feedback_switches,transfer_high_1st_neg_feedback_switches);
title(sprintf('t = %1.2f, p = %1.2f', STATS.tstat, P));
ylim([0 0.5])
print(gcf,'v1_GroupPlot','-depsc');

%% Do ANOVA (group x time bin)
anova_input = [transfer_low_1st_neg_feedback_switches_bin;transfer_high_1st_neg_feedback_switches_bin]; 
group = cell(numel(find(ismember(volatility,'low')))+numel(find(ismember(volatility,'high'))),1);
group(1:numel(find(ismember(volatility,'low')))) = {'low'};
group(numel(find(ismember(volatility,'low')))+1:end) = {'high'};
t_anova = table(group,anova_input(:,1),anova_input(:,2),anova_input(:,3),'VariableNames',{'group','t1','t2','t3'});
time_bin = [1:3]';
rm = fitrm(t_anova,'t1-t3 ~ group','WithinDesign',time_bin,'WithinModel','orthogonalcontrasts');
rm.anova
rm.ranova

%% plot transfer phase time bins
figure(100); hold on
x = 1:numel(transfer_ind_bins); x = x';
y1 = nanmean(transfer_low_1st_neg_feedback_switches_bin)';
dy1 = nanstd(transfer_low_1st_neg_feedback_switches_bin)'/sqrt(sum(ismember(volatility,'low'))-1);
%fill([x;flipud(x)],[y1-dy1;flipud(y1+dy1)],[.3 .3 .6],'linestyle','none','FaceAlpha',0.1);
%plot(x,y1,'Color',[.3 .3 .6])
errorbar(x,y1,dy1,'Color',[.3 .3 .6])
y2 = nanmean(transfer_high_1st_neg_feedback_switches_bin)';
dy2 = nanstd(transfer_high_1st_neg_feedback_switches_bin)'/sqrt(sum(ismember(volatility,'high'))-1);
%fill([x;flipud(x)],[y2-dy2;flipud(y2+dy2)],[.3 .6 .3],'linestyle','none','FaceAlpha',0.1);
% plot(x,y2,'Color',[.3 .6 .3])
errorbar(x,y2,dy2,'Color',[.3 .6 .3])
xlim([0.5 3.5])
ylim([0.2 0.45])
xticks([1,2,3])
xticklabels({'start','middle','end'})
ylabel('% of switches after negative feedback')
legend('low volatility group','high volatility group')
print(gcf,'v1_GroupPlot_binned','-depsc');


%% sample size / power calculation
g1_mean = mean(low_1st_invalid_errors_switches);
g2_mean = mean(high_1st_invalid_errors_switches);
n1 = numel(low_1st_invalid_errors_switches);
n2 = numel(high_1st_invalid_errors_switches);
pooled_std = sqrt(((n1-1)*std(low_1st_invalid_errors_switches)^2+(n2-1)*std(high_1st_invalid_errors_switches)^2)/(n1+n2-2));



