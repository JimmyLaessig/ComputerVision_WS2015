function ImageStitching(file_name,num_files)
warning('off','all');
path = sprintf('ass4_data/%s',file_name);

%% TASK A
%taskA(path);


%% TASK B
img_RGB = cell(num_files,1);
trans_img_RGB = cell(num_files,1);
trans_img_str = cell(num_files - 1,1);

for i = 1:num_files - 1
    
    % 1
    file = sprintf('%s%d.jpg',path,i);
    RGB_1 = imread(file);
    BW_1 = single(rgb2gray(RGB_1));
    
    file = sprintf('%s%d.jpg',path, i + 1);
    RGB_2 = imread(file);
    BW_2 = single(rgb2gray(RGB_2));
    
    [RGB, TFORM] = taskB(BW_1, BW_2, RGB_1);
    figure;
    imshow(RGB);
    img_RGB{i} = RGB_1;
    trans_img_RGB{i} = RGB;
    trans_img_str{i} = TFORM;
end

trans_img_RGB{num_files} = imread(sprintf('%s%d.jpg',path,num_files));
img_RGB{num_files} = imread(sprintf('%s%d.jpg',path,num_files));
%% Task C

% 2
trans_img_str{1}.tdata.T = trans_img_str{2}.tdata.T * trans_img_str{1}.tdata.T;
trans_img_str{4}.tdata.Tinv = trans_img_str{3}.tdata.Tinv * trans_img_str{4}.tdata.Tinv;

% 3
ref_tform = trans_img_str{3};
coords = [];
for i = 1:num_files - 1
    
    [height, width] = size(img_RGB{i});
    % y x 1
    coords = cat(2, coords, trans_img_str{i}.tdata.T * [1; 1; 1]);
    coords = cat(2, coords, trans_img_str{i}.tdata.T * [height; 1; 1]);
    coords = cat(2, coords, trans_img_str{i}.tdata.T * [1; width; 1]);
    coords = cat(2, coords, trans_img_str{i}.tdata.T * [height; width; 1]);
end

minX = min(coords(1,:));
maxX = max(coords(1,:));

minY = min(coords(2,:));
maxY = max(coords(2,:));

OUTPUT = [];
for i = 1:num_files
    RGB_t = imtransform(img_RGB{i}, ref_tform,'Xdata',[minX maxX],'Ydata',[minY maxY]);
%     figure;imshow(RGB_t);
    OUTPUT = cat(2,OUTPUT,RGB_t);
end

figure;imshow(OUTPUT);

end

function taskA(path)

file = sprintf('%s%d.jpg',path,1);
RGB = imread(file);
BW = single(rgb2gray(RGB));

F = vl_sift(BW);

imshow(RGB);
vl_plotframe(F);

end

function [TRANS_RGB, TFORM] = taskB(BW_1, BW_2, RGB_1)

[FEATS_1, DESCRS_1] = vl_sift(BW_1);
[FEATS_2, DESCRS_2] = vl_sift(BW_2);

% 2
MATCHES = vl_ubcmatch(DESCRS_1,DESCRS_2);

x = FEATS_1(1,:)';
y = FEATS_1(2,:)';

% Mx2x1
points_1 = [x y];

x = FEATS_2(1,:)';
y = FEATS_2(2,:)';

% Mx2x1
points_2 = [x y];

%h = match_plot(RGB_1, RGB_2,points_1,points_2);
%set(h, 'name', ['Matching without RANSAC: ', file_name, num2str(1), ' to ', file_name, num2str(2)]);

% 3 RANSAC
END_TFORM = [];
max_inliers = 0;
inliers_1 = [];
inliers_2 = [];

for i = 1:1000
    % 4 random positions in MATCHES
    % 1x4x1
    matches_idx = 1:size(MATCHES,2);
    rand_pos = randsample(matches_idx,4);
    
    % 4 indices of points (x y) in correspondig feature matrix
    % 4x1x1
    indices_1 = MATCHES(1,rand_pos);
    indices_2 = MATCHES(2,rand_pos);
    
    % get 4 points (x y) of the features
    % 4x2x1
    rand_points_1 = points_1(indices_1,:);
    rand_points_2 = points_2(indices_2,:);
    
    % get non already selected indices of MATCHES
    accept_idx = logical(matches_idx ~= rand_pos(1) & matches_idx ~= rand_pos(2) & matches_idx ~= rand_pos(3) & matches_idx ~= rand_pos(4));
    putative_idx = matches_idx(accept_idx);
    
    % get indices of points
    p_points_idx_1 = MATCHES(1,putative_idx);
    p_points_idx_2 = MATCHES(2,putative_idx);
    
    % get points
    put_points_1 = points_1(p_points_idx_1,:);
    put_points_2 = points_2(p_points_idx_2,:);
    
    
    try
        % projective transformation
        TFORM = cp2tform(rand_points_1, rand_points_2, 'projective');
        
        % forward transformation for imag1
        [X, Y] = tformfwd(TFORM, put_points_1(:,1), put_points_1(:,2));
        
        % Euclidean distance
        % Mx2x1
        img1_trans_points = [X Y];
        diff = img1_trans_points - put_points_2;
        
        % Mx1x1
        eucl_dist = sqrt(dot(diff,diff,2));
        inliers = logical(eucl_dist < 5);
        num_inliers = sum(inliers);
        
        if num_inliers > max_inliers
            max_inliers = num_inliers;
            END_TFORM = TFORM;
            inliers_1 = img1_trans_points(inliers,:);
            inliers_2 = put_points_2(inliers,:);
        end
        
    catch
        %disp('ERROR WHILE USING cp2tform');
    end
    
end

% 4
TFORM = cp2tform(inliers_1,inliers_2,'projective');

% 5
scale = [size(BW_1,2)/size(BW_2,2) size(BW_1,1)/size(BW_2,1)];
[TRANS_RGB,X,Y ]= imtransform(RGB_1,TFORM,'Xdata',[1 size(BW_2,2)],'Ydata',[1 size(BW_2,1)],'XYScale',scale);

end