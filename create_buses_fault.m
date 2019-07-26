function [line_bus_line] = create_buses_fault(DSSobj)
DSStext = DSSobj.Text;

% Estructura para guardar las lineas iguales
line_bus_line = {};

% Colocar bus de falla
DSSActiveCircuit = DSSobj.ActiveCircuit;
DSSLines = DSSActiveCircuit.Lines;
all_lines = DSSLines.AllNames;
count = 1;
while count <= size(all_lines,1)
    line_cell = all_lines(count);
    DSSLines.Name = line_cell{1,1};
    i_line_name = DSSLines.Name;
    i_line_bus2 = DSSLines.bus2;
    i_line_code = DSSLines.LineCode;
    i_line_phases = DSSLines.Phases;
    DSSobj.Text.Command = strcat('? Line.',i_line_name,'.Units');
    i_line_unit = DSSobj.Text.Result;
    
    % Conectar primera parte de la linea al bus de falla
    [~,strnodes] = get_nodes(i_line_bus2);
    faultbus = strcat('fbus_',i_line_name);
    faultbuswhitnodes = strcat(faultbus, strnodes);
    DSSLines.bus2 = faultbuswhitnodes;
    total_length = DSSLines.Length;
    middle_lenght = total_length / 2;
    DSSLines.Length = middle_lenght; % la ubico al 50%
    
    % Creo otra linea igual conectada a la otra barra original
    initial_bus_l2 = faultbuswhitnodes;
    i_line_name_2 = strcat(i_line_name,'_2');
    if (~isempty(i_line_code))
        i_line_code = strcat(' LineCode=', i_line_code);
    end;
    DSStext.Command = strcat('new Line.',i_line_name_2, ' phases=', num2str(i_line_phases), ' bus1=',initial_bus_l2, ' bus2=',i_line_bus2, i_line_code, ' Length=', num2str(middle_lenght), ' units=', i_line_unit);
    
    % guardo la estructura de linea para accederla despues
    row = {count i_line_name faultbus i_line_name_2 total_length};
    line_bus_line(count, :) = row;
    count = count +1; 
end
DSSobj.ActiveCircuit.Solution.Solve;
end