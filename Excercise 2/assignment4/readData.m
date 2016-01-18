function [RGB,GREY,INFO] = readData(file_name, num_files, datatype)
% Reads from a directory and saves the images, the corresponding grey image and their
% informations in cell vectors
% 
% file_name ... directory to look for images
% num_files ... number of images in directory
% datatype ... type of image (JPG, PNG, etc)
% 
% RGB ... num_filesx1 cell vector with the RGB images
% GREY ... num_filesx1 cell vector with grey images
% INFO ... num_filesx1 cell vector with the images informations

RGB = cell(num_files, 1);
GREY = cell(num_files, 1);
INFO = cell(num_files, 1);

for i=1:num_files
    
    path =  strcat('ass4_data\', file_name, num2str(i),'.', datatype);
    tmp = imread(path);
    RGB{i} = im2double(tmp);
    % Do NOT normalize greyscale image to the range of 0-1 since vl_sift needs the range to be normalized to 0-255
    GREY{i} = rgb2gray(tmp);
    INFO{i} = imfinfo(path);
    
end

end

