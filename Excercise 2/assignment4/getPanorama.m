function [IMG_STITCHED] = getPanorama(RGB,INFO,TFORMS)
% Transforms and blends the transformed images together to create a panorama image
% 
% RGB    ... Nx1 cell vector with the images
% INFO   ... Nx1 cell vector with the images informations
% TFORMS ... (N-1)x1 cell vector with the transformations of each image
%
% IMG_STITCHED ... the resulting panorama image

num_imgs = numel(INFO);

% Compute homographies for all images
homographies = calcHomographies(TFORMS,num_imgs);

% Compute the sizes of the resulting panorama image
[image_width,image_height, vars] = calcPanoramaSizes(INFO,homographies,num_imgs);

% Blend all transformed images together
pan_canvas = zeros(image_height + 1, image_width + 1);
IMG_STITCHED = blendImages(RGB,homographies,pan_canvas,vars,num_imgs);
%IMG_STITCHED = stitchImages(RGB,homographies,pan_canvas,vars,num_imgs);

end

function [HOMOGRAPHIES] = calcHomographies(TFORMS,num_imgs)
% Aligns every image to a reference image and creates the corresponding
% homographies
% 
% TFORMS        ... Mx1 cell vector with the transformation information per image
% num_imgs      ... scalar number of images (= M + 1)
% 
% HOMOGRAPHIES  ... the 'correct' transformation informations per image

% Reference image index
refIndex = ceil(num_imgs / 2);
HOMOGRAPHIES = cell(num_imgs, 1);

for i = 1:num_imgs
    
    % Initialize Transform as identity matrix(Creating identity matrix)
    transform =  [1 0 0; 0 1 0; 0 0 1];
    % Do not transform the reference image since all other images are
    % aligned to it
    
    if (i < refIndex)
        % Index is smaller then reference index (left of it), use regular transforms
        disp('Creating new Transform');
        % Accumulate all transforms in the sequence up to the reference index
        for j= refIndex-1:-1:i
            disp(['transform ', num2str(j), ',' num2str(j+1)]);
            transform = transform * TFORMS{j}.tdata.T;
        end
        
    elseif (i > refIndex)
        % Index is larger then reference index (right of it), use inverse transforms
        disp('Creating new Transform');
        % Accumulate all transforms in the sequence from the reference index to the current index
        for j=refIndex:i-1
            disp(['invTransform ', num2str(j), ',' num2str(j+1)]);
            transform = transform * TFORMS{j}.tdata.Tinv;
        end
    end
    
    % Create new TFORM with the calculated transformation matrix
    HOMOGRAPHIES{i} = maketform('projective', transform);
end

end

function [WIDTH,HEIGHT,VARYINGS] = calcPanoramaSizes(INFO,HOMOGRAPHIES,num_imgs)
% Estimates dimensions of output image
%
% INFO ... Nx1 cell vector with the images informations
% HOMOGRAPHIES ... Nx1 cell vector with the transformation information per image
% num_imgs ... scalar number of images
% 
% WIDTH ... scalar width of panorama
% HEIGHT ... scalar height of panorama
% VARYINGS ... 4x1x1 matrix with the min and max values of X and Y

% Transform the corners of all images onto the space of the centered base
% image
corners = zeros(num_imgs * 4, 3);
for i = 1:num_imgs
    
    transform = HOMOGRAPHIES{i};
    x = INFO{i}.Width;
    y = INFO{i}.Height;
    
    corners ((i-1) * 4 + 1, :) = [1 1 1] * transform.tdata.T;
    corners ((i-1) * 4 + 2, :) = [x 1 1] * transform.tdata.T;
    corners ((i-1) * 4 + 3, :) = [1 y 1] * transform.tdata.T;
    corners ((i-1) * 4 + 4, :) = [x y 1] * transform.tdata.T;
    
end
% Perform projective division
corners(:,1) = corners(:,1) ./ corners(:,3);
corners(:,2) = corners(:,2) ./ corners(:,3);
corners(:,3) = corners(:,3) ./ corners(:,3);

% Determine final dimensions using the min and max values of all
% transformed corners
minWidth  = floor(min(corners(:,1)));
minHeight = floor(min(corners(:,2)));
maxWidth  = ceil(max(corners(:,1)));
maxHeight = ceil(max(corners(:,2)));

WIDTH = maxWidth - minWidth;
HEIGHT = maxHeight - minHeight;

% Save min and max of width and height for later use
VARYINGS = [minWidth;minHeight;maxWidth;maxHeight];

end
function[IMG] = stitchImages(RGB, HOMOGRAPHIES, PAN_CANVAS, VARYINGS, num_imgs)
% Transforms and matches all images together WITHOUT blending
% panorama image
%
% RGB ... Nx1 cell vector with the images RGB
% HOMOGRAPHIES ... Nx1 cell vector with the transfomation information per image
% PAN_CANVAS ... KxLx1 zero matrix used as reference to 'draw' the panorama image
% VARYINGS ... 4x1x1 matrix containing the min and max values of width and height
% num_imgs ... scalar number of images
% 
% IMG_STITCHED ... the resulting panorama image

IMG = repmat(PAN_CANVAS,1,1,3);

minWidth  = VARYINGS(1);
minHeight = VARYINGS(2);
maxWidth  = VARYINGS(3);
maxHeight = VARYINGS(4);

% Transform all images onto the base plane
for i = 1:num_imgs
    
    % Transform the image onto the base plane
    img_transformed = imtransform(RGB{i}, HOMOGRAPHIES{i}, 'XData',[minWidth maxWidth], 'YData',[minHeight maxHeight]);
    
    % Create a mask that indicates where pixel aren't set yet
    mask = (img_transformed > 0);
    % Multiply current color value with the current alpha values
    IMG = mask .* img_transformed + ~mask .* IMG;
end

end


function [IMG_STITCHED] = blendImages(RGB,HOMOGRAPHIES,PAN_CANVAS,VARYINGS,num_imgs)
% Transforms and blends all transformed images together to a single
% panorama image
%
% RGB ... Nx1 cell vector with the images RGB
% HOMOGRAPHIES ... Nx1 cell vector with the transfomation information per image
% PAN_CANVAS ... KxLx1 zero matrix used as reference to 'draw' the panorama image
% VARYINGS ... 4x1x1 matrix containing the min and max values of width and height
% num_imgs ... scalar number of images
% 
% IMG_STITCHED ... the resulting panorama image

IMG_STITCHED = repmat(PAN_CANVAS,1,1,3);
image_alpha = PAN_CANVAS;

minWidth  = VARYINGS(1);
minHeight = VARYINGS(2);
maxWidth  = VARYINGS(3);
maxHeight = VARYINGS(4);

% Transform all images onto the base plane
for i = 1:num_imgs
    
    height = size(RGB{i},1);
    width = size(RGB{i},2);
    
    % Create alpha channel with white borders
    alpha = zeros(height,width);
    alpha(1,:) = 1;
    alpha(:,1) = 1;
    alpha(height,:) = 1;
    alpha(:, width) = 1;
    % Calculate distances to the white border
    alpha = bwdist(alpha);
    % Normalize distances to [0,1]
    alpha = alpha / max(alpha(:));
    % Transform the image onto the base plane
    img_transformed = imtransform(RGB{i}, HOMOGRAPHIES{i}, 'XData',[minWidth maxWidth], 'YData',[minHeight maxHeight]);
    alpha_transformed = imtransform(alpha, HOMOGRAPHIES{i}, 'XData',[minWidth maxWidth], 'YData',[minHeight maxHeight]);
    
    % Multiply current color value with the current alpha values
    IMG_STITCHED = IMG_STITCHED + img_transformed .* repmat(alpha_transformed,1 ,1 ,3);
    % add current alpha values to the images total alpha values
    image_alpha = image_alpha + alpha_transformed;
end

% Divide the color channels by the alpha values
IMG_STITCHED(:,:,1) = IMG_STITCHED(:,:,1) ./ image_alpha;
IMG_STITCHED(:,:,2) = IMG_STITCHED(:,:,2) ./ image_alpha;
IMG_STITCHED(:,:,3) = IMG_STITCHED(:,:,3) ./ image_alpha;

end

