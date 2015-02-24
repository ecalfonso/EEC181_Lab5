function [ y ] = sFunc( img )
% Input is the output of imread()
% 	This function takes in an image that is HEIGHT x WIDTH
%	n = WIDTH/HEIGHT =~ # Digits in picture
% 	We try to grab a HEIGHT x HEIGHT sample
    
    %converts image to grayscale
    img = rgb2gray(img);
    
    %number of rows of the matrix
    numROWS = size(img, 1);
    numCOLS = size(img, 2);

	% Get approximate # of digits     
    numDigit = round(numCOLS/numROWS);
    imshow(img);
    
    % Resize the image so it's nicer for detection
    img = imresize(img, [numROWS numROWS*numDigit]);
    numCOLS = size(img, 2);
    
	% Echo something nice
	display('Proposed digits:');

	% Loop through every HEIGHT x HEIGHT section fo the image
	for i = 0:numDigit-1
		
        % Calculate approximate beginning and end col # for ith digit 
		if (i == numDigit-1)
            colBegin = numCOLS - numROWS;
            colEnd = numCOLS;
        else
            colBegin = (i*numROWS) + 1;        
            colEnd = min(colBegin+numROWS, numCOLS);
        end
        
		% Extract that digit
        dig = img(1:numROWS, colBegin:colEnd);
		
		% Resize the img to be 28x28
		dig = imresize(dig, [28 28], 'nearest');
        
		% Convert digit to binary
		bin = im2bw(dig, 0.7);

		% Convert to a linear array for neural network
		lin = bin(:);

		% Put through neural network
		display(neural(lin));
	end
end
