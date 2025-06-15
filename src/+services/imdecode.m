function img = imdecode(imgBytes, fmt)
    % Decodifica matriz de bytes PNG/JPEG a imagen RGB
    tempFile = ['temp' '.' fmt];
    fid = fopen(tempFile, 'w');
    fwrite(fid, imgBytes);
    fclose(fid);
    img = imread(tempFile);
    delete(tempFile);
end

