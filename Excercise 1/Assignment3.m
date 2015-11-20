function Assignment3
img = im2double(imread('Data\butterfly.jpg'));
logBlobDetector(img);
end

function logBlobDetector( img )
% Performs the LoG Blob Detector
% img ... the image for the blob detection

sigma = 2; % initial scale
k = 1.25; % multiplication value
scale_space = zeros(size(img,1),size(img,2),10);

for i = sigma : k : 10 
   
    filter_size =  2*ceil(3*sigma)+1; % filter size
    log_filter = fspecial('log', filter_size, sigma) * sigma^2;
    filtered = imfilter(img, log_filter, 'same', 'replicate');
    %scale_space(:,:,i) = filtered;
    
    sigma = i;
end

rad = sigma * sqrt(2);
show_all_circles(img, rad,rad,rad);
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
