% this script replaces MTurk IDs with a random string of characters and numbers
clear all; close all; clc;

addpath(genpath('C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/mturk data'))
files = dir('C:/Users/Tanya Wen/Documents/GitHub/Meta-flexibility/mturk data/experiment*/*.log');


nsubj = numel(files);
for subj = 1:nsubj
    
    % load data from each subject
    data = readtable(files(subj).name,'FileType','text');
    data.workerId = data.subject;
    
    % remove demographic info
    % (age, race, gender, ethnicity, colorbindness, normal vision, neurological disorder)
    try
        fields = {'age','race','gender','ethnicity','color','vision','neuro'};
        data = removevars(data,fields);
        data(end,:) = []; % last row is demographics response
    catch
    end
    
    % write out data
    writetable(data,fullfile(files(subj).folder,files(subj).name),'FileType','text');
    
end

