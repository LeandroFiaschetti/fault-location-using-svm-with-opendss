function [ cell_array_output ] = remove_rows( cell_array_input, nodeSize)
% Esta funcion se encarga de:
% 1 - Borrar todas las filas que tengan al menos un elemento repetido
% 2 - Borrar las filas cuyos elementos sean iguales a otra fila, sin
%     importar el orden en que estos se encuentren

cell_array_output = {};


% Borro las que tienen el mismo elemento
% for x = cell_array_input(:,:)'
%     sizeOriginal = size(x);
%     sizeRepeated = size(unique(x));
%     if (sizeOriginal == sizeRepeated)
%         cell_array_output(end+1,:) = x;
%     end;
% end;

cell_array_output = cell_array_input;

sizeInput = size(cell_array_output);
rows = sizeInput(1);

indexToDelet = [];

% Borro los que tienen menos elementes que la cantidad de nodos porque se
% supone que se mide tension en barra y corriente en linea
% for i=1:rows
%     if (size(cell_array_output(i,:),2) ~= nodeSize)
%         indexToDelet = [indexToDelet; i];
%     end
% end

% Borro las filas iguales
for i=1:rows-1
    for j=(i+1):rows
        if (all(ismember(cell_array_output(i,:),cell_array_output(j,:))) == 1)
            indexToDelet = [indexToDelet; j];
        end;
    end;
end;

for pos=unique(indexToDelet)
    cell_array_output(pos,:) = [];
end;

end

