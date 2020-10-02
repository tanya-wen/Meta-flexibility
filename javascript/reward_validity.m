rewardValidity1 = [zeros(1,24),ones(1,96)];
fileID = fopen('reward_validity_sequence.txt','w');
for i = 1:120
    fprintf(fileID,'%d, ',rewardValidity1(i));
end

rewardValidity2 = [zeros(1,24),ones(1,72)];
for i = 1:96
    fprintf(fileID,'%d, ',rewardValidity2(i));
end