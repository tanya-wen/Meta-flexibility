clear all; close all; clc;

files = dir('C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/mturk data/experiment1/*.log');

bad_subj_list = [];
subj_ind = 1; low_ind = 1; high_ind = 1;
for subj = [6,20]
    subject_is_good = 1;
    
    % load data from each subject
    data = readtable(files(subj).name,'FileType','text');
    task_ind = find(~cellfun(@isempty,regexp(data.practice,'false')));
    part1_ind = task_ind(1:numel(task_ind)/2);
    part2_ind = task_ind(numel(task_ind)/2+1:end);
    
    
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
    set(gcf,'position',[1,1,1600,300])
    set(gca,'XTick',0:20:240, 'XTickLabel',0:20:240)
    print(gcf,sprintf('subject%d',subj),'-depsc');
    
    subj_ind = subj_ind + 1;
    
end