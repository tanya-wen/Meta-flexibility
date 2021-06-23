addpath(genpath('C:/Users/Tanya Wen/Box/Home Folder tw260/Private/meta-flexibility/javascript code/version4/images/MainExpStimuli/New folder'));
face_list = dir(fullfile('C:/Users/Tanya Wen/Box/Home Folder tw260/Private/meta-flexibility/javascript code/version4/images/MainExpStimuli/New folder','*.jpg'));

for i = 1:numel(face_list)
    
    img_orig = imread(face_list(i).name);
    img_resize = imresize(img_orig, [500, 712]);
    img_new = img_resize;
    img_new(:,1:106,:) = []; img_new(:,end-106:end,:) = [];
    imwrite(img_new,sprintf('C:/Users/Tanya Wen/Box/Home Folder tw260/Private/meta-flexibility/javascript code/version4/images/MainExpStimuli/New folder/%s',face_list(i).name));
    
end