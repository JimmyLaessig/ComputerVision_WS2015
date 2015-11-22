function Assignment3
img = im2double(imread('Data/butterfly.jpg'));
blobDetection(img, 2, 1.25, 10);
end


function blobDetection(img, sigma_0, k, levels)
%INPUT
% img ... the image to detect the scales from
% sigma_0 ... the start sigma for the LoG Filter
% k ... the scale factor for sigma
% levels ... the number of levels

%OUTPUT
[height,width] = size(img);
% levels - number of levels in the scale space
scale_space = zeros(height,width,levels);
sigma_k = sigma_0 / k;
% Calculate filtered image for each k
for i = 1:levels
    % Scale sigma
    sigma_k = floor(sigma_k * k);
    %sigma_k = sigma_0;
    log_filter = fspecial('log', 2 * 3 * sigma_k + 1, sigma_k);
    log_filter = log_filter * (sigma_k * sigma_k); % Normalize filter by multiplying with sigma^2
    
    filtered_image = imfilter(img, log_filter, 'same', 'replicate');
    
    scale_space(:,:,i) = filtered_image(:,:);
end

% Non Maximum Suppresion
for x=1:height
    for y=1:width
        for h = 1:levels
            neighborhood = zeros(26);
            
            % Value of the point at level h
            value = abs(scale_space(x, y, h));
            
            % Search within a 3x3x3 neighborhood for local maxima
            indices = zeros(26, 3);
            
            %% Level - 1
            if(x > 1 && y > 1 && h > 1)          indices(1,:) = [x - 1, y - 1, h - 1]; end
            if(x > 1 && h > 1)                   indices(2,:) = [x - 1, y    , h - 1]; end
            if(x > 1 && y < width && h > 1)      indices(3,:) = [x - 1, y + 1, h - 1]; end
            
            if(y > 1 && h > 1)                   indices(4,:) = [x, y - 1, h - 1];     end
            if(h > 1)                            indices(5,:) = [x, y    , h - 1];     end
            if(y < width && h > 1)               indices(6,:) = [x, y + 1, h - 1];     end
            
            if(x < height && y > 1 && h > 1)     indices(7,:) = [x + 1, y - 1, h - 1]; end
            if(x < height && h > 1)              indices(8,:) = [x + 1, y    , h - 1]; end
            if(x < height && y < width && h > 1) indices(9,:) = [x + 1, y + 1, h - 1]; end
            
            %% Same Level
            if(x > 1 && y > 1)     indices(10,:) = [x - 1 , y - 1, h]; end
            if(x > 1)              indices(11,:) = [x - 1 , y    , h]; end
            if(x > 1 && y < width) indices(12,:) = [x - 1 , y + 1, h]; end
            
            if(y > 0)              indices(13,:) = [x, y - 1, h]; end
                                 %%indices(14,:) = [x, y    , h]; %% current value
            if(y < width)          indices(15,:) = [x, y + 1, h]; end           
            
            if(x < height && y > 0)     indices(16,:) = [x + 1 , y - 1, h]; end
            if(x < height)              indices(17,:) = [x + 1 , y    , h]; end
            if(x < height && y < width) indices(18,:) = [x + 1 , y + 1, h]; end
            
            %% Level + 1
            if(x > 1 && y > 1 && h < levels)     indices(19,:) = [x - 1 , y - 1, h + 1]; end
            if(x > 1 &&  h < levels)             indices(20,:) = [x - 1 , y    , h + 1]; end
            if(x > 1 && y < width && h < levels) indices(21,:) = [x - 1 , y + 1, h + 1]; end
            
            if( y > 1 && h < levels)     indices(22,:) = [x, y - 1, h + 1]; end
            if( h < levels)              indices(23,:) = [x, y    , h + 1]; end
            if( y < width && h < levels) indices(24,:) = [x, y + 1, h + 1]; end
            
            if(x < height && y > 1 && h < levels)     indices(25,:) = [x + 1 , y - 1, h + 1]; end
            if(x < height && h < levels)              indices(26,:) = [x + 1 , y    , h + 1]; end
            if(x < height && y < width && h < levels) indices(27,:) = [x + 1 , y + 1, h + 1]; end
            
            % Filter out illegal indices
            
        end
    end
    
end

end