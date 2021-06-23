fileID = fopen('list.txt','w');
for color = {'Blue','Green','Red','Purple'}
    for shape = {'Circle','Triangle','Plus','Star'}
        for filling = {'Chess','Dots','Wave','Grid'}
            for numerosity = {'1','2','3','4'}
                fprintf(fileID,'"images/MainExpStimuli/%s_%s_%s_%s.jpg", ',color{1},shape{1},filling{1},numerosity{1});
            end
        end
    end
end
fclose(fileID);