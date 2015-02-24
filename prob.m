load testSet.mat;
list = testLabels(:, 1);
count = 0;
for j = 1:10000
    if neural(j) == list(j, 1)
        count = count + 1;
    end
end