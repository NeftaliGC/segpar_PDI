function [result, objetos] = identificarObjetos(imagen)

    % Cargar la base de conocimiento generada durante el entrenamiento
    load('knowledge_base_training.mat', 'knowledgeBase');

    % Cargar imagen de trabajo
    img = imagen;
    gray = rgb2gray(img);

    % Binarización (ajustable)
    bw = imbinarize(gray, 'adaptive', 'ForegroundPolarity','dark','Sensitivity', 0.6);
    se = strel("disk", 2);
    bw = imopen(bw, se);
    bw = bwareaopen(bw, 200); 

    % Obtener regiones
    stats = regionprops(bw, 'Area', 'Perimeter', 'Eccentricity', ...
        'Solidity', 'Extent', 'MajorAxisLength', 'MinorAxisLength', ...
        'BoundingBox', 'Centroid');

    % Generamos la figura (pero la hacemos invisible para no mostrarla si no se desea)
    fig = figure('Visible','off'); 
    imshow(imagen);
    hold on;

    labels = fieldnames(knowledgeBase);
    resultados = {};

    % Ponderaciones (puedes ajustar)
    w = struct('Area',0.01,'Perimeter',0.1,'Eccentricity',1,'Solidity',1,'Extent',1,'Circularity',2,'AspectRatio',1);

    objetos = length(stats);

    for i = 1:length(stats)
        s = stats(i);
        circularity = (4 * pi * s.Area) / (s.Perimeter^2);
        aspect_ratio = s.MajorAxisLength / s.MinorAxisLength;

        objeto = struct( ...
            'Area', s.Area, ...
            'Perimeter', s.Perimeter, ...
            'Eccentricity', s.Eccentricity, ...
            'Solidity', s.Solidity, ...
            'Extent', s.Extent, ...
            'Circularity', circularity, ...
            'AspectRatio', aspect_ratio ...
        );

        mejor_match = '';
        mejor_distancia = inf;

        for j = 1:length(labels)
            clase = labels{j};
            muestras = knowledgeBase.(clase);

            distancias = zeros(1, length(muestras));
            for k = 1:length(muestras)
                m = muestras(k);
                distancias(k) = sqrt( ...
                    w.Area * (objeto.Area - m.Area)^2 + ...
                    w.Perimeter * (objeto.Perimeter - m.Perimeter)^2 + ...
                    w.Eccentricity * (objeto.Eccentricity - m.Eccentricity)^2 + ...
                    w.Solidity * (objeto.Solidity - m.Solidity)^2 + ...
                    w.Extent * (objeto.Extent - m.Extent)^2 + ...
                    w.Circularity * (objeto.Circularity - m.Circularity)^2 + ...
                    w.AspectRatio * (objeto.AspectRatio - m.AspectRatio)^2 ...
                );
            end

            distancia_clase = min(distancias);

            if distancia_clase < mejor_distancia
                mejor_distancia = distancia_clase;
                mejor_match = clase;
            end
        end

        resultados{i} = mejor_match;

        % Mostrar resultados en consola (opcional)
        % fprintf('Objeto %d: mejor coincidencia: %s (distancia: %.4f)\n', i, mejor_match, mejor_distancia);

        % Dibujar en la imagen
        rectangle('Position', s.BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
        text(s.Centroid(1), s.Centroid(2), mejor_match, 'Color','b','FontSize',20,'FontWeight','bold');
    end

    % Capturamos la imagen renderizada como resultado
    frame = getframe(gca);
    result = frame.cdata;

    % Cerramos la figura oculta
    close(fig);
end
