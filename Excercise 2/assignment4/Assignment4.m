function Assignment4
% Before running this assignment, make sure that you call vl_setup in order
% to initialize vlfeat framework.
% Runs the Image Stiching assignment with the given image sequence located in
% ass4_data folder
ImageStitching('campus', 5, 'jpg', 1000);
%ImageStitching('officeview', 5, 'jpg', 1000);
end

function ImageStitching(name, count, datatype, RANSAC_num_iterations)
% name     ... the base name of the image sequence
% count    ... the number of images in the sequence
% datatype ... the image data type

%% TASK Prerequisites - Read data into memory
% Image sequence is stored in two arrays, one containing the reference
% images in RGB, the other the processing images in greyscale

imagesRGB = cell(count, 1);
imagesGREY = cell(count, 1);
imagesInfo = cell(count, 1);

for i=1:count
    path =  strcat('ass4_data\', name, num2str(i),'.', datatype);
    tmp = imread(path);
    imagesRGB{i} = im2double(tmp);
    % Do NOT normalize greyscale image to the range of 0-1 since vl_sift needs the range to be normalized to 0-255
    imagesGREY{i} = rgb2gray(tmp);
    imagesInfo{i} = imfinfo(path);
end

%% TASK A - SIFT Interest Point Detection
figure('name', 'SIFT Interest Points', 'position', [0, 0, 1920, 600]);

% Detect SIFT InteresetPoints and store features and descritpors for each input image
featureArray = cell(count, 1);
descriptorArray = cell(count, 1);

for i = 1:count
    
    [features, descriptors] = vl_sift((single(imagesGREY{i})));
    featureArray{i} = features;
    descriptorArray{i} = descriptors;
    
    % Plot Sift Features into figure
    subplot(1, count, i);
    imshow(imagesRGB{i});
    h1 = vl_plotframe(featureArray{i});
    set(h1, 'color','r','linewidth', 2);
    title(strcat(name, num2str(i),'.', datatype));
end

%% TASK B - Interest Point Matching and Image Registration
% Store transform and number of inliers for each iteration
transforms = cell(count-1, 1);

for i = 1:count-1
    [matches,~] = vl_ubcmatch(descriptorArray{i}, descriptorArray{i+1});
    
    % SIFT Features for the two images
    features1 = featureArray{i};
    features2 = featureArray{i+1};
    
    % All data points of the image features
    points1 = features1([1,2],:);
    points2 = features2([1,2],:);
    
    % All data points of the matching features
    indices1 = matches(1,:);
    indices2 = matches(2,:);
    
    matching_points1 = points1(:, indices1)';
    matching_points2 = points2(:, indices2)';
    
    % Plot Matches
    fig = match_plot(imagesRGB{i}, imagesRGB{i+1}, matching_points1, matching_points2);
    set(fig, 'name', ['Matching without RANSAC: ', name, num2str(i), ' to ', name, num2str(i+1)]);
    
    %% Perform RANSAC scheme
    num_inliers = 0;
    inlier_indices = [];
    for j = 1:RANSAC_num_iterations
        % Randomly choose four matches
        [samples1, indices] = datasample(matching_points1, 4);
        samples2 = matching_points2(indices, :);
        
        try
            % Estimate homography between two consequtive images and store
            % it for later use
            TFORM_current = cp2tform(samples1, samples2, 'projective');
            % Transform matching points
            [x, y]= tformfwd(TFORM_current, matching_points1(:,1), matching_points1(:,2));
            transformed_matching_points_1 = horzcat(x,y);
            
            % Determine inlier by comparing euclidic distances between the
            % old and transformed feature points to a certain threshold (e.g. 5)
            
            % Calculate Euclidean distances
            distances = (sum(((transformed_matching_points_1-matching_points2).^2), 2)).^0.5;
            % Remove all values over the threshold
            distances(distances >= 5) = 0;
            % Set all values beneath the threshold to 1
            distances(distances ~=0) = 1;
            num_inliers_current = sum(distances);
            
            % If the current homography has more inliers than the previous,
            % it will be the transform of choice
            if(num_inliers_current > num_inliers)
                num_inliers = num_inliers_current;
                transforms{i}  = TFORM_current;
                inlier_indices = find(distances);
            end
        catch
        end
    end
    % Plot Inlier Matches
 fig = match_plot(imagesRGB{i}, imagesRGB{i+1}, matching_points1(inlier_indices, :), matching_points2(inlier_indices, :));
 set(fig, 'name', ['Matching after RANSAC: ', name, num2str(i), ' to ', name, num2str(i+1)]);
end

% Transform the images onto the second image using the calculated transforms
% The figures show the image transformed into the space of the
% consecutive image space. Therefore all outlying data is cut off and
% only overlapping parts are visible
figure('name', [name, ': Images transformed onto consecutive neighbor'], 'position', [0, 0, 1920, 600]);
for i = 1:count-1
    subplot(1, count-1, i);
    
    height1 = imagesInfo{i}.Height;
    width1 = imagesInfo{i}.Width;
    
    height2 = imagesInfo{i+1}.Height;
    width2 = imagesInfo{i+1}.Width;
    
    scale = [height1 / height2, width1 / width2];
    img_transformed = imtransform(imagesRGB{i}, transforms{i}, 'XData',[1 width2], 'YData',[1 height2], 'XYScale', scale);
    % Create a mask to overlay the transformed image onto the base image
    mask = (img_transformed > 0);
    imshow(mask .* img_transformed + ~mask .* imagesRGB{i+1});
    title([num2str(i), ' onto ', num2str(i+1)]);
end

%% Image Stitching

% Reference image index
refIndex = ceil(count / 2);
homographies = cell(count, 1);
for i = 1:count
    
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
            transform = transform * transforms{j}.tdata.T;
        end
        
    elseif (i > refIndex)
        % Index is larger then reference index (right of it), use inverse transforms
        disp('Creating new Transform');
        % Accumulate all transforms in the sequence from the reference index to the current index
        for j=refIndex:i-1
            disp(['invTransform ', num2str(j), ',' num2str(j+1)]);
            transform = transform * transforms{j}.tdata.Tinv;
        end
    end
    
    % Create new TFORM with the calculated transformation matrix
    homographies{i} = maketform('projective', transform);
end

% Estimate dimensions of output image
% Transform the corners of all images onto the space of the centered base
% image
corners = zeros(count * 4, 3);
for i = 1:count
    
    transform = homographies{i};
    x = imagesInfo{i}.Width;
    y = imagesInfo{i}.Height;
    
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

image_width = maxWidth - minWidth;
image_height = maxHeight - minHeight;

% Init final image with the calculated dimensions
image_stitched = zeros(image_height + 1, image_width + 1, 3);
image_alpha = zeros(image_height + 1, image_width + 1);
% Transform all images onto the base plane
for i = 1:count
    
    width = imagesInfo{i}.Width;
    height = imagesInfo{i}.Height;
    
    % Create alpha channel with white borders
    alpha = zeros(size(imagesGREY{i}));
    alpha(1,:) = 1;
    alpha(:,1) = 1;
    alpha(height,:) = 1;
    alpha(:, width) = 1;
    % Calculate distances to the white border
    alpha = bwdist(alpha);
    % Normalize distances to [0,1]
    alpha = alpha / max(alpha(:));
    % Transform the image onto the base plane
    img_transformed = imtransform(imagesRGB{i}, homographies{i}, 'XData',[minWidth maxWidth], 'YData',[minHeight maxHeight]);
    alpha_transformed = imtransform(alpha, homographies{i}, 'XData',[minWidth maxWidth], 'YData',[minHeight maxHeight]);
    
    % Multiply current color value with the current alpha values
    image_stitched = image_stitched + img_transformed .* repmat(alpha_transformed,1 ,1 ,3);
    % add current alpha values to the images total alpha values
    image_alpha = image_alpha + alpha_transformed;
end

% Divide the color channels by the alpha values
image_stitched(:,:,1) = image_stitched(:,:,1) ./ image_alpha;
image_stitched(:,:,2) = image_stitched(:,:,2) ./ image_alpha;
image_stitched(:,:,3) = image_stitched(:,:,3) ./ image_alpha;

% Show Image
figure('name', 'Stitched image');
imshow(image_stitched);
end