function Assignment2

img = im2double(imread('Data\mm.jpg'));

% Create Feature Vector
features = createFeatureVector(img, true);
% Perform kNN
[classification, centroids] = kNN(features, 2, 1);
% Plot Results
plotResults(classification, img, centroids);
end


function [features] = createFeatureVector(img, useSpatial)
% INPUT
% img -> the image to be converted into a 2D feature vector
% useSpatial-> true if the coordinates should be treated as features too
%% Create Feature vector
[height, width, ~] = size(img);

tmp = img(:,:,1);
r = tmp(:);
tmp = img(:,:,2);
g = tmp(:);
tmp = img(:,:,3);
b = tmp(:);

features = [r g b];
if(useSpatial == true)
    
    % Create array for all x (height) indices 
    % The array for a 3x2 image look like [1,2,3,1,2,3]
    x = (1:1:height) / height;
    x = repmat(x, width, 1)';   % For each row
    
    % Create array for all y (width) indices
    % The array for a 3x2 image look like [1,1,1,2,2,2]

    y = (1:1:width)' / width;
    y = repmat(y, 1, height)';
   
    features = [r g b x(:) y(:)];
end
end


function[classification, centroids] = kNN(samples, k, maxIterations)
% Input
% img -> the image to be classified
% numClasses -> number of classes
% useSpatial -> determines whether to use spatial information or not
% maxIterations -> number of maximum iterations if the algorithm does not
% convert
% OUTPUT
% classification -> class labels for all elements in img
% centroids -> the centroid data points of each cluster

% Number of features
[numSamples, numFeatures] = size(samples);
% Create empty classifications
classification = NaN(numSamples, 1);
distances = NaN(numSamples, k);
% Create random centroids
%rng(2,'twister');
centroids = rand(k, numFeatures);


% Repeat as long as the centroids change
for i = 1:maxIterations
    disp(['Iteration: ', sprintf('%d', i) ]);
    % Calculate Distance for each sample to each centroid
    for class=1:k
        distances(:, class) = calcDistances(samples, centroids(class,:), numSamples);
    end
    
    % Get Min distances and the indices (= class Label)
    [~, classification] = min(distances,[],  2);       
       
    % Calculate new Centroids
    newCentroids = calculateCentroids(classification, samples, k, numSamples, numFeatures);
    %
    % Terminate algorithm if no change occured or max iterations is reached
    if(centroidsChanged(centroids, newCentroids, 0.1) == false)
        break;
    end
    % Apply new Centroids
    centroids = newCentroids;
    
end
end


%% Calculates the euclidean distance between sample1 and sample3
function[distances] = calcDistances(samples, centroid, numSamples)

tmp = samples - repmat(centroid, numSamples, 1);
distances = sqrt(sum(abs(tmp).^2,2));

end


%% Calculates the centroids based on the classification and samples
function[centroids] = calculateCentroids(classification, samples, k, numSamples, numFeatures)

% Store the number of samples per class
numClasses = zeros(k, 1);

% Store the new centroids
centroids = zeros(k, numFeatures);

% Accumulate Samples from each class
for i=1:numSamples
    class = classification(i);
    centroids(class,:) = centroids(class,:) + samples(i, :);
    numClasses(class) = numClasses(class) + 1;
end

%Divide accumulated centroids by the number
for i=1:k
    centroids(i,:) = centroids(i,:) / numClasses(i);
end
end


%% Determines if the new centroids differ from the old centroids, capped by threshold
function[changed] = centroidsChanged(oldCentroids, newCentroids, threshold)
% TODO: Implement this function correctly
changed = true;
end


%% Plots the image and the kMeans clustered image next to another in a figure
function plotResults(classification, image, centroids)

kMeansImage = zeros(size(image));
[height, width, ~] = size(image);

numSamples = height * width;

for i=0:numSamples - 1
    
    x = mod(i , height) + 1;
    y = floor(i / height) + 1;
    
    class = classification(i+1);
    
        kMeansImage(x, y, 1) = centroids(class, 1);
        kMeansImage(x, y, 2) = centroids(class, 2);
        kMeansImage(x, y, 3) = centroids(class, 3);
end

figure;
subplot(1, 2, 1);
imshow(image);
title('Color Image');

subplot(1, 2, 2);
imshow(kMeansImage);
title(['kMeans : k = ' , sprintf('%d', size(centroids, 2))]);
end