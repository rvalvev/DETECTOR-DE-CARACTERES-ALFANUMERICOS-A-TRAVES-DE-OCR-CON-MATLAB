# Detector de Caracteres Alfanuméricos mediante OCR

Proyecto desarrollado para la asignatura de Procesamiento Digital de Señales (DSP), cuyo objetivo es detectar y reconocer caracteres alfanuméricos presentes en señaléticas mediante técnicas de procesamiento digital de imágenes implementadas en MATLAB.

## Descripción

El reconocimiento óptico de caracteres (OCR) es una técnica utilizada para identificar y digitalizar texto contenido en imágenes. Sin embargo, la aplicación directa de OCR sobre imágenes reales suele producir resultados imprecisos debido a la presencia de ruido, variaciones de iluminación y elementos que no corresponden a texto.

Este proyecto implementa un sistema de detección de texto basado en el algoritmo MSER (Maximally Stable Extremal Regions), complementado con filtros geométricos y análisis del ancho del trazo para identificar regiones que contienen caracteres alfanuméricos antes de aplicar OCR.

## Objetivos

* Detectar regiones candidatas a contener texto.
* Eliminar regiones que no correspondan a caracteres alfanuméricos.
* Agrupar caracteres individuales en palabras o líneas de texto.
* Aplicar OCR sobre las regiones detectadas.
* Mejorar la precisión del reconocimiento de texto en señaléticas.

## Metodología

### 1. Conversión a escala de grises

La imagen de entrada es convertida a escala de grises utilizando la función `im2gray`, reduciendo la complejidad del procesamiento y facilitando la detección de regiones de interés.

```matlab
colorImage = imread("imagen1.png");
I = im2gray(colorImage);
```

### 2. Detección de regiones MSER

Se utiliza el algoritmo MSER para localizar regiones estables con características compatibles con texto.

```matlab
[mserRegions, mserConnComp] = detectMSERFeatures(I,...
    "RegionAreaRange",[100 4000],...
    "ThresholdDelta",3);
```

Los parámetros fueron ajustados para detectar regiones cuyo tamaño es consistente con caracteres alfanuméricos presentes en señaléticas.

### 3. Filtrado de regiones no textuales

Las regiones detectadas son evaluadas mediante propiedades geométricas obtenidas con `regionprops`.

Se consideran los siguientes criterios:

* Relación de aspecto.
* Excentricidad.
* Solidez.
* Extensión.
* Número de Euler.

Las regiones que no cumplen los umbrales definidos son eliminadas para reducir falsos positivos.

### 4. Filtrado mediante variación del ancho del trazo

Las regiones de texto suelen presentar un grosor relativamente uniforme en sus trazos.

Para analizar esta característica se utilizan:

```matlab
distanceImage = bwdist(~regionImage);
skeletonImage = bwmorph(regionImage,'thin',inf);
```

Posteriormente se calcula la métrica:

```matlab
strokeWidthMetric = std(strokeWidthValues) / mean(strokeWidthValues);
```

Las regiones cuya variación supera el umbral establecido son descartadas.

### 5. Agrupación de regiones de texto

Las regiones válidas son agrupadas mediante análisis de superposición de cuadros delimitadores.

```matlab
overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);
```

A continuación se construye un grafo de conectividad para unir regiones pertenecientes a una misma palabra o línea de texto.

```matlab
g = graph(overlapRatio);
componentIndices = conncomp(g);
```

### 6. Reconocimiento óptico de caracteres

Finalmente se aplica OCR sobre las regiones detectadas para extraer el contenido textual.

```matlab
ocrtxt = ocr(I, textBBoxes);
disp([ocrtxt.Text]);
```

## Flujo de Procesamiento

```text
Imagen de entrada
        │
        ▼
Conversión a escala de grises
        │
        ▼
Detección MSER
        │
        ▼
Filtrado geométrico
        │
        ▼
Filtrado por ancho del trazo
        │
        ▼
Agrupación de regiones
        │
        ▼
Detección de texto
        │
        ▼
OCR
        │
        ▼
Texto reconocido
```

## Tecnologías Utilizadas

* MATLAB
* Image Processing Toolbox
* OCR Toolbox
* Algoritmo MSER
* Técnicas de Procesamiento Digital de Imágenes

## Ejecución

1. Colocar la imagen de entrada en el directorio del proyecto.
2. Modificar el nombre del archivo si es necesario:

```matlab
colorImage = imread("imagen1.png");
```

3. Ejecutar el script principal en MATLAB.
4. El programa mostrará cada etapa del procesamiento:

   * Regiones MSER detectadas.
   * Regiones filtradas.
   * Cuadros delimitadores expandidos.
   * Texto detectado.
   * Resultado final del OCR.

## Resultados

Las pruebas realizadas sobre distintas señaléticas demostraron que la aplicación directa de OCR sobre imágenes sin preprocesamiento produce resultados poco precisos.

La combinación del algoritmo MSER, filtros geométricos y análisis del ancho del trazo permitió mejorar significativamente la detección de texto y la posterior etapa de reconocimiento óptico de caracteres.

Además, el sistema fue evaluado utilizando diferentes tipos de señaléticas, obteniendo resultados satisfactorios tras ajustar parámetros como el área de detección y el ancho del trazo.

## Autores

-Rodrigo Valenzuela Vera

-Javiera Bustos Pinto

**Académico:** Dr. Ali Dehghanfirouzabadi

## Referencias

[1] Chen, Huizhong, et al. *Robust Text Detection in Natural Images with Edge-Enhanced Maximally Stable Extremal Regions*. Image Processing (ICIP), 2011 18th IEEE International Conference on. IEEE, 2011.

[2] Gonzalez, Alvaro, et al. *Text Location in Complex Images*. Pattern Recognition (ICPR), 2012 21st International Conference on. IEEE, 2012.

[3] Li, Yao, and Huchuan Lu. *Scene Text Detection via Stroke Width*. Pattern Recognition (ICPR), 2012 21st International Conference on. IEEE, 2012.

[4] Neumann, Lukas, and Jiri Matas. *Real-time Scene Text Localization and Recognition*. Computer Vision and Pattern Recognition (CVPR), 2012 IEEE Conference on. IEEE, 2012.

## Licencia

Proyecto desarrollado con fines académicos para la asignatura de Procesamiento Digital de Señales (DSP).
