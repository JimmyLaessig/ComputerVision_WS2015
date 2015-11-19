%% Performs all necccecary steps for Assigmnent 1
function Assignment1(pic_name)
% INPUT
% pic_name ... the name of the picture

%read pictures
path = strcat('Data\', pic_name);
type = '.jpg';

r = im2double(imread(strcat(path , '_R' , type)));
g = im2double(imread(strcat(path , '_G' , type)));
b = im2double(imread(strcat(path , '_B' , type)));

% alignment
r_shift = alignChannel(r, b);
g_shift = alignChannel(g, b);
coloredImage = cat(3, r_shift, g_shift, b);

% show output
plotResults(r, g, b, coloredImage);

end

%% Aligns a color channel to another and returns the aligned channel
function [ aligned_I ] = alignChannel(I, ref_I)
%INPUT
% I     ... the channel which will be aligned
% ref_I ... the channel which will be used as reference for aligment

% OUTPUT
% aligned_I ... correctly aligned channel

max = 0;
shifts_x = 0;
shifts_y = 0;

for i = -15 : 15
    for j = -15 : 15
        
        shifted_I = circshift(I, [i j]);
        ncc = corr2(shifted_I, ref_I);
        
        if(max < ncc)
            max = ncc;
            shifts_y = i;
            shifts_x = j;
        end
    end
end

aligned_I = circshift(I, [shifts_y shifts_x]);

end


%% Plots the given images into a figure next to each other.
function plotResults(r, g, b, coloredImage)
% INPUT
% r            ... raw red color channel of the image
% g            ... raw green color channel of the image
% b            ... raw blue color channel of the image
% coloredImage ... the colored image

[width, height] = size(r(:,:));

% Create a rgb image for each color channel in order to visualize the
% corresponding color

red = cat(3, r, zeros(width, height), zeros(width, height));
green = cat(3, zeros(width, height),g , zeros(width, height));
blue = cat(3, zeros(width, height), zeros(width, height), b);
img = vertcat(red, green, blue);

figure;
subplot( 1, 2, 1) ,imshow (img), title('Color Channels');
subplot(1, 2, 2), imshow (coloredImage), title('Colored Image');
end