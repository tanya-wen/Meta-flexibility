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
        
        
        %% transfer task analysis
        transfer_ind = [121:240];
        transfer_ind_bins = {121:160,161:200,201:240};
        
        for bin = 1:numel(transfer_ind_bins)
            %% errors and switches
            if isequal(volatility{subj_ind},'low') == 1
                low_Nerrors(low_ind,bin) = sum(ismember(subj_accuracy(subj_ind,transfer_ind_bins{bin}),'false'));
                low_Nswitches(low_ind,bin) = sum(double(ismember(subswitch(subj_ind,transfer_ind_bins{bin}),'switch')));
            elseif isequal(volatility{subj_ind},'high') == 1
                high_Nerrors(high_ind,bin) = sum(ismember(subj_accuracy(subj_ind,transfer_ind_bins{bin}),'false'));
                high_Nswitches(high_ind,bin) = sum(double(ismember(subswitch(subj_ind,transfer_ind_bins{bin}),'switch')));
            end
            
            %% learning rate
            % real errors with negative feedback
            real_errors(subj_ind,:) = ismember(subj_accuracy(subj_ind,transfer_ind_bins{bin}),'false').*ismember(reward_validity(subj_ind,transfer_ind_bins{bin}),'1');
            real_errors_ind{subj_ind,bin} = find(real_errors(subj_ind,:)==1)+120+(bin-1)*20;
            temp = real_errors_ind{subj_ind,bin};
            if bin > 1 % see if the first value in bin is a 1st negative feedback
                prev_bin = ismember(120+(bin-1)*20-1,real_errors_ind{subj_ind,(bin-1)});
            else prev_bin = 0;
            end
            if prev_bin == 1
                first_real_errors_ind{subj_ind,bin} = [120+(bin-1)*20-1,temp(find(diff(real_errors_ind{subj_ind,bin})~=1)+1)];
            else
                first_real_errors_ind{subj_ind,bin} = temp(find(diff(real_errors_ind{subj_ind,bin})~=1)+1);
            end
            if isequal(volatility{subj_ind},'low') == 1
                low_1st_real_errors_switches(low_ind,bin) = sum(double(ismember(subswitch(subj_ind,first_real_errors_ind{subj_ind,bin}),'switch')))/numel(first_real_errors_ind{subj_ind,bin});
            elseif isequal(volatility{subj_ind},'high') == 1
                high_1st_real_errors_switches(high_ind,bin) = sum(double(ismember(subswitch(subj_ind,first_real_errors_ind{subj_ind,bin}),'switch')))/numel(first_real_errors_ind{subj_ind,bin});
            end
            
            % negative feedbacks on correct trials
            invalid_errors(subj_ind,:) = ismember(subj_accuracy(subj_ind,transfer_ind_bins{bin}),'true').*ismember(reward_validity(subj_ind,transfer_ind_bins{bin}),'0');
            invalid_errors_ind{subj_ind,bin} = find(invalid_errors(subj_ind,:)==1);
            temp = invalid_errors_ind{subj_ind,bin};
            if bin > 1 % see if the first value in bin is a 1st negative feedback
                prev_bin = ismember(120+(bin-1)*20-1,invalid_errors_ind{subj_ind,(bin-1)});
            else prev_bin = 0;
            end
            if prev_bin == 1
                first_invalid_errors_ind{subj_ind,bin} = [120+(bin-1)*20-1,temp(find(diff(invalid_errors_ind{subj_ind,bin})~=1)+1)];
            else
                first_invalid_errors_ind{subj_ind,bin} = temp(find(diff(invalid_errors_ind{subj_ind,bin})~=1)+1);
            end
            if isequal(volatility{subj_ind},'low') == 1
                low_1st_invalid_errors_switches(low_ind,bin) = sum(double(ismember(subswitch(subj_ind,first_invalid_errors_ind{subj_ind,bin}),'switch')))/numel(first_invalid_errors_ind{subj_ind,bin});
            elseif isequal(volatility{subj_ind},'high') == 1
                high_1st_invalid_errors_switches(high_ind,bin) = sum(double(ismember(subswitch(subj_ind,first_invalid_errors_ind{subj_ind,bin}),'switch')))/numel(first_invalid_errors_ind{subj_ind,bin});
            end
            
            % negative feedbacks on correct trials
            neg_feedback(subj_ind,:) = (ismember(subj_accuracy(subj_ind,transfer_ind_bins{bin}),'false').*ismember(reward_validity(subj_ind,transfer_ind_bins{bin}),'1').*ismember(subj_accuracy(subj_ind,transfer_ind_bins{bin}),'true')+ismember(reward_validity(subj_ind,transfer_ind_bins{bin}),'0'));
            neg_feedback_ind{subj_ind,bin} = find(neg_feedback(subj_ind,:)==1);
            temp = neg_feedback_ind{subj_ind,bin};
            if bin > 1 % see if the first value in bin is a 1st negative feedback
                prev_bin = ismember(120+(bin-1)*20-1,neg_feedback_ind{subj_ind,(bin-1)});
            else prev_bin = 0;
            end
            if prev_bin == 1
                first_neg_feedback_ind{subj_ind,bin} = [120+(bin-1)*20-1,temp(find(diff(neg_feedback_ind{subj_ind,bin})~=1)+1)];
            else
                first_neg_feedback_ind{subj_ind,bin} = temp(find(diff(neg_feedback_ind{subj_ind,bin})~=1)+1);
            end
            if isequal(volatility{subj_ind},'low') == 1
                low_1st_neg_feedback_switches(low_ind,bin) = sum(double(ismember(subswitch(subj_ind,first_neg_feedback_ind{subj_ind,bin}),'switch')))/numel(first_neg_feedback_ind{subj_ind,bin});
                if bin == numel(transfer_ind_bins)
                low_ind = low_ind+1;
                end
            elseif isequal(volatility{subj_ind},'high') == 1
                high_1st_neg_feedback_switches(high_ind,bin) = sum(double(ismember(subswitch(subj_ind,first_neg_feedback_ind{subj_ind,bin}),'switch')))/numel(first_neg_feedback_ind{subj_ind,bin});
                if bin == numel(transfer_ind_bins)
                high_ind = high_ind+1;
                end
            end
            
        end
        
        subj_ind = subj_ind + 1;
        break
    end
end
% 
% [H,P,CI,STATS] = ttest2(low_Nerrors,high_Nerrors);
% [H,P,CI,STATS] = ttest2(low_Nswitches,high_Nswitches);
% [H,P,CI,STATS] = ttest2(low_1st_real_errors_switches,high_1st_real_errors_switches);
% [H,P,CI,STATS] = ttest2(low_1st_invalid_errors_switches,high_1st_invalid_errors_switches);
% [H,P,CI,STATS] = ttest2(low_1st_neg_feedback_switches,high_1st_neg_feedback_switches);
% 
%% Do ANOVA 
anova_input = [low_1st_neg_feedback_switches;high_1st_neg_feedback_switches]; %rule * switch type 
group = cell(numel(find(ismember(volatility,'low')))+numel(find(ismember(volatility,'high'))),1);
group(1:numel(find(ismember(volatility,'low')))) = {'low'};
group(numel(find(ismember(volatility,'low')))+1:end) = {'high'};
t_anova = table(group,anova_input(:,1),anova_input(:,2),anova_input(:,3),'VariableNames',{'group','t1','t2','t3'});
time_bin = [1:3]';
rm = fitrm(t_anova,'t1-t3 ~ group','WithinDesign',time_bin,'WithinModel','orthogonalcontrasts');
rm.anova
rm.ranova

%%
figure(1); hold on
x = 1:numel(transfer_ind_bins); x = x';
y1 = nanmean(low_1st_neg_feedback_switches)';
dy1 = nanstd(low_1st_neg_feedback_switches)'/sqrt(sum(ismember(volatility,'low'))-1);
%fill([x;flipud(x)],[y1-dy1;flipud(y1+dy1)],[.3 .3 .6],'linestyle','none','FaceAlpha',0.1);
%plot(x,y1,'Color',[.3 .3 .6])
errorbar(x,y1,dy1,'Color',[.3 .3 .6])
y2 = nanmean(high_1st_neg_feedback_switches)';
dy2 = nanstd(high_1st_neg_feedback_switches)'/sqrt(sum(ismember(volatility,'high'))-1);
%fill([x;flipud(x)],[y2-dy2;flipud(y2+dy2)],[.3 .6 .3],'linestyle','none','FaceAlpha',0.1);
% plot(x,y2,'Color',[.3 .6 .3])
errorbar(x,y2,dy2,'Color',[.3 .6 .3])
xlim([0.5 3.5])
ylim([0.05 0.28])
xticks([1,2,3])
xticklabels({'start','middle','end'})
ylabel('% of switches after negative feedback')
legend('low volatility group','high volatility group')
print(gcf,'v1_GroupPlot_binned','-depsc');

