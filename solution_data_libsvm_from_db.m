% solution_data_libsvm('C:\Users\Leandro\Documents\MATLAB\fault-location-svm-matlab', '4bus-OYOD-UnBal.dss', 1, -1, [])
% solution_data_libsvm('C:\Users\Leandro\Documents\MATLAB\fault-location-svm-matlab', 'IEEE13Nodeckt.dss', 1, 3,{'rg60','680'});
% solution_data_libsvm('C:\Users\Leandro\Documents\MATLAB\fault-location-svm-matlab',
% 'IEEE13Nodeckt.dss', 1, 3, {'680', 'rg60', '675', '646', '684', '670'});

% path 'C:\Users\Leandro\Documents\MATLAB\fault-location-svm-matlab'

% DSStext.Command = 'compile ieee34Mod2.dss'; % Compilar red
% DSStext.Command = 'compile IEEE13Nodeckt.dss'; % Compilar red
% DSStext.Command = 'compile 4bus-OYOD-UnBal.dss'; % Compilar red

% minMeasurements = 1

% maxMeasurements = N --> si es negativo se usa el total de posibles
% medidas en todas las barras

function [final_result, trainX, trainY, testX, testY, pred] = solution_data_libsvm_from_db(localpath, dssFile, minMeasurements, maxMeasurements, container)
clc
cd(localpath); % Seteo directorio actual

% load train
trainDataX = load(fullfile('Data',dssFile,'trainX'));
trainDataX = trainDataX.trainX;
trainDataY = load(fullfile('Data',dssFile,'trainY'));
trainDataY = trainDataY.trainY;
% load test
testDataX = load(fullfile('Data',dssFile,'testX'));
testDataX = testDataX.testX;
testDataY = load(fullfile('Data',dssFile,'testY'));
testDataY = testDataY.testY;
% load cab
cab = load(fullfile('Data',dssFile,'cabecera'));
cab = cab.cab;

addpath('libsvm-3.21/matlab'); % Agrego el path de libsvm

DSSobj = actxserver('OpenDSSengine.DSS'); % Levanto el motor OpenDSS
DSSobj.DataPath = pwd; % Asignar directorio actual como directorio raiz
dssFile = strcat('compile', {' '}, dssFile);
dssFile = dssFile{1};

DSStext = DSSobj.Text;
DSStext.Command = dssFile; % Compilar red
nodes_list = DSSobj.ActiveCircuit.AllBusNames';

result = [];

%-------------------------------------------------------------------------
%---------------------------------Training--------------------------------
%-------------------------------------------------------------------------
if (maxMeasurements < 0)
    maxMeasurements = size(nodes_list, 2);
end

disp('Starting ..........');
total_processed = 0;
for j=minMeasurements:maxMeasurements
    accuraces = [];
    buses = [];
    lines = [];
    opcs = combnk(1:size(nodes_list,2),j);
    for i=1:size(opcs,1)
        
        total_processed = total_processed + 1;
        DSStext.Command = dssFile; % Compilar red
        
        nodes_list = DSSobj.ActiveCircuit.AllBusNames';
        nodes = nodes_list(opcs(i,:));
        
        if (size(container,2) > 0 && ~all(ismember(container,nodes) == 1))
            continue;
        end;
            
        endpoints = [];
        for node = nodes
            endpoints = [endpoints; {getElementsFromBus(DSSobj, node)}];
        end;
        endpoints = endpoints(~cellfun('isempty',endpoints));
        
        if (~isempty(endpoints))
            elementsSet = remove_rows(allcomb(endpoints{:}),size(nodes,2)); % todas las posibles combinaciones de medir elementos
        else
            elementsSet = {};
        end
        
        % ---------------------- Para lo anterior tener en cuenta solo lineas -------------------------------------------
        
        for elements = elementsSet'  % Entreno por cada posible configuracion para obtener la mejor ubicacion de medicion
            elements = remove_rows(elements,1);
            disp('Buses');
            disp(nodes);
            disp('Lines');
            disp(elements);
            
            %---------------------- Generate Faults ---------------------------------
            
            columns = [];
            for node = nodes
                columns = [columns, find(strcmp(cab, node))];
            end;
            
            for element = elements'
                columns = [columns, find(strcmp(cab, element))];
            end;
            
            trainX = trainDataX(:,columns);
            trainY = trainDataY;
            
            tic;
            %---------------------- Scaling Data -------------------------------------
            [trainX, minimums, ranges] = scale_data(trainX);
            %[trainX, mean_, std_] = scale_data2(trainX);
                        
            %---------------------- Cross Validation----------------------------------
            %[bestc, bestg] = cross_validation2(trainX, trainY, 0, 14, -7, 7);
            %cmd = [' -c ', num2str(bestc), ' -g ', num2str(bestg), ' -b 1 -h 1 -q'];
            
            %-------------------------------------------------------------------------
            %----------------------------------- Train -------------------------------
            %-------------------------------------------------------------------------
            disp('-------------')
            disp('Training.....');
            disp('-------------');
            %model = svmtrain(trainY, sparse(trainX), cmd);
            
            model = svmtrain(trainY, sparse(trainX), '-c 32768 -g 2 -b 1 -h 1 -q');
            toc;
            
            %-------------------------------------------------------------------------
            %---------------------------------Clasificación---------------------------
            %-------------------------------------------------------------------------
            
            testX = testDataX(:,columns);
            testY = testDataY;
            
            testX = (testX - repmat(minimums, size(testX, 1), 1)) ./ repmat(ranges, size(testX, 1), 1);
            %testX = bsxfun(@rdivide, bsxfun(@minus, testX, mean_), std_);
            
            [pred, ac, decv] = svmpredict(testY, sparse(testX), model, '-b 1');
            
            
            buses = [buses; nodes];
            elements = [elements', num2cell(zeros(j-length(elements),1)')]
            lines = [lines; elements];
            accuraces = [accuraces; ac(1)];
            saveArrayCellOnCSV(strcat('resultado_ubicando_en_',num2str(j),'_barras_incremental.csv'),[buses num2cell(accuraces,2)]);
        end;
        disp(strcat('-----------porcentage de avance', {' '}, num2str(total_processed/(size(opcs,1)* (maxMeasurements - minMeasurements + 1))),'------------------------'));
    end;
    result = [buses lines num2cell(accuraces,2)];
    saveArrayCellOnCSV(strcat('resultado_ubicando_en_',num2str(j),'_barras_y_lineas_final.csv'),result);
    
    final_result = [buses num2cell(accuraces,2)];
    saveArrayCellOnCSV(strcat('resultado_ubicando_en_',num2str(j),'_barras_final.csv'),final_result);
    container = maxNodesAccuracy(final_result);
end;

end