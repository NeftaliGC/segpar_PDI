# Segundo Parcial de Procesamiento de Imagenes Digitales

Identificación de objetos de ferreteria en imágenes 

## Cómo ejecutar el sistema
- ### Opción 1: Ejecutar en App Designer (modo nativo)
    Abrir MATLAB.

    Asegurarse de estar en la carpeta `src/` o agregarla al path de MATLAB:

    ```matlab
    % No necesario si ya estás en la carpeta src
    addpath(genpath('src'))
    ```
    Ejecutar el archivo principal:

    ```matlab
    >> main
    ```
    Esto abrirá la aplicación `interface.mlapp`, lista para interactuar.

    A través de la interfaz, puede cargar imágenes y realizar las pruebas de identificación.

- ### Opción 2: Ejecutar manualmente desde App Designer
    Abrir el archivo `src/+interfaz/interface.mlapp` desde el App Designer.

    Ejecutar la aplicación presionando el botón de Run.


## Cómo funciona:

Cuando se ingresa una imagen al sistema, el procesamiento de imágenes sigue el siguiente flujo:

1. **Conversión a escala de grises**

   - La imagen RGB es convertida a escala de grises usando `rgb2gray()`. Esto reduce la complejidad de procesamiento al trabajar con una sola componente de intensidad.

2. **Binarización adaptativa**

   - Se aplica una binarización adaptativa (`imbinarize()` con `adaptive` y `ForegroundPolarity='dark'`), que permite separar el fondo de los objetos de interés aún con variaciones de iluminación.
   - La sensibilidad del umbral adaptativo está ajustada a `0.6` para balancear detección y ruido.

3. **Filtrado morfológico**

   - Se realizan operaciones morfológicas para limpiar la segmentación:
     - `imopen()` con un elemento estructurante circular de radio 2 elimina pequeñas imperfecciones.
     - `bwareaopen()` elimina objetos pequeños de menos de 200 píxeles, descartando ruido residual.

4. **Extracción de regiones (segmentación)**

   - Se identifican las regiones conectadas usando `regionprops()`, extrayendo un conjunto de características geométricas:
     - Área
     - Perímetro
     - Excentricidad
     - Solidez
     - Extensión
     - Ejes mayor y menor (para Aspect Ratio)
     - Bounding Box (para visualización)
     - Centroid (para anotaciones)

5. **Cálculo de características derivadas**

   - A partir de las medidas básicas, se calculan:
     - **Circularidad**:  
       Circularidad = (4 × π × Área) / (Perímetro²)
     - **Relación de aspecto (Aspect Ratio)**:  
       AspectRatio = (MajorAxisLength) / (MinorAxisLength)

6. **Clasificación por distancia euclidiana ponderada**

   - Cada objeto detectado es comparado contra una base de conocimiento previamente entrenada (`knowledge_base_training.mat`), que contiene ejemplos de características de cada clase.
   - Se calcula la distancia euclidiana ponderada entre el objeto actual y cada muestra de la base:
        > D = √(∑(w_i (f_i - m_i)²))
        
    Donde:
     - \(w_i\): peso de la característica i
     - \(f_i\): característica extraída de la imagen actual
     - \(m_i\): característica de la muestra en la base

   - La clase asignada es la que produce la menor distancia.

7. **Visualización de resultados**

   - Se dibujan los rectángulos de cada objeto detectado sobre la imagen original.
   - Se superpone el nombre de la clase identificada en cada región mediante `rectangle()` y `text()`.

8. **Conteo total de objetos**

   - Finalmente, se contabiliza el número total de objetos detectados en la imagen, basado en el número de regiones procesadas.
