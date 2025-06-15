function imgBytes = imencode(img, fmt)
    % Crea un archivo temporal
    tempFile = [tempname '.' fmt];
    
    % Escribir imagen en archivo
    imwrite(img, tempFile);
    
    % Leer los bytes del archivo en modo binario
    fid = fopen(tempFile, 'rb');  % <-- aquí el cambio crítico
    imgBytes = fread(fid, inf, '*uint8');
    fclose(fid);
    
    % Eliminar el archivo temporal
    delete(tempFile);
end
