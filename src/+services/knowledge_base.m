function knowledge_base = knowledge_base()

    % Lista de piezas
    labels = {'a','b','c','d','e'};
    knowledge_base = struct();

    % Guardamos temporalmente los datos sin normalizar
    temp_data = [];

    for i = 1:length(labels)
        nombre_archivo = fullfile(pwd, 'img', ['pieza_' labels{i} '.jpg']);
        img = imread(nombre_archivo);
        gray = rgb2gray(img);
        bw = imbinarize(gray);
        bw = bwareaopen(bw, 50);
        
        stats = regionprops(bw, 'Area', 'Perimeter', 'Eccentricity', ...
            'Solidity', 'Extent', 'MajorAxisLength', 'MinorAxisLength', 'BoundingBox');
        
        s = stats(1);
        circularity = (4 * pi * s.Area) / (s.Perimeter^2);
        aspect_ratio = s.MajorAxisLength / s.MinorAxisLength;

        % Guardamos los datos sin normalizar
        data = struct( ...
            'Area', s.Area, ...
            'Perimeter', s.Perimeter, ...
            'Eccentricity', s.Eccentricity, ...
            'Solidity', s.Solidity, ...
            'Extent', s.Extent, ...
            'Circularity', circularity, ...
            'AspectRatio', aspect_ratio);

        temp_data = [temp_data; data];
        knowledge_base.(labels{i}).raw = data; % guardamos crudo
    end

    % Ahora calculamos los rangos globales para normalizar
    features = {'Area','Perimeter','Eccentricity','Solidity','Extent','Circularity','AspectRatio'};
    ranges = struct();

    for f = 1:length(features)
        values = arrayfun(@(x) x.(features{f}), temp_data);
        ranges.(features{f}).min = min(values);
        ranges.(features{f}).max = max(values);
    end

    % Guardamos también los rangos en la base de conocimiento
    knowledge_base.ranges = ranges;

    % Finalmente, calculamos los valores normalizados
    for i = 1:length(labels)
        for f = 1:length(features)
            raw_value = knowledge_base.(labels{i}).raw.(features{f});
            min_v = ranges.(features{f}).min;
            max_v = ranges.(features{f}).max;
            norm_value = (raw_value - min_v) / (max_v - min_v);
            knowledge_base.(labels{i}).norm.(features{f}) = norm_value;
        end
    end

    save('knowledge_base.mat', 'knowledge_base');

    for i = 1:length(labels)
        fprintf('Pieza %s:\n', labels{i});
        for f = 1:length(features)
            fprintf('  %s: %.4f\n', features{f}, knowledge_base.(labels{i}).norm.(features{f}));
        end
    end

end
