function plotFeatures(RGB,INFO,FEATS_ARRAY)
% Plots the found SIFT features
%
% RGB         ... Nx1 cell array with the RGB images
% INFO        ... Nx1 cell array with image informations
% FEATS_ARRAY ... Nx1 cell vector with the SIFT features,

figure('name', 'SIFT Interest Points', 'position', [0, 0, 1920, 600]);

% Get number of elements
num_files = numel(INFO);

for i = 1:num_files
    
    % Plot Sift Features into figure
    subplot(1, num_files, i);
    imshow(RGB{i});
    h1 = vl_plotframe(FEATS_ARRAY{i});
    set(h1, 'color','r','linewidth', 2);
    
    [~,file_name,datatype] = fileparts(INFO{i}.Filename);
    title(strcat(file_name,'.', datatype));
end


end

