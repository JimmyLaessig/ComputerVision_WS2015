warning('off','all');

%% TODO: rename to main.m
folder_train = 'ass5_data\train';
folder_test = 'ass5_data\test';

% tic;
% C = BuildVocabulary(folder_train, 50);
% bVoc = toc;

% tic;
% [training, group] = BuildKNN(folder_train,C);
% bKnn = toc;

tic;
conf_matrix = ClassifyImages(folder_test,C,training,group);
classIm = toc;

fprintf('BuildVocabulary: %f\n', bVoc);
fprintf('BuildKNN:        %f\n', bKnn);
fprintf('ClassifyImages:  %f\n', classIm);
fprintf('Total in mins:   %f\n', (bVoc + bKnn + classIm)/60);