function [ y ] = sFunc(finalB1L1, finalB1L2, finalW1L1, finalW1L2, finalSoftmaxTheta)
% Running this will use imread() to take an image from
%	http://eec181.ece.ucdavis.edu:8081/photo.jpg
% This will:
%	1) Take the current displayed image
%	2) Extract the Region of Interest (roi), the black box with white digits
%	3) Use digit separation to put digits through the nerual network
%	4) Put digits through the neural network to find a proposed digit
%	5) Repeat for as many digits we believe are in the image

    % Set timer to measure time performance
    tic

    % Set variables
    % Arrays for ast and 2nd layer
    Z1 = {};
    Z2 = {};
    Z3 = {};
 
    % Load weights and biases
    w1 = finalW1L1(:,:);
    w2 = finalW1L2(:,:);
    w3 = finalSoftmaxTheta(:,:);
    b1 = finalB1L1(:,:);
    b2 = finalB1L2(:,:);

	% Grab image
    img = imread('http://eec181.ece.ucdavis.edu:8081/photo.jpg');
    %img = imread('img27.jpg');
    
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
    %row = ~row;
    %col = ~col;
    
    % Get array where row_ind(1) == first part of white area
    %   row_ind(end) should be the end of the projector area
    row_indeces = find(row == 0);
    
    % Get array where col_ind(1) == first part of white area
    %   col_ind(end) should be the end of the projector area
    col_indeces = find(col == 0);
    
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
    
    % This makes the final ROI finer
    final = im2bw(final, 0.7999999);
    %imshow(final);
    % Return roi
    roi = final;
    imshow(roi);
    pause(1);
    
    % -----------------------------------------------------------
    % Attempt to get digits
    % -----------------------------------------------------------
    
    %number of rows of the matrix
    numROWS = size(roi, 1);
    numCOLS = size(roi, 2);
    
    %imshow(roi);
    %display(numROWS);
    %display(numCOLS);
    %pause(3);
    
	% Get approximate # of digits     
    numDigit = round(numCOLS/numROWS);
    %display(numDigit);
    
    % Resize the image so it's nicer for detection
    roi = imresize(roi, [numROWS numROWS*numDigit]);
    numCOLS = size(roi, 2);
    
    product = 0;
    
	% Echo something nice
	%display('Proposed digits:');
    
	% Loop through every HEIGHT x HEIGHT section fo the image
	for i = 0:numDigit-1
		
        % Calculate approximate beginning and end col # for ith digit 
		if (i == numDigit-1)
            colBegin = numCOLS - numROWS;
            colEnd = numCOLS;
        else % For every other digit
            colBegin = (i*numROWS) + 1;        
            colEnd = min(colBegin+numROWS, numCOLS);
        end
        
		% Extract that digit
        digit = roi(1:numROWS, colBegin:colEnd);
		
		% Resize the img to be 28x28
		digit = imresize(digit, [28 28], 'bicubic');
        imshow(digit);
        pause(0.5);

		% Convert to a linear array for neural network
		linear = digit(:);

		% Put through neural network
        Z1 = w1*linear;
        Z1 = Z1 + b1;
        nZ1 = Z1 * -1;
        for j = 1:200
            Z1(j, 1) = 1/(1+exp(nZ1(j, 1)));
        end
        
        Z2 = w2*Z1;
        Z2 = Z2 + b2;
        nZ2 = Z2 * -1;
        for k = 1:200
            Z2(k, 1) = 1/(1+exp(nZ2(k, 1)));
        end
        
        Z3 = w3*Z2;
        
        pos = 0;
        lowest = -1000000;
        for l = 1:10
            if Z3(l, 1) > lowest
                lowest = Z3(l, 1);
                pos = l;
            end
        end
        
        product = product + 10^(2-i)*mod(pos, 10);
    end

    % end timer and display elapsed time
    toc

	%display('Done!');
    y = product;
end

