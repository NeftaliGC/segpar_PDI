function training()

    % Asignación automática
    clases = {'d', 'a', 'e', 'c', 'd', 'c', 'a', 'b', 'a', 'd'};

    imagen = imread(fullfile(pwd, 'img', 'piezas1.jpg')); % Cambia el nombre de la imagen según sea necesario

    % Cargar imagen
    img = imagen;
    gray = rgb2gray(img);

    % Procesamiento de imagen
    bw = imbinarize(gray, 'adaptive', 'ForegroundPolarity','dark','Sensitivity', 0.6);
    se = strel("disk", 2);
    bw = imopen(bw, se);
    bw = bwareaopen(bw, 200); 

    % Extraer regiones
    stats = regionprops(bw, 'Area', 'Perimeter', 'Eccentricity', ...
        'Solidity', 'Extent', 'MajorAxisLength', 'MinorAxisLength', ...
        'BoundingBox', 'Centroid');

    fig = figure("Visible", "off"); imshow(imagen); hold on;

    % Inicializamos base de conocimiento vacía
    knowledgeBase = struct();

    for i = 1:length(stats)
        s = stats(i);
        circularity = (4 * pi * s.Area) / (s.Perimeter^2);
        aspect_ratio = s.MajorAxisLength / s.MinorAxisLength;

        features = struct( ...
            'Area', s.Area, ...
            'Perimeter', s.Perimeter, ...
            'Eccentricity', s.Eccentricity, ...
            'Solidity', s.Solidity, ...
            'Extent', s.Extent, ...
            'Circularity', circularity, ...
            'AspectRatio', aspect_ratio ...
        );

        label = clases{i};

        if isfield(knowledgeBase, label)
            knowledgeBase.(label)(end+1) = features;
        else
            knowledgeBase.(label) = features;
        end

        % Mostrar progreso
        % fprintf('Objeto %d asignado a clase %s.\n', i, label);
    end

    close(fig);
    % Guardar el dataset
    save('knowledge_base_training.mat','knowledgeBase');
    disp('✅ Base de conocimiento guardada correctamente.');
end
