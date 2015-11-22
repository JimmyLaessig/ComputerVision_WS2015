function Assignment3
img = im2double(imread('Data\tree.jpg'));
if size(img,3) == 3
    img = rgb2gray(img);
end
logBlobDetector(img);
end

function logBlobDetector( img )
% Performs the LoG Blob Detector
% img ... the image for the blob detection

sigma = 2; % initial scale
k = 1.25; % multiplication value
level = 10;
scale_space = zeros(size(img,1),size(img,2),level);
max_space = scale_space;
threshold = 0.001;
suppression_size = 10;

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

function show_all_circles(I, cx, cy, rad, color, ln_wid)
%% I: image on top of which you want to display the circles
%% cx, cy: column vectors with x and y coordinates of circle centers
%% rad: column vector with radii of circles. 
%% The sizes of cx, cy, and rad must all be the same
%% color: optional parameter specifying the color of the circles
%%        to be displayed (red by default)
%% ln_wid: line width of circles (optional, 1.5 by default

if nargin < 5
    color = 'r';
end

if nargin < 6
   ln_wid = 1.5;
end

imshow(I); hold on;

theta = 0:0.1:(2*pi+0.1);
cx1 = cx(:,ones(size(theta)));
cy1 = cy(:,ones(size(theta)));
rad1 = rad(:,ones(size(theta)));
theta = theta(ones(size(cx1,1),1),:);
X = cx1+cos(theta).*rad1;
Y = cy1+sin(theta).*rad1;
line(X', Y', 'Color', color, 'LineWidth', ln_wid);

title(sprintf('%d circles', size(cx,1)));

end
