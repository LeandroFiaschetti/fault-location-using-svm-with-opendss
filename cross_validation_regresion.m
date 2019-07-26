function [bestc, bestg, bestp] = cross_validation_regresion(trainX, trainY, minc, maxc, ming, maxg, minp, maxp)
bestcv = Inf;
for log2c = minc : maxc
    for log2g = ming : maxg
        for log2p = minp :maxp
            cmd = ['-v 10 -s 3 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g), ' -p ', num2str(2^log2p)];
            cv = svmtrain(trainY, sparse(trainX), cmd);
            if (cv < bestcv)
                bestcv = cv;
                bestc = 2^log2c;
                bestg = 2^log2g;
                bestp = 2^log2p;
            end
        end
    end
end
end