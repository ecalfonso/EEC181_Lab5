function [ y ] = neural( img )
% Puts testData sample column x and puts it through the nerual network
%	It returns the most probable digit it recognizes

    % Arrays for 1st and 2nd layer
    Z1 = {};
    Z2 = {};
    Z3 = {};
    
    % Load weights and biases
    % load NN.mat;
    w1 = finalW1L1(:,:);
    w2 = finalW1L2(:,:);
    w3 = finalSoftmaxTheta(:,:);
    b1 = finalB1L1(:,:);
    b2 = finalB1L2(:,:);
    
    Z1 = w1*img;
    Z1 = Z1 + b1;
    nZ1 = Z1 * -1;
    for i = 1:200
        Z1(i, 1) = 1/(1+exp(nZ1(i, 1)));
    end

    Z2 = w2*Z1;
    Z2 = Z2 + b2;
    nZ2 = Z2 * -1;
    for i = 1:200
        Z2(i, 1) = 1/(1+exp(nZ2(i, 1)));
    end
    
    Z3 = w3*Z2;

    pos = 0;
    max = -1000000;
    for i = 1:10
        if Z3(i, 1) > max
            max = Z3(i, 1);
            pos = i;
        end
    end

    y = mod(pos, 10);
end
