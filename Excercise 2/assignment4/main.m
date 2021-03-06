function main(file_name,num_files,datatype)

%% Pre-requisites
warning('off','all');

if nargin < 2
    num_files = 5;
end

if nargin < 3
    datatype = 'jpg';
end

% num_filesx1 cell vectors with matrices
[RGB,GREY,INFO] = readData(file_name,num_files,datatype);
[FEATS_ARRAY,DESCRS_ARRAY] = getFeatures(GREY);

%% TaskA
plotFeatures(RGB,INFO,FEATS_ARRAY);

%% TaskB
% (num_files - 1)x1 cell vector
[TFORMS,MATCHES,INLIERS] = getTransforms(FEATS_ARRAY,DESCRS_ARRAY);
plotMatches(RGB,INFO,MATCHES,INLIERS);

%% TaskC
plotTransforms(RGB,INFO,TFORMS);
PANORAMA = getPanorama(RGB,INFO,TFORMS);

% Show Image
figure('name', 'Stitched image');
imshow(PANORAMA);

end