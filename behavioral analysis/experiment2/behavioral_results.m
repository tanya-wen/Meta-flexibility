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
        transfer_ind = 121:240;
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
        
        subj_ind = subj_ind + 1;
        break
    end
end


%% statistical analysis

% all trials
[H,P,CI,STATS] = ttest2(low_Nerrors,high_Nerrors);
[H,P,CI,STATS] = ttest2(low_Nswitches,high_Nswitches);
[H,P,CI,STATS] = ttest2(low_switchRT,high_switchRT);

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

