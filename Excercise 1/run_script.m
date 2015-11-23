function run_script( assign, save)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
dir = 'assign';
if ~exist('save','var') || isempty(save)
    save=false;
else
    dir = sprintf('%s%d',dir, assign);
end

if ~exist(dir, 'dir') && save == true
    fprintf('Creating directory %s to save files', dir);
    mkdir(dir);
end

if(assign == 1)
    assign1(dir, save);
elseif(assign == 2)
    assign2(dir, save);
else
    assign3(dir, save);
end

end

function assign1(dir, save)

pics = ['00125v'; '00149v'; '00153v'; '00351v'; '00398v'; '01112v'];
cell = cellstr(pics);
fig = 0;

separator = '####################################';
fprintf('%s\n       Assignment1     \n%s\n\n',separator, separator);

for i = 1 : length(cell)
    
    fig = fig + 1;
    fprintf('Figure %d = Image: %s\n', fig, cell{i});
    Assignment1(cell{i})
    savef(fig, strcat(dir, '\', cell{i}, '_RGB'), save);
    
end
fprintf('\n%s\n       End     \n%s\n',separator, separator);

if save == true
    close all;
end

clear cell;
clear pics;

end

function assign2(dir, save)

pics = ['future'; 'mm    '];
cell = cellstr(pics);
fig = 0;

separator = '####################################';
fprintf('%s\n       Assignment2     \n%s\n',separator, separator);
fprintf('\n');

for i = 1 : length(cell)
    
    fig = fig + 1;
    file = cell{i};
    path = strcat(file, '.jpg');
    
    Assignment2(path, 5)
    fprintf('Figure %d = Image: %s , k = %d, spatial = false\n', fig, file, 5);
    savef(fig, sprintf('%s\\%s_k5_false',dir, file), save);
    
    fig = fig + 1;
    
    Assignment2(path, 5, true)
    fprintf('Figure %d = Image: %s , k = %d, spatial = true\n', fig, file, 5);
    savef(fig, sprintf('%s\\%s_k5_true',dir, file), save);
    
    fprintf('\n');
end
disp(separator);

fprintf('%s\n\n', separator);
k = 2;
file = 'simple';
path = 'simple.png';
for c = 1:4
    
    k = k + c;
    fig = fig + 1;
    
    Assignment2(path, k)
    fprintf('Figure %d = Image: %s , k = %d, spatial = false\n',fig, file, k);
    savef(fig, sprintf('%s\\%s_k%d_false',dir, file, k), save);
    
    fig = fig + 1;
    
    Assignment2(path, k, true)
    fprintf('Figure %d = Image: %s , k = %d, spatial = true\n', fig, file, k);
    savef(fig, sprintf('%s\\%s_k%d_true',dir, file, k), save);
    
    fprintf('\n');
end
fprintf('%s\n       End     \n%s\n',separator, separator);

if save == true
    close all;
end

clear cell;
clear pics;

end

function assign3(dir, save)

pics = ['butterfly'; 'tree     '];
cell = cellstr(pics);
fig = 0;

separator = '####################################';
fprintf('%s\n       Assignment3     \n%s\n\n',separator, separator);

for i = 1 : length(cell)
    
    % normal size
    fig = fig + 1;
    Assignment3(cell{i})
    fprintf('Figure %d = Image: %s\n', fig, cell{i});
    savef(fig, strcat(dir, '\', cell{i}, '_blob'), save);
    
    % half of the size
    filename = scaleAndSave(cell{i}, 0.5);
    fig = fig + 1;
    Assignment3(filename)
    fprintf('Figure %d = Image: %s\n', fig, filename);
    savef(fig, strcat(dir, '\', filename, '_blob'), save);
    
    % double the size
    filename = scaleAndSave(cell{i}, 2);
    fig = fig + 1;
    Assignment3(filename)
    fprintf('Figure %d = Image: %s\n', fig, filename);
    savef(fig, strcat(dir, '\', filename, '_blob'), save);
    
    fprintf('\n');
end
fprintf('%s\n       End     \n%s\n',separator, separator);

if save == true
    close all;
end

clear cell;
clear pics;

end

function [filename] = scaleAndSave(img, scale)

if scale < 1
    filename = strcat(img, '_down_scaled');
else
    filename = strcat(img, '_up_scaled');
end

path = strcat('Data\', filename, '.jpg');

if ~exist(path, 'file')
    path = strcat('Data\', img, '.jpg');
    rescaled = imread(path);
    rescaled = imresize(rescaled, scale);
    imwrite(rescaled, strcat('Data\', filename, '.jpg'));
end

end

function savef(id, name, save)

if save == true
    number = sprintf('-f%d',id);
    print(number, name, '-dpng');
end

end