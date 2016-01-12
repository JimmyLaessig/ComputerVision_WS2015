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
n = 100;
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
figure('name', 'SIFT Interest Points', 'position', [0, 0, 1920, 600]);

% Detect SIFT InteresetPoints and store features and descritpors for each input image
featureArray = cell(count, 1);
descriptorArray = cell(count, 1);

for i = 1:count
    
    [features, descriptors] = vl_sift((single(imagesGREY(:,:,i))));
    featureArray{i} = features;
    descriptorArray{i} = descriptors;
    
    % Plot Sift Features into figure
    subplot(1, count, i);
    imshow(imagesRGB(:,:,:,i));
    h1 = vl_plotframe(featureArray{i});
    set(h1, 'color','r','linewidth', 2);
    title(strcat(name, num2str(i),'.', datatype));
end

%% TASK B - Interest Point Matching and Image Registration

for i = 1:count-1
    [matches,scores] = vl_ubcmatch(descriptorArray{i}, descriptorArray{i+1});
    
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
    fig = match_plot(imagesRGB(:,:,:,i), imagesRGB(:,:,:,2), matching_points1, matching_points2);
    set(fig, 'name', ['Matching without RANSAC: ', name, num2str(i), ' to ', name, num2str(i+1)]);
    
    %% Perform RANSAC scheme
    % Store transform and number of inliers for each iteration
    TFORM = 0;
    num_inliers = 0;
    
    for j=1:n
        % Randomly choose four matches
        [samples1, indices] = datasample(matching_points1, 4);
        samples2 = matching_points2(indices, :);
        
        try
            % Estimate homography
            TFORM_current = cp2tform(samples1, samples2, 'projective');
            % Transform matching points
            [x, y]= tformfwd(TFORM_current, matching_points1(:,1), matching_points1(:,2));
            transformed_matching_points_1 = horzcat(x,y);
            % Calculate Euclidean distances
            distances = (sum(((transformed_matching_points_1-matching_points2).^2), 2)).^0.5;
            % Remove all values over the threshold
            distances(distances >= 5) = 0;
            % Set all values beneath the threshold to 1
            distances(distances ~=0) = 1;
            
            num_inliers_current = sum(distances);
            
            if(num_inliers_current > num_inliers)
                num_inliers = num_inliers_current;
                TFORM  = TFORM_current;
            end                   
        end
    end
    % Transform the image onto the second image using the calculated TFORM
    [height1, width1] = size(imagesRGB(:,:,1,i));
    [height2, width2] = size(imagesRGB(:,:,1,i+1));
    scale = [height1 / height2, width1 / width2];
    img = imtransform(imagesRGB(:,:,:,i), TFORM, 'XData',[1 width2], 'YData',[1 height2], 'XYScale', scale);
    
end
end