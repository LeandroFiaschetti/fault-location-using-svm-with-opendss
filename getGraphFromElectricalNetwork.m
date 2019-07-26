function [graph, busesID] = getGraphFromElectricalNetwork(DSSobj)
buses = DSSobj.ActiveCircuit.AllBusNames;
busesID = containers.Map;
for i=1:size(buses,1)
    busesID(buses{i}) = i;
end;

graph = zeros(size(DSSobj.ActiveCircuit.AllBusNames,1));

actualLine = DSSobj.ActiveCircuit.Lines.First;
while (actualLine ~= 0)
    strBus1 = strsplit(DSSobj.ActiveCircuit.Lines.Bus1,'.');
    bus1 = strBus1{1};
    strBus2 = strsplit(DSSobj.ActiveCircuit.Lines.Bus2,'.');
    bus2 = strBus2{1};
    posBus1 = busesID(bus1);
    posBus2 = busesID(bus2);
    graph(posBus1,posBus2) = DSSobj.ActiveCircuit.Lines.Length;
    actualLine = DSSobj.ActiveCircuit.Lines.Next;
end;

