clc;
close all;
clear;

% Create a temporary imgfildata.mat if it does not exist
if ~isfile('imgfildata.mat')
    % Create a dummy character database
    imgfile = cell(2, 1);
    imgfile{1, 1} = rand(42, 24) > 0.5; % Random binary image as a placeholder
    imgfile{2, 1} = 'A';               % Corresponding character
    save('imgfildata.mat', 'imgfile');
    disp('Temporary imgfildata.mat file created.');
end

% Load the character database
load imgfildata;

% Choose an image file
[file, path] = uigetfile({'*.jpg;*.bmp;*.png;*.tif'}, 'Choose an image');
if isequal(file, 0)
    disp('No file selected. Exiting...');
    return;
end
s = fullfile(path, file);

% Read and preprocess the image
picture = imread(s);
[~, cc] = size(picture);
picture = imresize(picture, [500 700]);

if size(picture, 3) == 3
    picture = rgb2gray(picture);
end

threshold = graythresh(picture);
picture = ~im2bw(picture, threshold);
picture = bwareaopen(picture, 30);
imshow(picture);

if cc > 2000
    picture1 = bwareaopen(picture, 3500);
else
    picture1 = bwareaopen(picture, 3000);
end
figure, imshow(picture1);

picture2 = picture - picture1;
figure, imshow(picture2);

picture2 = bwareaopen(picture2, 200);
figure, imshow(picture2);

% Label connected components
[L, Ne] = bwlabel(picture2);
propied = regionprops(L, 'BoundingBox');
hold on;
pause(1);
for n = 1:size(propied, 1)
    rectangle('Position', propied(n).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2);
end
hold off;

% Process and match each component
figure;
final_output = [];
t = [];
for n = 1:Ne
    [r, c] = find(L == n);
    n1 = picture(min(r):max(r), min(c):max(c));
    n1 = imresize(n1, [42, 24]);
    imshow(n1);
    pause(0.2);
    x = [];

    totalLetters = size(imgfile, 2);

    for k = 1:totalLetters
        y = corr2(imgfile{1, k}, n1);
        x = [x y];
    end

    t = [t max(x)];
    if max(x) > 0.45
        z = find(x == max(x));
        out = cell2mat(imgfile(2, z));
        final_output = [final_output out];
    end
end

% Save the output to a text file
file = fopen('number_Plate.txt', 'wt');
fprintf(file, '%s\n', final_output);
fclose(file);
winopen('number_Plate.txt');
