function [pred, ac, decv] = ovrpredict(y, x, model)

labelSet = model.labelSet;
labelSetSize = length(labelSet);
models = model.models;
decv= zeros(size(y, 1), labelSetSize);

for k=1:labelSetSize
    [~,~,p] = svmpredict(double(y==k), x, models{k}, '-b 1');
    decv(:,k) = p(:,models{k}.Label==1);    %# probability of class==k
end

% for i=1:labelSetSize
%   [~,~,d] = svmpredict(double(y == labelSet(i)), x, models{i}, '-b 1');
%   decv(:, i) = d * (2 * models{i}.Label(1) - 1);
% end

[~,pred] = max(decv, [], 2);
pred = labelSet(pred);
ac = sum(y==pred) / size(x, 1);
end
