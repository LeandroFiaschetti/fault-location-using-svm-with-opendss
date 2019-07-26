function [trainX, trainY, trainfaultinfo, cab, testX, testY, testfaultinfo] = GenerateFaultDB(localpath, dssFile)

clc
cd(localpath);

DSSobj = actxserver('OpenDSSengine.DSS'); % Levanto el motor OpenDSS
DSSobj.DataPath = pwd; % Asignar directorio actual como directorio raiz
dssCommandCompile = strcat('compile', {' '}, dssFile);
dssCommandCompile = dssCommandCompile{1};

DSStext = DSSobj.Text;
DSStext.Command = dssCommandCompile; % Compilar red

nodes = DSSobj.ActiveCircuit.AllBusNames';
elements = strcat('Line.',DSSobj.ActiveCircuit.Lines.AllNames);
elements = elements';

bd = create_buses_fault(DSSobj); % Creo buses de falla en cada linea
locations = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]; % ubicacion de la falla
resistances = [10, 20, 30, 40]; % resistencias de falla
%sslevel = [20,40,60,80,100]; % Potencias de corto circuito
sslevel = [1];

tic;
disp('-------------------Generando datos de Training---------------------');
[trainX, trainY, trainfaultinfo, cab] = fault_simulation2(DSSobj, bd, locations, resistances, sslevel, nodes, elements);
disp('-------------------------------------------------------------------');

DSStext.Command = dssCommandCompile; % Compilar red
bd = create_buses_fault(DSSobj); % Creo buses de falla en cada linea
            
locations = [0.15, 0.25, 0.45, 0.65, 0.85]; % ubicacion de la falla
resistances = [10, 20, 30, 40]; % resistencias de falla
%sslevel = [10,30,50,70,90]; % Potencias de corto circuito
sslevel = [1];

disp('-------------------Generando datos de Test-------------------------');
[testX, testY, testfaultinfo] = fault_simulation2(DSSobj, bd, locations, resistances, sslevel, nodes, elements); % Genero diferentes fallas
disp('-------------------------------------------------------------------');

disp('----------------------Guardando datos------------------------------');
mkdir(fullfile('Data',dssFile));
save(fullfile('Data',dssFile,'trainX.mat'), 'trainX');
save(fullfile('Data',dssFile,'trainY.mat'), 'trainY');
save(fullfile('Data',dssFile,'trainfaultinfo.mat'), 'trainfaultinfo');
save(fullfile('Data',dssFile,'testX.mat'), 'testX');
save(fullfile('Data',dssFile,'testY.mat'), 'testY');
save(fullfile('Data',dssFile,'testfaultinfo.mat'), 'testfaultinfo');
save(fullfile('Data',dssFile,'cabecera.mat'), 'cab');

toc;
disp('Fin Generacion');