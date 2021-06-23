clear all; clc;
%% switch every 10 trials 
% practice rules
seq1_part1 = [repmat([zeros(1,10),ones(1,10)],1,6)];
fileID = fopen('high_volatility_sequence.txt','w');
for i = 1:120
    fprintf(fileID,'%d, ',seq1_part1(i));
end
% transfer rules
seq1_part2 = [repmat([2*ones(1,20),3*ones(1,20)],1,3)];
for i = 1:120
    fprintf(fileID,'%d, ',seq1_part2(i));
end


%% switch every 30 trials 
% practice rules
seq2_part1 = [repmat([zeros(1,30),ones(1,30)],1,2)];
fileID = fopen('low_volatility_sequence.txt','w');
for i = 1:120
    fprintf(fileID,'%d, ',seq2_part1(i));
end
% transfer rules
seq2_part2 = [repmat([2*ones(1,20),3*ones(1,20)],1,3)];
for i = 1:120
    fprintf(fileID,'%d, ',seq2_part2(i));
end