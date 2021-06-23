% switch every 10 trials 
seq1 = [repmat([zeros(1,10),ones(1,10)],1,6), repmat([zeros(1,20),ones(1,20)],1,3)];
fileID = fopen('high_volatility_sequence.txt','w');
for i = 1:240
    fprintf(fileID,'%d, ',seq1(i));
end


% switch every 30 trials 
seq2 = [repmat([zeros(1,30),ones(1,30)],1,2), repmat([zeros(1,20),ones(1,20)],1,3)];
fileID = fopen('low_volatility_sequence.txt','w');
for i = 1:240
    fprintf(fileID,'%d, ',seq2(i));
end
