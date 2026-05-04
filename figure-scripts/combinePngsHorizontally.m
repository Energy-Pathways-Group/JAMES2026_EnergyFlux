function combinePngsHorizontally(leftPngPath, rightPngPath, outputPngPath, options)
% Combine two PNG images into one horizontally arranged PNG.
%
% `combinePngsHorizontally` reads two PNG image files, centers them
% vertically on a white canvas, inserts optional horizontal spacing between
% them, and writes the combined image to a PNG file.
%
% - Topic: Create figures
% - Declaration: combinePngsHorizontally(leftPngPath, rightPngPath, outputPngPath, HorizontalSpacing=0)
% - Parameter leftPngPath: Path to the PNG image placed on the left.
% - Parameter rightPngPath: Path to the PNG image placed on the right.
% - Parameter outputPngPath: Path where the combined PNG image is written.
% - Parameter HorizontalSpacing: Nonnegative integer spacing between images, in pixels.

arguments (Input)
    leftPngPath (1,1) string {mustBeFile}
    rightPngPath (1,1) string {mustBeFile}
    outputPngPath (1,1) string
    options.HorizontalSpacing (1,1) double {mustBeInteger, mustBeNonnegative} = 0
end

leftImage = readPngAsRgb(leftPngPath);
rightImage = readPngAsRgb(rightPngPath);
horizontalSpacing = options.HorizontalSpacing;

leftSize = size(leftImage);
rightSize = size(rightImage);
combinedHeight = max(leftSize(1), rightSize(1));
combinedWidth = leftSize(2) + horizontalSpacing + rightSize(2);

combinedImage = uint8(255*ones(combinedHeight, combinedWidth, 3));

leftRowStart = floor((combinedHeight - leftSize(1))/2) + 1;
rightRowStart = floor((combinedHeight - rightSize(1))/2) + 1;
rightColumnStart = leftSize(2) + horizontalSpacing + 1;

combinedImage(leftRowStart:(leftRowStart + leftSize(1) - 1), 1:leftSize(2), :) = leftImage;
combinedImage(rightRowStart:(rightRowStart + rightSize(1) - 1), rightColumnStart:(rightColumnStart + rightSize(2) - 1), :) = rightImage;

imwrite(combinedImage, outputPngPath);
end

function rgbImage = readPngAsRgb(pngPath)
[imageData, colorMap, alpha] = imread(pngPath);

if ~isempty(colorMap)
    rgbImage = ind2rgb(imageData, colorMap);
elseif ismatrix(imageData)
    rgbImage = repmat(imageData, 1, 1, 3);
elseif size(imageData, 3) == 3
    rgbImage = imageData;
else
    error("combinePngsHorizontally:InvalidImage", "PNG file %s must contain a grayscale, indexed, RGB, or RGBA image.", pngPath);
end

rgbImage = convertToUint8(rgbImage);

if ~isempty(alpha)
    alpha = double(alpha);
    alphaMaximum = max(alpha(:));
    if alphaMaximum > 0
        alpha = alpha/alphaMaximum;
        alpha = repmat(alpha, 1, 1, 3);
        rgbImage = uint8(double(rgbImage).*alpha + 255*(1 - alpha));
    else
        rgbImage(:) = 255;
    end
end
end

function uint8Image = convertToUint8(imageData)
if isa(imageData, "uint8")
    uint8Image = imageData;
elseif isa(imageData, "uint16")
    uint8Image = uint8(round(double(imageData)/257));
elseif isfloat(imageData)
    uint8Image = uint8(round(255*max(0, min(1, imageData))));
else
    uint8Image = uint8(imageData);
end
end
