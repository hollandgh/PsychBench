function image = imreadish(fileName)

% image = imreadish(fileName)
%
% Adds some automation to MATLAB imread(). Outputs an L/RGB/RGBA image matrix.
% 
% Currently:
%
% - Reads any transparency information in file into RGBA alpha channel
% - Converts color map image to RGB(A)
% - Normalizes RGB(A) to 0-1 using bit depth in file
% - Applies any orientation information in file


% Giles Holland 2024


[image, colorMap, alpha] = imread(fileName);

%Disable warning cause of buggy warning in MATLAB
warning('off', 'imageio:tifftagsread:badTagValueDivisionByZero');
imageInfo = imfinfo(fileName);

if strcmp(imageInfo.ColorType, 'indexed')
    %Look for transparency info
    ii_transparentPixels = [];
    if isfield(imageInfo, 'TransparentColor')
        t = imageInfo.TransparentColor;
        if isOneNum(t) && isIntegerVal(t) && t > 0 && t <= size(colorMap, 1)
            if isinteger(image)
                ii_transparentPixels = image == t-1;
            else
                ii_transparentPixels = image == t;
            end
        end
    end

    %Convert indexed image to RGB
    image = ind2rgb(image, colorMap);

    %Color already normalized to 0-1 so don't need to get or apply bitDepth

    %Apply transparency info if any
    if ~isempty(ii_transparentPixels)
        x = zeros(size(image(:,:,1)));
        x(~ii_transparentPixels) = 1;
        image = cat(3, image, x);
    end
else
    if ~isempty(alpha)
        %Add alpha channel
        image = cat(3, image, alpha);
    end

    %Get bitDepth and normalize color to 0-1
                bitDepth_file = [];
    if isfield(imageInfo, 'NumberOfSamples')
        if ~isempty(imageInfo.BitDepth) && ~isempty(imageInfo.NumberOfSamples)
                bitDepth_file = imageInfo.BitDepth/imageInfo.NumberOfSamples;
            if ~(isIntegerVal(bitDepth_file) && bitDepth_file > 0)
                bitDepth_file = [];
            end
        end
    end
    if ~isempty(bitDepth_file)
        bitDepth = bitDepth_file;
    end
    image = double(image)/(2^bitDepth-1);
end        

%Apply orientation info if any
if isfield(imageInfo, 'Orientation')
                o = imageInfo.Orientation;
    if isOneNum(o)
        if      o == 2
            image = fliplr(image);
        elseif  o == 3
            image = fliplr(image);            
            image = flipud(image); %#ok<*FLUDLR>
        elseif  o == 4
            image = flipud(image);
        elseif  o == 5
            image = permute(image, [2 1 3]);
        elseif  o == 6
            image = flipud(image);
            image = permute(image, [2 1 3]);
        elseif  o == 7
            image = flipud(image);
            image = fliplr(image);                        
            image = permute(image, [2 1 3]);
        elseif  o == 8
            image = fliplr(image);
            image = permute(image, [2 1 3]);
        end
    end
end