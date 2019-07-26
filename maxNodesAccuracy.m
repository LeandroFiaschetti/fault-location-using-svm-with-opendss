function [max_row] = maxNodesAccuracy(nodes)
last_column = nodes(1,size(nodes,2));
max = last_column{1};
max_row = nodes(1,1:size(nodes,2)-1);
for i =1:size(nodes,1)
    last_column = nodes(i,size(nodes,2));
    if last_column{1} > max
        max = last_column{1};
        max_row = nodes(i,1:size(nodes,2)-1);
    end
end;
end