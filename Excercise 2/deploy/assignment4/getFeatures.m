function [FEATS_ARRAY,DESCRS_ARRAY] = getFeatures(GREY)
% Computes the SIFT features and descriptors of every image.
% 
% GREY ... Mx1 cell vector with the input image to aply SIFT to
%     
% FEATS_ARRAY   ... Mx1 cell vector with the found SIFT features of the input
%                   images
% DESCRS_ARRAY  ... Mx1 cell vector with the found SIFT descriptors of the
%                   input images

% Get number of elements
num_files = numel(GREY);

% Detect SIFT InteresetPoints and store features and descritpors for each input image
FEATS_ARRAY = cell(num_files, 1);
DESCRS_ARRAY = cell(num_files, 1);

for i = 1:num_files
    
    [features, descriptors] = vl_sift((single(GREY{i})));
    FEATS_ARRAY{i} = features;
    DESCRS_ARRAY{i} = descriptors;

end

end

