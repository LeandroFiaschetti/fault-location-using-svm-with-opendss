function [solution, sol_values, solution_general] = feature_selection(dssFile, nodes, elements)

addpath('libsvm-3.21/matlab'); % Agrego el path de libsvm

% -------------- Inicializar variables ----------------------

% load train
trainX = load(fullfile('Data',dssFile,'trainX'));
trainX = trainX.trainX;
trainY = load(fullfile('Data',dssFile,'trainY'));
trainY = trainY.trainY;
trainfaultinfo = load(fullfile('Data',dssFile,'trainfaultinfo'));
trainfaultinfo = trainfaultinfo.trainfaultinfo;

% load test
testX = load(fullfile('Data',dssFile,'testX'));
testX = testX.testX;
testY = load(fullfile('Data',dssFile,'testY'));
testY = testY.testY;
testfaultinfo = load(fullfile('Data',dssFile,'testfaultinfo'));
testfaultinfo = testfaultinfo.testfaultinfo;

% load cab
cab = load(fullfile('Data',dssFile,'cabecera'));
cab = cab.cab;

% ------------- Obtener datos ------------------------------

columns = [];
for node = nodes
    columns = [columns, find(strcmp(cab, node))];
end;

for element = elements
    columns = [columns, find(strcmp(cab, element))];
end;

trainX = trainX(:,columns);
trainX = [trainX trainY];
testX = testX(:,columns);
testX = [testX testY];
cab = cab(columns);

% ------------- Entrenar --------------------------------------

%[trainX, minimums, ranges] = scale_data(trainX);
%testX = (testX - repmat(minimums, size(testX, 1), 1)) ./ repmat(ranges, size(testX, 1), 1);

uniqueCab = unique(cab);

solution = {};
sol_values = [];

trainXInicial = trainX;
testXInicial = testX;

i = 0;
solution_general = [];

for elementCabSup = uniqueCab
    i = i + 1;
    j = 0;
    minMSE = Inf;
    for elementCab = uniqueCab
        j = j + 1;
        if (find(strcmp(elementCab, solution)))
            solution_general(i,j) = 0;
            continue;
        end;
        
        trainX = trainXInicial;
        testX = testXInicial;
        
        columns = [];
        
        partialSolution = solution;
        
        actualNodes = [partialSolution elementCab];
        for node = actualNodes
            columns = [columns, find(strcmp(cab, node))];
        end;
        
        trainX = trainX(:,columns);
        trainX = [trainX trainY];
        
        testX = testX(:,columns);
        testX = [testX testY];
        
        disp('------------------------------SLG----------------------------------');
        
        trainX_slg = trainX(trainfaultinfo(:,7) == 1,:);
        testX_slg = testX(testfaultinfo(:,7) == 1,:);
        
        trainY_slg = trainfaultinfo(trainfaultinfo(:,7) == 1,8);
        testY_slg = testfaultinfo(testfaultinfo(:,7) == 1,8);
        
        disp('-------------');
        disp('Training.....');
        disp('-------------');
        
        % [bestc,bestg,bestp] = cross_validation_regresion(trainX_slg, trainY_slg, 1, 14, -7, -1, -7, -1);
        % cmd = ['-s 3 -c ', num2str(bestc), ' -g ', num2str(bestg), ' -p ', num2str(bestp)];
        % model_slg = svmtrain(trainY_slg, sparse(trainX_slg), cmd);
        
        model_slg = svmtrain(trainY_slg, sparse(trainX_slg), '-s 3 -c 32768 -g 0.806 -e 0.8');
        
        disp('-------------')
        disp('Testing.....');
        disp('-------------');
        [pred, ac, decv] = svmpredict(testY_slg, sparse(testX_slg), model_slg);
        
        mseSLG = immse(testY_slg,pred);
        solution_general(i,j) = mseSLG;
        
        if (mseSLG < minMSE)
            minMSE = mseSLG;
            solution(i) = elementCab;
            sol_values(i) = minMSE;
        end
        
        subplot(4, 1, 1)
        plot(1:size(testY_slg,1),testY_slg); hold on;
        plot(1:size(testY_slg,1),pred);
        drawnow
        
        disp('------------------------------LL----------------------------------')
        
        trainX_ll = trainX(trainfaultinfo(:,7) == 2,:);
        testX_ll = testX(testfaultinfo(:,7) == 2,:);
        
        trainY_ll = trainfaultinfo(trainfaultinfo(:,7) == 2,8);
        testY_ll = testfaultinfo(testfaultinfo(:,7) == 2,8);
        
        disp('-------------')
        disp('Training.....');
        disp('-------------');
        
        % [bestc,bestg,bestp] = cross_validation_regresion(trainX_ll, trainY_ll, 1, 14, -7, -1, -7, -1);
        % cmd = ['-s 3 -c ', num2str(bestc), ' -g ', num2str(bestg), ' -p ', num2str(bestp)];
        % model_ll = svmtrain(trainY_ll, sparse(trainX_ll), cmd);
        
        model_ll = svmtrain(trainY_ll, sparse(trainX_ll), '-s 3 -c 32768 -g 0.806 -e 0.8');
        
        disp('-------------')
        disp('Testing.....');
        disp('-------------');
        [pred, ac, decv] = svmpredict(testY_ll, sparse(testX_ll), model_ll);
        
        subplot(4, 1, 2)
        plot(1:size(testY_ll,1),testY_ll); hold on;
        plot(1:size(testY_ll,1),pred);
        drawnow
        
        disp('------------------------------LLG----------------------------------')
        
        trainX_llg = trainX(trainfaultinfo(:,7) == 3,:);
        testX_llg = testX(testfaultinfo(:,7) == 3,:);
        
        trainY_llg = trainfaultinfo(trainfaultinfo(:,7) == 3,8);
        testY_llg = testfaultinfo(testfaultinfo(:,7) == 3,8);
        
        disp('-------------');
        disp('Training.....');
        disp('-------------');
        
        % [bestc,bestg,bestp] = cross_validation_regresion(trainX_llg, trainY_llg, 1, 14, -7, -1, -7, -1);
        % cmd = ['-s 3 -c ', num2str(bestc), ' -g ', num2str(bestg), ' -p ', num2str(bestp)];
        % model_llg = svmtrain(trainY_llg, sparse(trainX_llg), cmd);
        
        model_llg = svmtrain(trainY_llg, sparse(trainX_llg), '-s 3 -c 32768 -g 0.806 -e 0.8');
        
        disp('-------------')
        disp('Testing.....');
        disp('-------------');
        [pred, ac, decv] = svmpredict(testY_llg, sparse(testX_llg), model_llg);
        
        subplot(4, 1, 3)
        plot(1:size(testY_llg,1),testY_llg); hold on;
        plot(1:size(testY_llg,1),pred);
        drawnow
        
        disp('------------------------------LLLG----------------------------------')
        
        trainX_lllg = trainX(trainfaultinfo(:,7) == 4,:);
        testX_lllg = testX(testfaultinfo(:,7) == 4,:);
        
        trainY_lllg = trainfaultinfo(trainfaultinfo(:,7) == 4,8);
        testY_lllg = testfaultinfo(testfaultinfo(:,7) == 4,8);
        
        disp('-------------')
        disp('Training.....');
        disp('-------------');
        
        % [bestc,bestg,bestp] = cross_validation_regresion(trainX_lllg, trainY_lllg, 1, 14, -7, -1, -7, -1);
        % cmd = ['-s 3 -c ', num2str(bestc), ' -g ', num2str(bestg), ' -p ', num2str(bestp)];
        % model_lllg = svmtrain(trainY_lllg, sparse(trainX_lllg), cmd);
        
        model_lllg = svmtrain(trainY_lllg, sparse(trainX_lllg), '-s 3 -c 32768 -g 0.806 -e 0.8');
        
        disp('-------------')
        disp('Testing.....');
        disp('-------------');
        [pred, ac, decv] = svmpredict(testY_lllg, sparse(testX_lllg), model_lllg);
        
        subplot(4, 1, 4)
        plot(1:size(testY_lllg,1),testY_lllg); hold on;
        plot(1:size(testY_lllg,1),pred);
        drawnow
        
    end
end
end