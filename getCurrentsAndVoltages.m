function [voltages,currents,cabecera] = getCurrentsAndVoltages(DSSobj,buses,elements)

currents = [];
voltages = [];
cabecera = [];

% Obtengo las tensiones en cada nodo especificado en Nodos
for bus = buses
    DSSobj.ActiveCircuit.Buses(bus{1});
    v = DSSobj.ActiveCircuit.ActiveBus.VMagAngle;
    i = 0;
    voltages = [voltages v];
    
    
    %       para guardar la cabecera
    for vo = v
        if (i == 0)
            cabecera{length(cabecera)+1} = bus{1};
            i = 1;
        else i = 0;
        end;
    end;
    
end

for element = elements
    % Obtengo las Corrientes en cada elemento especificado en Elements
    DSSobj.ActiveCircuit.SetActiveElement(element{1});
    numnodes = DSSobj.ActiveCircuit.ActiveElement.NumConductors;
    c = DSSobj.ActiveCircuit.ActiveElement.CurrentsMagAng(1:numnodes * 2);
    i = 0;
    currents = [currents c];
    
    %       para guardar la cabecera
    for co = c
        if (i == 0)
            cabecera{length(cabecera)+1} = element{1};
            i = 1;
        else i = 0;
        end;
    end;
end

