function [currents, voltages, cabecera] = generate_fault(DSSobj, type, line_bus_line, phase1, phase2, count, resistance, fraction, buses, elements)
%
%                   type 1: S-L-G
%                   type 2: L-L
%                   type 3: L-L-G
%                   type 4: 3-Ph
%
%     |   total*fraccion   | 1 - total*fraccion |
%     |--------------------|--------------------|
%     |                    |                    |
%   bus1                bus_falla              bus2p


total = line_bus_line{1,5};

% Ubico la falla modificando el tamaño de la primera linea
DSSobj.ActiveCircuit.Lines.Name = line_bus_line{1,2};
bus = line_bus_line{1,3};
DSSobj.ActiveCircuit.Lines.Length = total * fraction;

% Asigno el tamaño correspondiente a la segunda linea
DSSobj.ActiveCircuit.Lines.Name = line_bus_line{1,4};
DSSobj.ActiveCircuit.Lines.Length = total - total * fraction;

[voltagesBefore,currentsBefore,cabecera] = getCurrentsAndVoltages(DSSobj, buses, elements);

switch type
    case 1
        fault = strcat(' Fault.fslg', num2str(count));
        DSSobj.Text.Command = strcat('New ', fault, ' bus1=', bus , '.', num2str(phase1), ' phases=1 r=', num2str(resistance));
    case 2
        fault = strcat(' Fault.fll', num2str(count));
        DSSobj.Text.Command = strcat('New ', fault, ' bus1=', bus, '.', num2str(phase1), ' bus2=', bus, '.', num2str(phase2), ' phases=1 r=', num2str(resistance));
    case 3
        fault = strcat(' Fault.fllg', num2str(count));
        DSSobj.Text.Command = strcat('New ', fault, ' bus1=', bus, '.', num2str(phase1), '.', num2str(phase2), ' phases=2 r=', num2str(resistance));
    case 4
        fault = strcat(' Fault.f3p', num2str(count));
        DSSobj.Text.Command = strcat('New ', fault, ' bus1=', bus, '.1.2.3 phases=3 r=', num2str(resistance));
end

DSSobj.Text.Command = 'Solve mode=Dynamics';

if (DSSobj.ActiveCircuit.Solution.Converged)
    [voltagesAfter,currentsAfter,cabecera] = getCurrentsAndVoltages(DSSobj, buses, elements);
    % voltages = voltagesAfter - voltagesBefore;
    % currents = currentsAfter - currentsBefore;
    voltages = voltagesAfter;
    currents = currentsAfter;

else
    currents = zeros(1,length(lines)*6);
    voltages = zeros(1,length(buses)*6);
end

% Deshabilito la falla
DSSobj.Text.Command = strcat(fault, '.enabled=false');
end