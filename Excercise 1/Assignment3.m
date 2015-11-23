function Assignment3(pic_name, threshold, supp_size)

if ~exist('threshold','var') || isempty(threshold)
  threshold=0.1;
end

if ~exist('supp_size','var') || isempty(supp_size)
  supp_size=10;
end

img = im2double(imread(strcat('Data\', pic_name)));

if size(img,3) == 3
    img = rgb2gray(img);
end

logBlobDetector(img, threshold, supp_size);

end

%% Perform LoG Blob Detector
function logBlobDetector(img, threshold, suppression_size)
% img              ... the image for the blob detection
% threshold        ...
% suppression_size ...

sigma = 2; % initial scale
k = 1.25; % multiplication value
level = 10;
scale_space = zeros(size(img,1),size(img,2),level);
max_space = scale_space;
%threshold = 0.001;
%suppression_size = 10;

for i = 1 : level 
    sigma2 = sigma * k^(i-1);
    filter_size =  2*ceil(3*sigma2)+1; % filter size
    log_filter = fspecial('log', filter_size, sigma2) * sigma2^2;
    filtered = imfilter(img, log_filter, 'same', 'replicate');
    filtered = filtered .^2;
    scale_space(:,:,i) = filtered;   
end

%% non-maximum suppression

%non max suppression for each scale_space
for i = 1:level
    max_space(:,:,i) = ordfilt2(scale_space(:,:,i), suppression_size^2, ones(suppression_size));
end

%non max suppression between scales and threshold
for i = 1:level
    max_space(:,:,i) = max(max_space(:,:,max(i-1,1):min(i+1,level)),[],3);
end
max_space = max_space .* (max_space == scale_space);

cx = [];   
cy = [];   
rad = [];
for i = 1 : level
    [rows, cols] = find(max_space(:,:,i) >= threshold);
    tmp_rad = sigma * k^(i-1) * sqrt(2); 
    tmp_rad = repmat(tmp_rad, length(rows), 1);
    cx = [cx; cols];
    cy = [cy; rows];
    rad = [rad; tmp_rad];
end

show_all_circles(img, cx, cy, rad);

end
