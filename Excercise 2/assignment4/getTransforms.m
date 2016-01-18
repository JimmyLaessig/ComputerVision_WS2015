function [TFORMS,MATCHES] = getTransforms(FEATS_ARRAY, DESCRS_ARRAY)
% Compute the transformation matrix to 'transform/align' the left image to the right image
% 
% FEATS_ARRAY ... Nx1 cell vector with the SIFT features, only the coords are relevant [x y]
% DESCRS_ARRAY ... Nx1 cell vector with the SIFT descriptors
% 
% TFORMS ... (N-1)x1 cell vector with the transformations of imgL to imgR
% MATCHES ... (N-1)x1 cell vector with the matching points of imgL to imgR

num_imgs = numel(FEATS_ARRAY);
TFORMS = cell(num_imgs-1, 1);
MATCHES = cell(num_imgs-1, 1);

for i = 1:num_imgs-1
    
    % Comput matching and return the match points coordinates
    matching_points = getMatchPoints(FEATS_ARRAY,DESCRS_ARRAY,i,i+1);
    
    % Save match points to plot them later on
    MATCHES{i} = matching_points;
    
    % Perform RANSAC and save the resulting TFORM
    TFORMS{i} = RANSAC(matching_points,1000);
end

end

function [matching_points] = getMatchPoints(FEATS_ARRAY,DESCRS_ARRAY,pos1,pos2)
% Computes the matches of the descriptors of two different consequtive images
% and returns the coordinates of the matches
%
% FEATS_ARRAY   ... Nx1 cell vector with the SIFT features, only the coords are relevant [x y]
% DESCRS_ARRAY  ... Nx1 cell vector with the SIFT descriptors
% pos1          ... scalar position in cell array of first image
% pos2          ... scalar position in cell array of second image
%
% matching_points ... 2x1 cell vector with the coordinates of the matching points

[matches,~] = vl_ubcmatch(DESCRS_ARRAY{pos1}, DESCRS_ARRAY{pos2});

% SIFT Features for the two images
features1 = FEATS_ARRAY{pos1};
features2 = FEATS_ARRAY{pos2};

% All data points of the image features
points1 = features1([1,2],:);
points2 = features2([1,2],:);

% All data points of the matching features
indices1 = matches(1,:);
indices2 = matches(2,:);

matching_points = cell(2,1);
matching_points{1} = points1(:, indices1)';
matching_points{2} = points2(:, indices2)';

end

function [TFORM] = RANSAC(matching_points, iterations)
% Performs RANSAC algorithm to detect the most suitable image transformation
%
% matching_points ... 2x1 cell vector with 2xN matrices containing the matching points per image
% iterations      ... scalar number of iterations
%
% TFORM ... most suitable transformation

matching_points1 = matching_points{1};
matching_points2 = matching_points{2};

%% Perform RANSAC scheme
num_inliers = 0;

for j = 1:iterations
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
            TFORM  = TFORM_current;
        end
    catch
    end
end

end