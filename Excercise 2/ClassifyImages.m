function [ conf_matrix ] = ClassifyImages(folder,C,training,group)

% get directories with images
dirs = dir(folder);

% start = 3 to ignore '.' and '..' directories
loop_start = 3;

% number of directories
num_of_dirs = size(dirs,1);

% number of clusters in C
num_clusters = size(C,2);

% initialize output matrix
% 8 = 8 directories
% 8x8x1
conf_matrix = zeros(8,8);

group_index = 1;

% for each directory
for i = loop_start:num_of_dirs
    path = strcat(folder,'\',dirs(i).name);
    files = dir(path);
    num_of_files = size(files,1);
    
    % for each images
    for j = loop_start:num_of_files
        
        file_path = strcat(path,'\',files(j).name);
        
        I = imread(file_path);
        
        if size(I,3) > 1
            I = rgb2gray(I);
        end
        
        I = single(I);
        
        % compute dense SIFT from test directory
        % 128xMx1
        [~,DESCRS] = vl_dsift(I,'step',2,'fast');

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
        
        % classify the recently computed histogramm to one category
        % number of columns of the sample and training sets must be equal
        % scalar = index of category
        class = knnclassify(bincounts',training,group,3);
        
        % fill output matrix with number of matches
        % correct match: group_index = class
        conf_matrix(group_index,class) = conf_matrix(group_index,class) + 1;
    end
    
    group_index = group_index + 1;
end
end

