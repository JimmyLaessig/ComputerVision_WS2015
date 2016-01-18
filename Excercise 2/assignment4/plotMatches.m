function plotMatches(RGB,INFO,MATCHES)
% Plots the matches before using RANSAC
%
% RGB     ... Nx1 cell array with the RGB images
% INFO    ... Nx1 cell array with image informations
% MATCHES ... (N - 1)x1 cell with 2x1 cell arrays containing coordinates of matches

num_imgs = numel(MATCHES);

for i = 1:num_imgs
    matching_points = MATCHES{1};
    matching_points1 = matching_points{1};
    matching_points2 = matching_points{2};
    
    % Plot Matches
    fig = match_plot(RGB{i}, RGB{i+1}, matching_points1, matching_points2);
    
    [~,img_name1,~] = fileparts(INFO{i}.Filename);
    [~,img_name2,~] = fileparts(INFO{i+1}.Filename);
    
    set(fig, 'name', ['Matching without RANSAC: ',img_name1, ' to ', img_name2]);
    
end

end

