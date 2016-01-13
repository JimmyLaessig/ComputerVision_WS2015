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
% Store transform and number of inliers for each iteration
transforms = cell(count-1, 1);

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
    fig = match_plot(imagesRGB(:,:,:,i), imagesRGB(:,:,:,i+1), matching_points1, matching_points2);
    set(fig, 'name', ['Matching without RANSAC: ', name, num2str(i), ' to ', name, num2str(i+1)]);
    
    %% Perform RANSAC scheme
    num_inliers = 0;
    
    for j=1:n
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
            end
        catch
        end
    end
end

% Transform the images onto the second image using the calculated transforms
% The figures show the image transformed into the space of the
% consecutive image space. Therefore all outlying data is cut off and
% only overlapping parts are visible
figure('name', [name, ': Images transformed onto consecutive neighbor'], 'position', [0, 0, 1920, 600]);
for i = 1:count-1
    subplot(1, count-1, i);
    
    [height1, width1] = size(imagesRGB(:,:,1,i));
    [height2, width2] = size(imagesRGB(:,:,1,i+1));
    scale = [height1 / height2, width1 / width2];
    img = imtransform(imagesRGB(:,:,:,i), transforms{i}, 'XData',[1 width2], 'YData',[1 height2], 'XYScale', scale);
    imshow(img);
    title([num2str(i), ' onto ', num2str(i+1)]);
end

%% Image Stitching

% Reference image index
refIndex = ceil(count / 2);
for i = 1:count
    
    % Initialize Transform as identity matrix(Creating identity matrix)
    transform = maketform('projective', [1 0 0; 0 1 0; 0 0 1]);
    
    if (i == refIndex)
        % Do not transform the reference image since all other images are
        % aligned to it
        continue;
        
    elseif (i < refIndex)
        % Index is smaller then reference index (left of it), use regular transforms
        disp('Creating new Transform');
        % Accumulate all transforms in the sequence up to the reference index
        for j= refIndex-1:-1:i
            disp(['transform ', num2str(j), ',' num2str(j+1)]);
            transform.tdata.T = transform.tdata.T * transforms{j}.tdata.T;
        end
        
    elseif (i > refIndex)
        % Index is larger then reference index (right of it), use inverse transforms
        disp('Creating new Transform');
        % Accumulate all transforms in the sequence from the reference index to the current index
        for j=refIndex:i-1
            disp(['invTransform ', num2str(j), ',' num2str(j+1)]);
            transform.tdata.Tinv = transform.tdata.Tinv * transforms{j}.tdata.Tinv;
        end
        % Set the inverse as regular matrix
        transform.tdata.T = transform.tdata.Tinv;       
    end
    
    % Calculate new inverse Transform (just in case)
    transform.tdata.tInv = inv(transform.tdata.T);
    % TODO: Transform image here with the calculated TFORM
    
end
end