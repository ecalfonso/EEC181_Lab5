function [ out ] = roi( img )
% Input should be the output of imread()
% Finds region of interest from input image
%   We know we want an set of digits within a black box,
%   withing a white box, that's somewhere in the image

% ---------------------------------------------------------------
% Get white projector image
% ---------------------------------------------------------------

% Get image dimensions
imgROWS = size(img, 1);
imgCOLS = size(img, 2);

% Create edge buffer of 10%
imgTop = round(imgROWS * .1);
imgBot = imgROWS - imgTop;
imgLeft = round(imgCOLS * .1);
imgRight = imgCOLS - imgLeft;

% Turn into grayscale with new dimensions
gray = rgb2gray(img);
gray = gray(imgTop:imgBot, imgLeft:imgRight);

% generate summations of rows and cols
% This generates a numROWS x 1 matrix of the sum of all rows
row = sum(gray, 2);
row_max = max(row);
row_avg = mean(row);

% This generates a 1 x numCOLS martix of the sum of all cols
col = sum(gray, 1);
col_max = max(col);
col_avg = mean(col);

% Normalize row and col
row = row/row_max;
col = col/col_max;

% And convert to binary to show light distribution
%   All pretty black areas will be represented by 0s
%   All white areas will be 1s
row_level = ((row_max+row_avg)/2)/row_max;
row = im2bw(row, row_level);
col_level = ((col_max+col_avg)/2)/col_max;
col = im2bw(col, col_level);

% Get array where row_ind(1) == first part of white area
%   row_ind(end) should be the end of the projector area
row_indeces = find(row);

% Get array where col_ind(1) == first part of white area
%   col_ind(end) should be the end of the projector area
col_indeces = find(col);

% Create crop, region of the projector
crop = gray(row_indeces(1):row_indeces(end), col_indeces(1):col_indeces(end));

% Get cropped image dimensions
cropROWS = size(crop, 1);
cropCOLS = size(crop, 2);

% Create edge buffer of 10%
cropTop = round(cropROWS * .1);
cropBot = cropROWS - cropTop;
cropLeft = round(cropCOLS * .1);
cropRight = cropCOLS - cropLeft;

% New image with 5% edge buffer
crop = crop(cropTop:cropBot, cropLeft:cropRight);

% ---------------------------------------------------------------
% Get black ROI image
% ---------------------------------------------------------------

% generate summations of rows and cols
% This generates a matrix of the sum of all rows
row = sum(crop, 2);
row_max = max(row);
row_avg = mean(row);

% This generates a martix of the sum of all cols
col = sum(crop, 1);
col_max = max(col);
col_avg = mean(col);

% Normalize row and col
row = row/row_max;
col = col/col_max;

% Normalize row and col
% And convert to binary to show light distribution
%   All pretty black areas will be represented by 0s
%   All white areas will be 1s
%row_level = ((row_max+row_avg)/2)/row_max;
row = im2bw(row, 0.9);
%col_level = ((col_max+col_avg)/2)/col_max;
col = im2bw(col, 0.9);

% Invert 
row = ~row;
col = ~col;

% Get array where row_ind(1) == first part of white area
%   row_ind(end) should be the end of the projector area
row_indeces = find(row);

% Get array where col_ind(1) == first part of white area
%   col_ind(end) should be the end of the projector area
col_indeces = find(col);

% Create crop, region of the projector
final = crop(row_indeces(1):row_indeces(end), col_indeces(1):col_indeces(end));

% Get cropped image dimensions
finalROWS = size(final, 1);
finalCOLS = size(final, 2);

% Create edge buffer of 5%
finalTop = round(finalROWS * 0.05);
finalBot = finalROWS - finalTop;
finalLeft = round(finalCOLS * 0.025);
finalRight = finalCOLS - finalLeft;

% New image with 5% edge buffer
final = final(finalTop:finalBot, finalLeft:finalRight);

final = im2bw(final, 0.5);
imshow(final);
% Return roi
out = final;
end
