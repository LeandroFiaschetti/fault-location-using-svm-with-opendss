function [elements] = getElementsFromBus(DSSobj, bus)
elements = {};

% PC Elements
% count = DSSobj.ActiveCircuit.FirstPCElement;
% while (count > 0)
%     buses = DSSobj.ActiveCircuit.ActiveElement.BusNames;
%     for n = 1:numel(buses)
%         busname = strsplit(buses{n},'.');
%         busname = busname{1};
%         if (strcmp(busname,bus))
%             elements(end+1) = {DSSobj.ActiveCircuit.ActiveElement.Name};
%         end;
%     end;
%     count = DSSobj.ActiveCircuit.NextPCElement;
% end;

% PD Elements
count = DSSobj.ActiveCircuit.FirstPDElement;
while (count > 0)
    buses = DSSobj.ActiveCircuit.ActiveElement.BusNames;
    for n = 1:numel(buses)
        busname = strsplit(buses{n},'.');
        busname = busname{1};
        if (strcmp(busname,bus))
            if (~isempty(findstr('Line.',DSSobj.ActiveCircuit.ActiveElement.Name)))
                elements(end+1) = {DSSobj.ActiveCircuit.ActiveElement.Name};
            end;
        end;
    end;
    count = DSSobj.ActiveCircuit.NextPDElement;
end;