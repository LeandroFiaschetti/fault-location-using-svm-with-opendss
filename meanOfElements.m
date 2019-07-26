function [result,uniqueCab] = meanOfElements(trainX, cab)
result = [];
    uniqueCab = unique(cab);
    for element = uniqueCab
        indexes = find(strcmp(cab, element) == 1);
        result = [result mean(trainX(:,indexes),2)];
    end
end