function Assignment2
img = im2double(imread('Data\mm.jpg'));
kNN(img, 2, true);
end


function kNN(img, k, useSpatial)
% Input
% img -> the image to be classified
% k -> number of centroids
% useSpatial -> determines whether to use spatial information or not
% OUTPUT
% classification -> class labels for all elements in img

% Create emtpy 2D information

%% Create Feature vector
[width, height] = size(img(:,:,1));
numSamples = width * height;

tmp = img(:,:,1);
r = tmp(:);
tmp = img(:,:,1);
g = tmp(:);
tmp = img(:,:,1);
b = tmp(:);

samples = [r g b];
if(useSpatial == true)
    
    x = 1:1:width;
    x = repmat(x, 1, height);
    x = x' / width;
    
    y = 1:1:height;
    y = repmat(y, 1, width);
    y = y' / height;
    
    samples = [r g b x y];
end

numFeatures = size(samples, 2);
%% Perform kMeans
classification = zeros(width * height, 1);


% Initialize rnd centroids
rng(0,'twister');
centroids = rand(k, numFeatures);
changed = true;

% Repeat as long as the centroids change
while(changed == true)
    
    % Do kNN-Classification for each sample using the Centroids
    for i=1:numSamples
        distance = Inf;
        for j=1:k
            currentDistance = euclid(samples(i,:), centroids(j,:));
            if ( currentDistance < distance)
                distance = currentDistance;
                classification(i) = j;
            end
        end
    end
    % Calculate new Centroids
    newCentroids = calculateCentroids(classification, samples, k, numFeatures, numSamples);
    % Determine if Centroids have changed
    %centroidsChanged(centroids, newCentroids, 0.1);
    changed = centroidsChanged(centroids, newCentroids, 0.1);
    % Apply new Ventroids if changed
    if(changed == true)
        centroids = newCentroids;
    end
end

% Plot the result
plotResults(classification, img, centroids);
end

%% Determines if the new centroids differ from the old centroids, capped by threshold
function[changed] = centroidsChanged(oldCentroids, newCentroids, threshold)
% TODO: Implement this function correctly
changed = false;
end


%% Calculates the euclidean distance between sample1 and sample2
function[distance] = euclid(sample1, sample2)
distance = norm(sample1 - sample2);
end


%% Calculates the centroids based on the classification and samples
function[centroids] = calculateCentroids(classification, samples, k, numFeatures, numSamples)
numClasses = zeros(k, 1);
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


%% Plots the image and the kMeans clustered image next to another in a figure
function plotResults(classification, image, centroids)
figure;
subplot(1, 2, 1);
imshow(image);
title('Color Image');
kMeansImage = zeros(size(image));
[width, height] = size(image(:,:,1));
numFeatures = size(classification, 2);

for i=1:numFeatures
    class = classification(i);
    x = mod(i, width);
    y = 1 + fix(i / width);
    centroids(class, 1);
   % kMeansImage(x, y, 1) = centroids(class, 1);
   % kMeansImage(x, y, 2) = centroids(class, 2);
   % kMeansImage(x, y, 3) = centroids(class, 3);
    kMeansImage(x, y, 1) = 0.5;
    kMeansImage(x, y, 2) = 0.5;
    kMeansImage(x, y, 3) = 0.5;
end

subplot(1, 2, 2);
imshow(kMeansImage);
title(['kMeans : k = ' , sprintf('%d', size(centroids, 2))]);
end


