fileID = fopen('list.txt','w');

for color = {'Blue','Green','Red','Purple'}
    for shape = {'Circle','Triangle','Plus','Star'}
        for filling = {'Chess','Dots','Stripes','Grid'}
            for numerosity = {'1','2','3','4'}
                fprintf(fileID,'"images/MainExpStimuli/shapes/%s_%s_%s_%s.jpg", ',color{1},shape{1},filling{1},numerosity{1});
            end
        end
    end
end

for race = {'A','C'}
    for gender = {'M','F'}
        for number = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16'}
            fprintf(fileID,'"images/MainExpStimuli/faces/%s_%s_%s.jpg", ',race{1},gender{1},number{1});
        end
    end
end

fclose(fileID);