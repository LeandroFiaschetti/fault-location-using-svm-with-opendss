function [data, classes, faultinfo, cab] = fault_simulation2(DSSobj, line_bus_line, locations, resistances, sslevel, buses, lines)
data = [];
voltages = [];
currents = [];
faultinfo = [];
classes = [];
size_lines = size(line_bus_line,1);

count = 1;
solution_count = 1;
a = 1;
whilecount = 1;

disp('generando fallas monofasicas');

while whilecount <= size_lines
    bd_actual = line_bus_line(whilecount,:);
    DSSobj.ActiveCircuit.Buses(bd_actual{1,3});
    nodes = DSSobj.ActiveCircuit.ActiveBus.Nodes;
    phases = combnk(nodes,1)';
    for ssc = sslevel
        %DSSobj.Text.Command = strcat('edit Vsource.source mvasc1=',num2str(ssc),' mvasc3=',num2str(ssc));
        for r = resistances
            for l = locations
                for phase = phases
                    % Generar Falla Single-line-to-ground
                    [c,v,cab] = generate_fault(DSSobj, 1, bd_actual, phase, 0, solution_count, r, l, buses, lines);
                    [graph, busesID] = getGraphFromElectricalNetwork(DSSobj);
                    distance = graphshortestpath(sparse(graph), busesID('rg60'), busesID(bd_actual{1,3}));
                    DSStext = DSSobj.Text;
                    DSStext.Command = 'compile IEEE13Nodeckt.dss';
                    line_bus_line = create_buses_fault(DSSobj);
                    if (any(c ~= 0) || any(v ~= 0))
                        voltages = [voltages; v];
                        currents = [currents; c];
                        classes = [classes; count];
                        faultinfo = [faultinfo;double(ssc) double(r) double(l) double(phase) double(0) double(0) 1 distance];
                        a = a + 1;
                    end;
                    solution_count = solution_count + 1;
                end;
            end;
        end;
    end;
    count = count + 1;
    whilecount = whilecount + 1;
end

disp('generando fallas bifasicas');
whilecount = 1;
while whilecount <= size_lines
    bd_actual = line_bus_line(whilecount,:);
    DSSobj.ActiveCircuit.Lines.Name = bd_actual{1,2};
    DSSobj.ActiveCircuit.Buses(bd_actual{1,3});
    nodes = DSSobj.ActiveCircuit.ActiveBus.Nodes;
    if length(nodes) > 1
        phases = combnk(nodes,2)';
        for ssc = sslevel
            %DSSobj.Text.Command = strcat('edit Vsource.source mvasc1=',num2str(ssc),' mvasc3=',num2str(ssc));
            for r = resistances
                for l = locations
                    for phase = phases
                        % Generar Falla Line-to-line
                        [c,v] = generate_fault(DSSobj, 2, bd_actual, phase(1), phase(2), solution_count, r, l, buses, lines);
                        [graph, busesID] = getGraphFromElectricalNetwork(DSSobj);
                        distance = graphshortestpath(sparse(graph), busesID('rg60'), busesID(bd_actual{1,3}));
                        DSStext = DSSobj.Text;
                        DSStext.Command = 'compile IEEE13Nodeckt.dss';
                        line_bus_line = create_buses_fault(DSSobj);
                        if (any(c ~= 0) || any(v ~= 0))
                            voltages = [voltages; v];
                            currents = [currents; c];
                            classes = [classes; count];
                            faultinfo = [faultinfo; double(ssc) double(r) double(l) double(phase(1)) double(phase(2)) double(0) 2 distance];
                            a = a + 1;
                        end;
                        solution_count = solution_count + 1;
                    end;
                end;
            end;
        end;
    end;
    count = count + 1;
    whilecount = whilecount + 1;
end

disp('generando fallas bifasicas a tierra');
whilecount = 1;
while whilecount <= size_lines
    bd_actual = line_bus_line(whilecount,:);
    DSSobj.ActiveCircuit.Lines.Name = bd_actual{1,2};
    DSSobj.ActiveCircuit.Buses(bd_actual{1,3});
    nodes = DSSobj.ActiveCircuit.ActiveBus.Nodes;
    if length(nodes) > 1
        phases = combnk(nodes,2)';
        for ssc = sslevel
            %DSSobj.Text.Command = strcat('edit Vsource.source mvasc1=',num2str(ssc),' mvasc3=',num2str(ssc));
            for r = resistances
                for l = locations
                    for phase = phases
                        
                        % Generar Falla Line-to-line-to-groung
                        [c,v] = generate_fault(DSSobj, 3, bd_actual, phase(1), phase(2), solution_count, r, l, buses, lines);
                        [graph, busesID] = getGraphFromElectricalNetwork(DSSobj);
                        distance = graphshortestpath(sparse(graph), busesID('rg60'), busesID(bd_actual{1,3}));
                        DSStext = DSSobj.Text;
                        DSStext.Command = 'compile IEEE13Nodeckt.dss';
                        line_bus_line = create_buses_fault(DSSobj);
                        if (any(c ~= 0) || any(v ~= 0))
                            voltages = [voltages; v];
                            currents = [currents; c];
                            classes = [classes; count];
                            faultinfo = [faultinfo; double(ssc) double(r) double(l) double(phase(1)) double(phase(2)) double(0) 3 distance];
                            a = a + 1;
                        end;
                        solution_count = solution_count + 1;
                    end;
                end;
            end;
        end;
    end;
    count = count + 1;
    whilecount = whilecount + 1;
end

disp('generando fallas trifasicas');
whilecount = 1;
while whilecount <= size_lines
    bd_actual = line_bus_line(whilecount,:);
    DSSobj.ActiveCircuit.Lines.Name = bd_actual{1,2};
    DSSobj.ActiveCircuit.Buses(bd_actual{1,3});
    nodes = DSSobj.ActiveCircuit.ActiveBus.Nodes;
    if length(nodes) > 2
        for ssc = sslevel
            %DSSobj.Text.Command = strcat('edit Vsource.source mvasc1=',num2str(ssc),' mvasc3=',num2str(ssc));
            for r = resistances
                for l = locations
                    % Generar Falla 3-phases
                    [c,v] = generate_fault(DSSobj, 4, bd_actual, 0, 0, solution_count, r, l, buses, lines);
                    [graph, busesID] = getGraphFromElectricalNetwork(DSSobj);
                    distance = graphshortestpath(sparse(graph), busesID('rg60'), busesID(bd_actual{1,3}));
                    DSStext = DSSobj.Text;
                    DSStext.Command = 'compile IEEE13Nodeckt.dss';
                    line_bus_line = create_buses_fault(DSSobj);
                    if (any(c ~= 0) || any(v ~= 0))
                        voltages = [voltages; v];
                        currents = [currents; c];
                        classes = [classes; count];
                        faultinfo = [faultinfo; double(ssc) double(r) double(l) double(1) double(2) double(3) 4 distance];
                        a = a + 1;
                    end;
                    solution_count = solution_count + 1;
                end;
            end;
        end;
    end;
    count = count + 1;
    whilecount = whilecount + 1;
end

data = [currents voltages];
%data = voltages
data = data(:,1:2:end); % Saco los angulos
end