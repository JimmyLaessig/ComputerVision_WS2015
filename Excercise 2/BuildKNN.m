function [training,group] = BuildKNN(folder,C)
% get directories with images
dirs = dir(folder);
% start = 3 to ignore '.' and '..' directories
loop_start = 3;
% number of directories
num_of_dirs = size(dirs,1);
group = zeros(800,1);
training = zeros(800,50);

img_index = 1;
dir_index = 1;

for i = loop_start:num_of_dirs
    path = strcat(folder,'\',dirs(i).name);
    files = dir(path);
    num_of_files = size(files,1);
    
    for j = loop_start:num_of_files
        
        file_path = strcat(path,'\',files(j).name);
        I = single(imread(file_path));
        
        [~,DESCRS] = vl_dsift(I,'step',2,'fast');
        group(img_index) = dir_index;
        

        [IDX] = knnsearch(C',DESCRS');
        bincounts = histc(IDX,1:50);
        bincounts = bincounts / size(DESCRS,2);
        training(img_index,:) = bincounts(:);
        
        img_index = img_index + 1;
    end
    
    dir_index = dir_index + 1;
end
end