function [training,group] = BuildKNN(folder,C)

% get directories with images
dirs = dir(folder);

% start = 3 to ignore '.' and '..' directories
loop_start = 3;

% number of directories
num_of_dirs = size(dirs,1);

% initialize group vector, one row per image
% 800 = 8 directories with 100 images
% 800x1x1
group = zeros(800,1);

% number of clusters in C
num_clusters = size(C,2);

% initialize trainig matrix containing histograms, one row = hist per image
% 800xnum_clustersx1
training = zeros(800,num_clusters);

% up to 800
img_index = 1;

% up to 8, directory = categorie
dir_index = 1;

% for each directory
for i = loop_start:num_of_dirs
    path = strcat(folder,'\',dirs(i).name);
    files = dir(path);
    num_of_files = size(files,1);
    
    % for each image
    for j = loop_start:num_of_files
        
        if strcmp(files(j).name,'Thumbs.db')
            continue;
        end
        
        file_path = strcat(path,'\',files(j).name);
        
        I = single(imread(file_path));
        
        % compute dense SIFT
        % 128xMx1
        [~,DESCRS] = vl_dsift(I,'step',2,'fast');
        
        % store image's category = directory index
        group(img_index) = dir_index;
        
        % compute for every row in DESCRS (=feature) its index in C
        % (= corresponding cluster it belongs to).
        % C and DESCRS must have the same column size = 128
        % Mx1x1
        [IDX] = knnsearch(C',DESCRS');
        
        % map M values of IDX to num_clusters bins
        % (= number of entries per bin)
        % num_clusters x1x1
        bincounts = histc(IDX,1:num_clusters);
        
        % normalize bins to keep values uniform
        bincounts = bincounts / size(DESCRS,2);
        
        % save normalized histogram bins in training matrix
        training(img_index,:) = bincounts(:);
        
        img_index = img_index + 1;
    end
    
    dir_index = dir_index + 1;
end
end