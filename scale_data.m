function [trainX, minimums, ranges] = scale_data(trainX)
minimums = min(trainX, [], 1);
ranges = max(trainX, [], 1) - minimums;
trainX = (trainX - repmat(minimums, size(trainX, 1), 1)) ./ repmat(ranges, size(trainX, 1), 1);
end