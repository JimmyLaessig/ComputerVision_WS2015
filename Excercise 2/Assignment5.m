%main script
%VLFeat/ Library\v0.9.19\vlfeat-0.9.19\toolbox\vl_setup()

%addpath('E:\Dateien\Eigene Dokumente\Studium\CV\vlfeat-0.9.19\toolbox','-end');
%vl_setup();

%% TODO: rename to main.m
C = BuildVocabulary(folder, num_clusters);
[training, group] = BuildKNN(folder,C);
conf_matrix = ClassifyImages(folder,C,training,group);