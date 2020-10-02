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
        subj_accuracy(subj_ind,:) = data.response_acc(task_ind);
        subj_RT(subj_ind,:) = cellfun(@str2double,data.response_time(task_ind));
        subj_RT(subj_RT==0) = NaN;
        for i = 2:numel(task_ind)
            if strcmp(rule(subj_ind,i),rule(subj_ind,i-1)) == 0
                switchtype{subj_ind,i} = 'switch';
            else
                switchtype{subj_ind,i} = 'repeat';
            end
        end
        for i = 2:numel(task_ind)
            if strcmp(subj_accuracy(subj_ind,i),subj_accuracy(subj_ind,i-1)) == 0
                if (ismember(subj_accuracy(subj_ind,i-1),'false').*ismember(reward_validity(subj_ind,i-1),'1')) || (ismember(subj_accuracy(subj_ind,i-1),'true').*ismember(reward_validity(subj_ind,i-1),'0'))
                    subswitch{subj_ind,i} = 'switch';
                else subswitch{subj_ind,i} = 'random error';
                end
            else
                subswitch{subj_ind,i} = 'repeat';
            end
        end
%         error_ind{subj_ind} = find(~cellfun(@isempty,regexp(data.response_acc(task_ind),'false')));
        
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
        %% transfer task analysis
        transfer_ind = [121:240];
        
        %% errors and switches
        if isequal(volatility{subj_ind},'low') == 1
            low_Nerrors(low_ind) = sum(ismember(subj_accuracy(subj_ind,transfer_ind),'false'));
            low_Nswitches(low_ind) = sum(double(ismember(subswitch(subj_ind,transfer_ind),'switch')));
            low_switchRT(low_ind) = nanmedian(subj_RT(subj_ind,ismember(subswitch(subj_ind,transfer_ind),'switch')));
        elseif isequal(volatility{subj_ind},'high') == 1
            high_Nerrors(high_ind) = sum(ismember(subj_accuracy(subj_ind,transfer_ind),'false'));
            high_Nswitches(high_ind) = sum(double(ismember(subswitch(subj_ind,transfer_ind),'switch')));
            high_switchRT(high_ind) = nanmedian(subj_RT(subj_ind,ismember(subswitch(subj_ind,transfer_ind),'switch')));
        end
        
        %% learning rate
        % real errors with negative feedback
        real_errors(subj_ind,:) = ismember(subj_accuracy(subj_ind,transfer_ind),'false').*ismember(reward_validity(subj_ind,transfer_ind),'1');
        real_errors_ind{subj_ind} = find(real_errors(subj_ind,:)==1);
        first_real_errors_ind{subj_ind} = find(diff(real_errors_ind{subj_ind})~=1)+1;
        if isequal(volatility{subj_ind},'low') == 1
            low_1st_real_errors_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,first_real_errors_ind{subj_ind}),'switch')))/numel(first_real_errors_ind{subj_ind});
        elseif isequal(volatility{subj_ind},'high') == 1
            high_1st_treal_errors_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,first_real_errors_ind{subj_ind}),'switch')))/numel(first_real_errors_ind{subj_ind});
        end
            
        % negative feedbacks on correct trials
        invalid_errors(subj_ind,:) = ismember(subj_accuracy(subj_ind,transfer_ind),'true').*ismember(reward_validity(subj_ind,transfer_ind),'0');
        invalid_errors_ind{subj_ind} = find(invalid_errors(subj_ind,:)==1);
        first_invalid_errors_ind{subj_ind} = find(diff(invalid_errors_ind{subj_ind})~=1)+1;
        if isequal(volatility{subj_ind},'low') == 1
            low_1st_invalid_errors_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,first_invalid_errors_ind{subj_ind}),'switch')))/numel(first_invalid_errors_ind{subj_ind});
        elseif isequal(volatility{subj_ind},'high') == 1
            high_1st_invalid_errors_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,first_invalid_errors_ind{subj_ind}),'switch')))/numel(first_invalid_errors_ind{subj_ind});
        end
        
        % all negative feedbacks 
        neg_feedback(subj_ind,:) = (ismember(subj_accuracy(subj_ind,transfer_ind),'false').*ismember(reward_validity(subj_ind,transfer_ind),'1').*ismember(subj_accuracy(subj_ind,transfer_ind),'true')+ismember(reward_validity(subj_ind,transfer_ind),'0'));
        neg_feedback_ind{subj_ind} = find(neg_feedback(subj_ind,:)==1);
        first_neg_feedback_ind{subj_ind} = find(diff(neg_feedback_ind{subj_ind})~=1)+1;
        if isequal(volatility{subj_ind},'low') == 1
            low_1st_neg_feedback_switches(low_ind) = sum(double(ismember(subswitch(subj_ind,first_neg_feedback_ind{subj_ind}),'switch')))/numel(first_neg_feedback_ind{subj_ind});
            low_1stswitchRT(low_ind) = nanmedian(subj_RT(subj_ind,ismember(subswitch(subj_ind,first_neg_feedback_ind{subj_ind}),'switch')));
            low_ind = low_ind+1;
        elseif isequal(volatility{subj_ind},'high') == 1
            high_1st_neg_feedback_switches(high_ind) = sum(double(ismember(subswitch(subj_ind,first_neg_feedback_ind{subj_ind}),'switch')))/numel(first_neg_feedback_ind{subj_ind});
            high_1stswitchRT(high_ind) = nanmedian(subj_RT(subj_ind,ismember(subswitch(subj_ind,first_neg_feedback_ind{subj_ind}),'switch')));
            high_ind = high_ind+1;
        end
        
        subj_ind = subj_ind + 1;
        break
    end
end

[H,P,CI,STATS] = ttest2(low_Nerrors,high_Nerrors);
[H,P,CI,STATS] = ttest2(low_Nswitches,high_Nswitches);
[H,P,CI,STATS] = ttest2(low_switchRT,high_switchRT);
[H,P,CI,STATS] = ttest2(low_1st_real_errors_switches,high_1st_treal_errors_switches);
[H,P,CI,STATS] = ttest2(low_1st_invalid_errors_switches,high_1st_invalid_errors_switches);
[H,P,CI,STATS] = ttest2(low_1st_neg_feedback_switches,high_1st_neg_feedback_switches);
[H,P,CI,STATS] = ttest2(low_1stswitchRT,high_1stswitchRT);


%% plot
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


mean_1st_real_errors_switches = [mean(low_1st_real_errors_switches),mean(high_1st_treal_errors_switches)];
se_1st_real_errors_switches = [std(low_1st_real_errors_switches)/sqrt(numel(low_1st_real_errors_switches)-1),std(high_1st_treal_errors_switches)/sqrt(numel(high_1st_treal_errors_switches)-1)];
figure(3); hold on
bar(mean_1st_real_errors_switches)
errorbar(mean_1st_real_errors_switches,se_1st_real_errors_switches,'.k')
xticks([1,2])
xticklabels({'low volatility group','high volatility group'})
ylabel('% of switches after real error')
set(gcf,'color','w')
[H,P,CI,STATS] = ttest2(low_1st_real_errors_switches,high_1st_treal_errors_switches);
title(sprintf('t = %1.2f, p = %1.2f', STATS.tstat, P));


mean_1st_invalid_errors_switches = [mean(low_1st_invalid_errors_switches),mean(high_1st_invalid_errors_switches)];
se_1st_invalid_errors_switches = [std(low_1st_invalid_errors_switches)/sqrt(numel(low_1st_invalid_errors_switches)-1),std(high_1st_invalid_errors_switches)/sqrt(numel(high_1st_invalid_errors_switches)-1)];
figure(4); hold on
bar(mean_1st_invalid_errors_switches)
errorbar(mean_1st_invalid_errors_switches,se_1st_real_errors_switches,'.k')
xticks([1,2])
xticklabels({'low volatility group','high volatility group'})
ylabel('% of switches after invalid feedback')
set(gcf,'color','w')
[H,P,CI,STATS] = ttest2(low_1st_invalid_errors_switches,high_1st_invalid_errors_switches);
title(sprintf('t = %1.2f, p = %1.2f', STATS.tstat, P));


mean_1st_neg_feedback_switches = [mean(low_1st_neg_feedback_switches),mean(high_1st_neg_feedback_switches)];
se_1st_neg_feedback_switches = [std(low_1st_neg_feedback_switches)/sqrt(numel(low_1st_neg_feedback_switches)-1),std(high_1st_neg_feedback_switches)/sqrt(numel(high_1st_neg_feedback_switches)-1)];
figure(5); hold on
bar(mean_1st_neg_feedback_switches)
errorbar(mean_1st_neg_feedback_switches,se_1st_neg_feedback_switches,'.k')
xticks([1,2])
xticklabels({'low volatility group','high volatility group'})
ylabel('% of switches after negative feedback')
set(gcf,'color','w')
[H,P,CI,STATS] = ttest2(low_1st_neg_feedback_switches,high_1st_neg_feedback_switches);
title(sprintf('t = %1.2f, p = %1.2f', STATS.tstat, P));
ylim([0 0.2])
print(gcf,'v1_GroupPlot','-depsc');

%% sample size / power calculation
g1_mean = mean(low_1st_invalid_errors_switches);
g2_mean = mean(high_1st_invalid_errors_switches);
n1 = numel(low_1st_invalid_errors_switches);
n2 = numel(high_1st_invalid_errors_switches);
pooled_std = sqrt(((n1-1)*std(low_1st_invalid_errors_switches)^2+(n2-1)*std(high_1st_invalid_errors_switches)^2)/(n1+n2-2));


%% plot RT over time
low_subs = find(ismember(volatility,'low'));
high_subs = find(ismember(volatility,'high'));
[H,P,CI,STATS] = ttest2(nanmedian(subj_RT(low_subs,121:240),2),nanmean(subj_RT(high_subs,121:240),2));
mean(subject_total_acc(low_subs))
std(subject_total_acc(low_subs))
mean(subject_total_acc(high_subs))
std(subject_total_acc(high_subs))

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
