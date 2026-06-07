%% Detector de caracteres alfanuméricos mediante MSER y OCR

% 1°) Visualización en escala de grises
clear
clc
colorImage = imread("imagen1.png");
I = im2gray(colorImage);

% 2°) Aplicación de la técnica MSER
regions = detectMSERFeatures(I);
figure; imshow(I); hold on;
plot(regions,'showPixelList',true,'showEllipses',false);

[mserRegions, mserConnComp] = detectMSERFeatures(I, ...
    "RegionAreaRange",[100 4000], "ThresholdDelta", 3);

figure; imshow(I); hold on;
plot(mserRegions, "showPixelList", true,"showEllipses",false);
title("Región MSER"); hold off;

% 3°) Eliminación de regiones que no sean texto
mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
    'Solidity', 'Extent', 'EulerNumber', 'Image');

bbox = vertcat(mserStats.BoundingBox);
w = bbox(:,3); h = bbox(:,4);
aspectRatio = w./h;

filterIdx = aspectRatio' > 3; 
filterIdx = filterIdx | [mserStats.Eccentricity] > .995;
filterIdx = filterIdx | [mserStats.Solidity] < .3;
filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

mserStats(filterIdx) = [];
mserRegions(filterIdx) = [];

figure; imshow(I); hold on;
plot(mserRegions, 'showPixelList', true,'showEllipses',false);
title('Imagen luego de la eliminación de regiones sin texto'); hold off;

% Basado en la variación del grosor del trazo
strokeWidthThreshold = 0.4;
strokeWidthFilterIdx = false(1,numel(mserStats));

for j = 1:numel(mserStats)
    regionImage = padarray(mserStats(j).Image, [1 1], 0);
    distanceImage = bwdist(~regionImage);
    skeletonImage = bwmorph(regionImage, 'thin', inf);
    strokeWidthValues = distanceImage(skeletonImage);
    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);
    strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;
end

mserRegions(strokeWidthFilterIdx) = [];
mserStats(strokeWidthFilterIdx) = [];

figure; imshow(I); hold on;
plot(mserRegions, 'showPixelList', true,'showEllipses',false);
title('Regiones con texto basado en el ancho del trazo'); hold off;

% 4°) Combinaciones de regiones de texto
bboxes = vertcat(mserStats.BoundingBox);
xmin = bboxes(:,1); ymin = bboxes(:,2);
xmax = xmin + bboxes(:,3) - 1;
ymax = ymin + bboxes(:,4) - 1;

expansionAmount = 0.02;
xmin = (1-expansionAmount) * xmin;
ymin = (1-expansionAmount) * ymin;
xmax = (1+expansionAmount) * xmax;
ymax = (1+expansionAmount) * ymax;

xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, size(I,2));
ymax = min(ymax, size(I,1));

expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
IExpandedBBoxes = insertShape(colorImage,"rectangle",expandedBBoxes,"LineWidth",3);

figure; imshow(IExpandedBBoxes);
title('Cuadros delimitadores expandidos');

overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);
n = size(overlapRatio,1); 
overlapRatio(1:n+1:n^2) = 0;

g = graph(overlapRatio);
componentIndices = conncomp(g);

xmin = accumarray(componentIndices', xmin, [], @min);
ymin = accumarray(componentIndices', ymin, [], @min);
xmax = accumarray(componentIndices', xmax, [], @max);
ymax = accumarray(componentIndices', ymax, [], @max);

textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];

% 5°) Resultados
numRegionsInGroup = histcounts(componentIndices);
textBBoxes(numRegionsInGroup == 1, :) = [];

ITextRegion = insertShape(colorImage, "rectangle", textBBoxes,"LineWidth",3);
figure; imshow(ITextRegion);
title("Texto detectado");

% 6°) Reconocer el texto mediante OCR
ocrtxt = ocr(I, textBBoxes);
disp([ocrtxt.Text]);
