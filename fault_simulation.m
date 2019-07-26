function [data, classes] = fault_simulation(DSSobj, line_bus_line, locations, resistances, sslevel, phases)
data = [];
classes = [];
size_lines = size(line_bus_line,1);

count = 1;
solution_count = 1;
while count <= size_lines
    for ssc = sslevel
        DSSobj.Text.Command = strcat('edit Vsource.source mvasc1=',num2str(ssc),' mvasc3=',num2str(ssc));
        for r = resistances
            for l = locations
                for phase = 1:phases
                    
                    disp('-------------------------------------------------------------');
                    fprintf('      resistencia: %d     ubicación: %d        fase: %d\n', r, l, phase);
                    disp('-------------------------------------------------------------');
                    
                    % Generar Falla Single-line-to-ground
                    [c,v] = fault_slg(DSSobj, line_bus_line(count,:), phase, solution_count, r, l);
                    disp('-------------------------Corrientes--------------------------');
                    disp(c);
                    disp('---------------------------Voltages--------------------------');
                    if (any(c ~= 0) || any(c ~= v))
                        disp(v);
                        data = [data; c v];
                        classes = [classes; 1];
                    end;
                    
                    % Generar Falla Line-to-line
                    [c,v] = fault_ll(DSSobj, line_bus_line(count,:), phase, solution_count, r, l);
                    disp('-------------------------Corrientes--------------------------');
                    disp(c);
                    disp('---------------------------Voltages--------------------------');
                    if (any(c ~= 0) || any(c ~= v))
                        disp(v);
                        data = [data; c v];
                        classes = [classes; 2];
                    end;
                    
                    % Generar Falla Line-to-line-to-groung
                    [c,v] = fault_llg(DSSobj, line_bus_line(count,:), phase, solution_count, r, l);
                    disp('-------------------------Corrientes--------------------------');
                    disp(c);
                    disp('---------------------------Voltages--------------------------');
                    if (any(c ~= 0) || any(c ~= v))
                        disp(v);
                        data = [data; c v];
                     classes = [classes; 3];
                    end;
                    
                    solution_count = solution_count + 1;
                end;
                
                % Generar Falla 3-phases
                [c,v] = fault_3p(DSSobj, line_bus_line(count,:), solution_count, r, l);
                disp('-------------------------Corrientes--------------------------');
                disp(c);
                disp('---------------------------Voltages--------------------------');
                if (any(c ~= 0) || any(c ~= v))
                    disp(v);
                    data = [data; c v];
                    classes = [classes; 4];
                end;
            end;
        end;
    end;
    count = count + 1;
end
data = data(:,1:2:end); % Saco los angulos
end