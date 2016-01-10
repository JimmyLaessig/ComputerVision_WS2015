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
    
    % Extract data feature coordinates of the two images
    allPoints1 = featureArray{i}([1,2],:)';
    allPoints2 = featureArray{i+1}([1,2],:)';
    
    % Extract indices of matches into singular array
    indices1 = matches(1,:)';
    indices2 = matches(2,:)';
    
    % Extract feature points with the certain indices
    points1 = zeros(size(indices1, 1), 2);
    points1(:,:) = allPoints1(indices1, :);
    
    points2 = zeros(size(indices2, 1), 2);
    points2(:,:) = allPoints2(indices2,:);
    
    % Plot Results
    h = match_plot(imagesRGB(:,:,:,i), imagesRGB(:,:,:,2), points1, points2);    
    set(h, 'name', ['Matching ', name, num2str(i),'.', datatype,' to ', name, num2str(i+1),'.', datatype]);
end
end


