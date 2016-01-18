function plotTransforms(RGB,INFO,FORMS)
% Plots the transformed images
%
% RGB     ... Nx1 cell array with the RGB images
% INFO    ... Nx1 cell array with image informations
% TFORMS  ... (N - 1)x1 cell with transformation information

% Transform the images onto the second image using the calculated transforms
% The figures show the image transformed into the space of the
% consecutive image space. Therefore all outlying data is cut off and
% only overlapping parts are visible

num_imgs = numel(INFO);

figure('name','Images transformed onto consecutive neighbor', 'position', [0, 0, 1920, 600]);

for i = 1:num_imgs-1
    subplot(1, num_imgs-1, i);
    
    height1 = INFO{i}.Height;
    width1 = INFO{i}.Width;
    
    height2 = INFO{i+1}.Height;
    width2 = INFO{i+1}.Width;
    
    scale = [height1 / height2, width1 / width2];
    img_transformed = imtransform(RGB{i}, FORMS{i}, 'XData',[1 width2], 'YData',[1 height2], 'XYScale', scale);
    
    % Create a mask to overlay the transformed image onto the base image
    mask = (img_transformed > 0);
    imshow(mask .* img_transformed + ~mask .* RGB{i+1});
    
    [~,img_name1,~] = fileparts(INFO{i}.Filename);
    [~,img_name2,~] = fileparts(INFO{i+1}.Filename);
    
    title([img_name1, ' onto ', img_name2]);
end

end

