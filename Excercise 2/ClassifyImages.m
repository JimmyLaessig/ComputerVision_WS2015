function [ conf_matrix ] = ClassifyImages(folder,C,training,group)

% get directories with images
dirs = dir(folder);
% start = 3 to ignore '.' and '..' directories
loop_start = 3;
% number of directories
num_of_dirs = size(dirs,1);

conf_matrix = zeros(8,8);

group_index = 1;

for i = loop_start:num_of_dirs
    path = strcat(folder,'\',dirs(i).name);
    files = dir(path);
    num_of_files = size(files,1);
    
    for j = loop_start:num_of_files
        
        file_path = strcat(path,'\',files(j).name);
        I = single(imread(file_path));
        
        [~,DESCRS] = vl_dsift(I,'step',2,'fast');        

        [IDX] = knnsearch(C',DESCRS');
        bincounts = histc(IDX,1:50);
        bincounts = bincounts / size(DESCRS,2);
        class = knnclassify(bincounts',training,group,3);
        
        conf_matrix(group_index,class) = conf_matrix(group_index,class) + 1;
    end
    
    group_index = group_index + 1;
end
end

