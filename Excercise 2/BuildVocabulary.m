function [ C ] = BuildVocabulary(folder,num_clusters )

% get directories with images
dirs = dir(folder);

% matrix to save descriptors horizontaly
% 128x80000x1
descriptors = zeros(128,800 * 100);

% start = 3 to ignore '.' and '..' directories
loop_start = 3;

% number of directories
num_of_dirs = size(dirs,1);

% positions to save computed DESCRS in descriptors
des_start = 1;
des_end = 100;

% for each directory
for i = loop_start:num_of_dirs
    path = strcat(folder,'\',dirs(i).name);
    files = dir(path);
    num_of_files = size(files,1);
    
    % for each image
    for j = loop_start:num_of_files
        
        file_path = strcat(path,'\',files(j).name);
        
        % get image and transform to single precission
        I = single(imread(file_path));
        
        % calculate steps to get ~100 features
        steps = min(size(I)) / 10;
        
        % compute dense SIFT descriptors
        % 128xMx1
        [~, DESCRS] = vl_dsift(I,'step',steps,'fast');
        
        % get 100 random indices
        indices = randsample((1:size(DESCRS,2)),100);
        
        % get 100 random descriptor values
        % 128x100x1
        DESCRS = DESCRS(:,indices);
        
        % save them in descriptors matrix
        descriptors(:,des_start:des_end) = DESCRS;
        des_start = des_start + 100;
        des_end = des_end + 100;
        
    end
end

% compute kmeans from all the found descriptors
% 128xnum_clustersx1
[C,~] = vl_kmeans(single(descriptors),num_clusters);

end

