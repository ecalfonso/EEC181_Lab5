function [ y ] = func( x )
% Converts sample column from testData into a 28x28 image 
    final = {};

    % Load sample into img
    load testSet.mat;
    img = testData(:, x);
    
    index = 1;
    % Build image
    for i = 1:28
        for j = 1:28
            final{j, i} = img(index, 1);
            index = index + 1;
        end
    end
    
    y = cell2mat(final);
    imshow(y);
end
