%Giles Holland 2022-24


        %(Handle deprecated)
        %---
        if isfield(this, 'mask')
            if ~isempty(this.mask)
                %mask ignored, treated as crop
                this.crop = this.mask;
            %else default value in crop
            end
        end
        if any(isfield(this, {'interval' 'repeat' 'breakInterval' 'nn_images'}))
            error('Properties .interval, .repeat, .breakInterval, .nn_images are deprecated. For arranging multiple images spatially, use .positions. For arranging temporally, please use a sequence element or the images2movie() tool and a movie element.')
        end
        %---


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.height = element_deg2px(this.height);
this.positions = element_deg2px(this.positions);

%Standardize strings from "x"/'x' to 'x'.
%-c: always outputs a cell array.
this.fileName = var2char(this.fileName, '-c');
this.dataExpr = var2char(this.dataExpr, '-c');
this.height = var2char(this.height, '-c');
this.imageCode = var2char(this.imageCode, '-c');
%---


fileNames = this.fileName;
dataExprs = this.dataExpr;
bitDepths = this.bitDepth;
crops = this.crop;
heights = this.height;
grayscales = this.grayscale;
imageCodes = this.imageCode;
positions = this.positions;
rotations = this.rotations;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isa(positions, 'numeric') && ismatrix(positions) && size(positions, 2) == 2 && ~isempty(positions))
    error('Property .positions must be an nx2 matrix.')
end
numImages = size(positions, 1);


if isempty(fileNames)
        fileNames = cell(1, numImages);
else
    if numel(fileNames) == 1
        fileNames = repmat(fileNames, 1, numImages);
    else
        fileNames = row(fileNames);
    end
    if ~(isa(fileNames, 'cell') && numel(fileNames) == numImages && all(cellfun(@(x) isRowChar(x) || isempty(x),    fileNames)))
        error('Property .fileName must be a string or []. It can also be a 1xn array of strings where n is number of images in .positions.')
    end
end
this.fileName = fileNames;

if isempty(dataExprs)
        dataExprs = cell(1, numImages);
else
    if numel(dataExprs) == 1
        dataExprs = repmat(dataExprs, 1, numImages);
    else
        dataExprs = row(dataExprs);
    end
    if ~(isa(dataExprs, 'cell') && numel(dataExprs) == numImages && all(cellfun(@(x) isRowChar(x) || isempty(x),    dataExprs)))
        error('Property .dataExpr must be a string or []. It can also be a 1xn array of strings where n is number of images in .positions.')
    end
end
this.dataExpr = dataExprs;

    tff_f = isemptycell(fileNames);
    tff_d = isemptycell(dataExprs);
if numImages == 1
    if ~(~tff_f || ~tff_d)
        error('One of properties .fileName or .dataExpr must be set.')
    end
    if ~(tff_f || tff_d)
        error('Only one of properties .fileName and .dataExpr can be set.')
    end
else
    if ~all(~tff_f | ~tff_d)
        error('One of properties .fileName or .dataExpr must be set for each image in .positions.')
    end
    if ~all(tff_f | tff_d)
        error('Only one of properties .fileName and .dataExpr can be set for each image in .positions.')
    end
end


if numel(bitDepths) == 1
    bitDepths = repmat(bitDepths, 1, numImages);
else
    bitDepths = row(bitDepths);
end
if ~(isa(bitDepths, 'numeric') && numel(bitDepths) == numImages && all(isIntegerVal(bitDepths) & bitDepths > 0))
    error('Property .bitDepth must be an integer > 0. It can also be a 1xn vector where n is number of images in .positions.')
end
this.bitDepth = bitDepths;


    crops = round(crops);
if size(crops, 1) == 1
    crops = repmat(crops, numImages, 1);
end
if ~(isa(crops, 'numeric') && ismatrix(crops) && size(crops, 1) == numImages && all2(crops >= 0) && all2(crops(:,1:2) < crops(:,3:4)))
    error('Property .crop must be a 1x4 vector with numbers >= 0, and (1) < (3) and (2) < (4). It can also be an nx4 matrix where n is number of images in .positions.')
end
this.crop = crops;


if isa(heights, 'numeric')
    heights = num2cell(heights);
end
%If was char or string var2char -c above converted to cell
if numel(heights) == 1
    heights = repmat(heights, 1, numImages);
else
    heights = row(heights);
end
if ~(isa(heights, 'cell') && numel(heights) == numImages && all(cellfun(@(x) isOneNum(x) && x > 0 || isa(x, 'char') && strisini(x, {'fit' 'fitw' 'fith' 'fill' 'px'}),    heights)))
    error('Property .height must be a number > 0 or a string "fit", "fitw", "fith", "fill", or "px". It can also be a 1xn vector or string or cell array where n is number of images in .positions.')
end
this.height = heights;


if numel(grayscales) == 1
    grayscales = repmat(grayscales, 1, numImages);
else
    grayscales = row(grayscales);
end
if ~(is01s(grayscales) && numel(grayscales) == numImages)
    error('Property .grayscale must be true/false. It can also be a 1xn array of true/false, where n is number of images in .positions.')
end
this.grayscale = grayscales;


if ~isa(imageCodes, 'cell')
    %[]
    imageCodes = {imageCodes};
end
if numel(imageCodes) == 1
    imageCodes = repmat(imageCodes, 1, numImages);
else
    imageCodes = row(imageCodes);
end
if ~(numel(imageCodes) == numImages && all(cellfun(@(x) isRowChar(x) || isempty(x),    imageCodes)))
    error('Property .imageCode must be a string or []. It can also be a 1xn string or cell array where n is number of images in .positions.')
end
this.imageCode = imageCodes;


if numel(rotations) == 1
    rotations = repmat(rotations, 1, numImages);
else
    rotations = row(rotations);
end
if ~(isa(rotations, 'numeric') && numel(rotations) == numImages)
    error('Property .rotations must be a number. It can also be a 1xn vector where n is number of images in .positions')
end
this.rotations = rotations;
%---


this.numImages = numImages;