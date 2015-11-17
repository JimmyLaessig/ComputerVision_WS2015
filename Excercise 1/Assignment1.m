%% Performs all necccecary steps for Assigmnent 1
function Assignment1

path = 'Data\00125v';
type = '.jpg';
h = fspecial('gauss', [1 20])
r = im2double(imread(strcat(path , '_R' , type)));
g = im2double(imread(strcat(path , '_G' , type)));
b = im2double(imread(strcat(path , '_B' , type)));

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
[width, height] = size(r(:,:));
max = -Inf;
min = Inf;
for i=1:width - 29
    for j=1:height - 29
       
       r_window = r(i : i+29 , j : j+29);
       g_window = g(i : i+29 , j : j+29);
       b_window = b(i : i+29 , j : j+29);
       % g_window = g(x_min:x_max , y_min:y_max);
        ncc = corr2(r_window, g_window);
        if (ncc > max)
            max = ncc;
        end
        if (ncc < min)
            min = ncc;
        end
    end
end


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