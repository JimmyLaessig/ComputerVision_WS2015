function [ C ] = BuildVocabulary(folder,num_clusters )

% get directories with images
dirs = dir(folder);
% matrix to save descriptors
descriptors = zeros(128,800 * 100);
% start = 3 to ignore '.' and '..' directories
loop_start = 3;
% number of directories
num_of_dirs = size(dirs,1);

des_start = 1;
des_end = 100;

for i = loop_start:num_of_dirs
    path = strcat(folder,'\',dirs(i).name);
    files = dir(path);
    num_of_files = size(files,1);
    
    for j = loop_start:num_of_files
        
        file_path = strcat(path,'\',files(j).name);
        I = single(imread(file_path));
        steps = min(size(I)) / 10;
        [~, DESCRS] = vl_dsift(I,'step',steps,'fast');
        indices = randsample((1:size(DESCRS,2)),100);
        DESCRS = DESCRS(:,indices);
        descriptors(:,des_start:des_end) = DESCRS;
        des_start = des_start + 100;
        des_end = des_end + 100;
        
    end
end

[C,~] = vl_kmeans(single(descriptors),num_clusters);

end

