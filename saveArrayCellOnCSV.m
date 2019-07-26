function saveArrayCellOnCSV(name, cellArray)
    fid = fopen(name,'wt');
     if fid>0
         for k=1:size(cellArray,1)
             for m=1:size(cellArray(k,:),2)-1
                fprintf(fid,'%s,',cellArray{k,m});
             end
             fprintf(fid,'%f\n',cellArray{k,size(cellArray(k,:),2)});
         end
         fclose(fid);
     end
end
