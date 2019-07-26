function [nodes, strnodes] = get_nodes( bus )
v = strsplit(bus, '.');
v = cell(v);
nodes = v(2:length(v));
strnodes = '.';
for element = nodes
    strnodes = strcat(strnodes,char(element),'.');
end
if (length(v) > 1)
    strnodes = strcat(strnodes,char(v(length(v))));
else
    strnodes = '';
end
end

