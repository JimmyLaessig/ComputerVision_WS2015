warning('off','all');

folder_train = 'ass5_data\train';
%folder_test = 'ass5_data\owntest';
folder_test = 'ass5_data\test';

if exist('C','var') == 0
    tic;
    C = BuildVocabulary(folder_train, 50);
    bVoc = toc;
end

if exist('training','var') == 0 || exist('group','var') == 0
    tic;
    [training, group] = BuildKNN(folder_train,C);
    bKnn = toc;
end

tic;
conf_matrix = ClassifyImages(folder_test,C,training,group);
classIm = toc;

fprintf('BuildVocabulary: %f\n', bVoc);
fprintf('BuildKNN:        %f\n', bKnn);
fprintf('ClassifyImages:  %f\n', classIm);
fprintf('Total in mins:   %f\n', (bVoc + bKnn + classIm)/60);