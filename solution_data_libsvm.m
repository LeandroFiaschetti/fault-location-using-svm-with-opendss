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

function [final_result, trainX, trainY, testX, testY, pred] = solution_data_libsvm(localpath, dssFile, minMeasurements, maxMeasurements, container)
clc
cd(localpath); % Seteo directorio actual

addpath('libsvm-3.21/matlab'); % Agrego el path de libsvm
addpath('Multiclassify'); % Agrego el path de libsvm

DSSobj = actxserver('OpenDSSengine.DSS'); % Levanto el motor OpenDSS
DSSobj.DataPath = pwd; % Asignar directorio actual como directorio raiz
dssFile = strcat('compile', {' '}, dssFile);
dssFile = dssFile{1};

DSStext = DSSobj.Text;
DSStext.Command = dssFile; % Compilar red
nodes_list = DSSobj.ActiveCircuit.AllBusNames';

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
            getElementsFromBus(DSSobj, node);
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
            disp('Buses');
            disp(nodes);
            disp('Lines');
            disp(elements);
            
            DSStext.Command = dssFile;
            
            bd = create_buses_fault(DSSobj); % Creo buses de falla en cada linea
            
            %---------------------- Generate Faults ---------------------------------
            locations = [0.1, 0.3, 0.5, 0.7, 0.9]; % ubicacion de la falla
            resistances = [0.0001, 25, 50, 75]; % resistencias de falla
            sslevel = [20,40,60,80]; % Potencias de corto circuito
            
            [trainX, trainY, trainfaultinfo, cab] = fault_simulation2(DSSobj, bd, locations, resistances, sslevel, nodes, elements);
            save('x.mat','trainX');
            save('x_nodes_elements','nodes','elements');
            save('x_cabecera','cab');
            
            %scatter3(trainX(:,1),trainX(:,2),trainX(:,3),5,trainY);
            figure
            subplot(1, 2, 1)
            scatter(trainX(:,1),trainX(:,2),5,trainY);
            drawnow
            
            %---------------------- Scaling Data -------------------------------------
            [trainX, minimums, ranges] = scale_data(trainX);
            %[trainX, mean_, std_] = scale_data2(trainX);
            
            subplot(1, 2, 2)
            scatter(trainX(:,1),trainX(:,2),5,trainY);
            drawnow
            %scatter3(trainX(:,1),trainX(:,2),trainX(:,3),5,de2bi(trainY - 1));
            
            %---------------------- Cross Validation----------------------------------
            %[bestc, bestg] = cross_validation2(trainX, trainY, 0, 14, -7, 7);
            %cmd = [' -c ', num2str(bestc), ' -g ', num2str(bestg), ' -b 1'];
            
            %-------------------------------------------------------------------------
            %----------------------------------- Train -------------------------------
            %-------------------------------------------------------------------------
            disp('-------------')
            disp('Training.....');
            disp('-------------');
            %model = svmtrain(trainY, sparse(trainX), cmd);
            model = svmtrain(trainY, sparse(trainX), '-c 32768 -g 2 -b 1 -h 1 -q');
            
            %-------------------------------------------------------------------------
            %---------------------------------Clasificación---------------------------
            %-------------------------------------------------------------------------
            
            %DSStext.Command = 'compile 4bus-OYOD-UnBal.dss'; % Compilar red
            DSStext.Command = dssFile; % Compilar red
            
            bd = create_buses_fault(DSSobj); % Creo buses de falla en cada linea
            
            locations = [0.2, 0.4, 0.6]; % ubicacion de la falla
            resistances = [15, 30, 60]; % resistencias de falla
            sslevel = [30,50,70]; % Potencias de corto circuito
            
            [testX, testY, testfaultinfo] = fault_simulation2(DSSobj, bd, locations, resistances, sslevel, nodes, elements); % Genero diferentes fallas
            testX = (testX - repmat(minimums, size(testX, 1), 1)) ./ repmat(ranges, size(testX, 1), 1);
            %testX = bsxfun(@rdivide, bsxfun(@minus, testX, mean_), std_);
            
            [pred, ac, decv] = svmpredict(testY, sparse(testX), model, '-b 1');
            
            buses = [buses; nodes];
            accuraces = [accuraces; ac(1)];
            saveArrayCellOnCSV(strcat('resultado_ubicando_en_',num2str(j),'_barras_incremental.csv'),[buses num2cell(accuraces,2)]);
        end;
        disp(strcat('-----------porcentage de avance', {' '}, num2str(total_processed/(size(opcs,1)* (maxMeasurements - minMeasurements + 1))),'------------------------'));
    end;
    final_result = [buses num2cell(accuraces,2)];
    saveArrayCellOnCSV(strcat('resultado_ubicando_en_',num2str(j),'_barras_final.csv'),final_result);
    container = maxNodesAccuracy(final_result);
end;
end