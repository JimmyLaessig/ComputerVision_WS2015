function Assignment4

ImageStitching('campus', 5, 'jpg');
end

function ImageStitching(name, count, datatype)
% name     ... the base name of the image sequence
% count    ... the number of images in the sequence
% datatype ... the image data type

%% TASK Prerequisites - Read data into memory
% Image sequence is stored in two arrays, one containing the reference
% images in RGB, the other the processing images in greyscale
path =  strcat('ass4_data\', name, '1.', datatype);

tmp = imread(path);

imagesRGB = zeros(size(tmp,1),size(tmp,2), 3,count);
imagesGREY = zeros(size(tmp,1), size(tmp,2), count);

imagesRGB(:,:,:,1) = im2double(tmp);
imagesGREY(:,:,1) = rgb2gray(tmp);

for i=2:count
    path =  strcat('ass4_data\', name, num2str(i),'.', datatype);
    tmp = imread(path); 
    imagesRGB(:,:,:,i) = im2double(tmp);
    % Do NOT normalize greyscale image to the range of 0-1 since vl_sift needs the range to be normalized to 0-255
    imagesGREY(:,:,i) = rgb2gray(tmp);
  
end

%% TASK A - SIFT Interest Point Detection
[features, descriptors] = vl_sift((single(imagesGREY(:,:,1))));
figure;
imshow(imagesRGB(:,:,:,1));
seq = 1:1:size(features, 2);
h1 = vl_plotframe(features(:,seq));
set(h1, 'color','r','linewidth', 2); 

%% TASK B - Interest Point Matching and Image Registration

end

function Interest
