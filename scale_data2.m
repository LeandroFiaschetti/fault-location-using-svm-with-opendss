function [trainX, mean_, std_] = scale_data2(trainX)
mean_ = mean(trainX);
std_ = std(trainX);
% Normalizamos las features a partir de estos valores
trainX = bsxfun(@rdivide, bsxfun(@minus, trainX, mean_), std_);

end