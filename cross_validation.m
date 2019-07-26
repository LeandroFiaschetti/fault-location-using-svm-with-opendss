function [bestc, bestg] = cross_validation(trainX, trainY, minc, maxc, ming, maxg)
bestcv = 0;
for log2c = minc : maxc
    for log2g = ming : maxg
        cmd = ['-v 10 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
        cv = svmtrain(trainY, sparse(trainX), cmd);
        if (cv >= bestcv)
            bestcv = cv;
            bestc = 2^log2c;
            bestg = 2^log2g;
        end
    end
end
end