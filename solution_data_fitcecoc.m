clc
clear
cd 'D:\Documents\MATLAB\Fallas Simulación'; % Seteo directorio actual
DSSobj = actxserver('OpenDSSengine.DSS'); % Levanto el motor OpenDSS
DSSobj.DataPath = pwd; % Asignar directorio actual como directorio raiz

DSStext = DSSobj.Text;
DSStext.Command = 'compile 4bus-OYOD-UnBal.dss'; % Compilar red

bd = create_buses_fault(DSSobj); % Creo buses de falla en cada linea

%-------------------------------------------------------------------------
%---------------------------------Training--------------------------------
%-------------------------------------------------------------------------

locations = [0.1, 0.2, 0.3, 0.5, 0.7, 0.9]; % ubicacion de la falla
resistances = [1, 25, 50, 75, 100]; % resistencias de falla
sslevel = [20,40,60,80,100]; % Potencias de corto circuito
phases = 3; % numero de fases de la red

[train, labels] = fault_simulation2(DSSobj, bd, locations, resistances, sslevel, phases); % Genero diferentes fallas

t = templateSVM('Standardize',1,'KernelFunction','rbf');
Model = fitcecoc(train,labels,'Learners',t); % Entreno un svm con los datos simulados
Model = crossval(Model);

%-------------------------------------------------------------------------
%---------------------------------Clasificación---------------------------
%-------------------------------------------------------------------------
DSStext.Command = 'compile 4bus-OYOD-UnBal.dss'; % Compilar red
bd = create_buses_fault(DSSobj); % Creo buses de falla en cada linea

locations = [0.15, 0.25, 0.35, 0.55, 0.75, 0.95]; % ubicacion de la falla
resistances = [1, 40, 60, 90]; % resistencias de falla
sslevel = [30,50,70]; % Potencias de corto circuito
phases = 3; % numero de fases de la red

[to_predict, result] = fault_simulation2(DSSobj, bd, locations, resistances, sslevel, phases); % Genero diferentes fallas
prediction = predict(Model,to_predict);
%result = predict(Model,to_predict);

%comp = strcmp(prediction, result);
[cantidad,posicion]=find(result == prediction);
ig=length(cantidad);
similitud=ig*100/size(result,1);
disp(similitud);
