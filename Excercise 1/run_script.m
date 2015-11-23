function run_script( assign_number )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


end

function assign1()

pics = ['00125v'; '00149v'; '00153v'; '00351v'; '00398v'; '01112v'];
cell = cellstr(pics);

for i = 1 : length(cell)
    Assignment1(cell{i})
end

clear cell;
clear pics;

end

function assign2()

pics = ['future.jpg'; 'mm.jpg    '; 'simple.png'];
cell = cellstr(pics);

separator = '####################################';

disp(separator);
for i = 1 : length(cell)
    
    Assignment2(cell{i}, 5)
    fprintf('Image: %s , k = %d, spatial = false\n', cell{i}, 5);
    
    Assignment2(cell{i}, 5, true)
    fprintf('Image: %s , k = %d, spatial = true\n', cell{i}, 5);
    
    fprintf('\n');
end
disp(seperator);

disp(separator);
k = 2;
for c = 1:4
    k = k + c;
    
    Assignment2(cell{i}, k)
    fprintf('Image: %s , k = %d, spatial = false\n',  cell{2}, k);
    
    Assignment2(cell{i}, k, true)
    fprintf('Image: %s , k = %d, spatial = true\n', cell{2}, k);
    
    fprintf('\n');
end
disp(seperator);


clear cell;
clear pics;

end

function assign3()



end
