%% Performs all necccecary steps for Assigmnent 1
function Assignment1

path = 'Data\00125v';
type = '.jpg';
r = imread(strcat(path , '_R' , type));
g = imread (strcat(path , '_G' , type));
b = imread(strcat(path , '_B' , type));

coloredImage = alignChannels(r, g, b);

plotResults(r, g, b, coloredImage);

end

%% Calculate the matching for the given color channels and produces a
% aligned rgb image
function[coloredImage]  = alignChannels(r, g, b)
%INPUT
% r            ... raw red color channel of the image
% g            ... raw green color channel of the image
% b            ... raw blue color channel of the image

% OUTPUT
% coloredImage ... color aligned corrected image 


%% TODO: Calculate real colored image
coloredImage = cat(3, r, g, b);
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