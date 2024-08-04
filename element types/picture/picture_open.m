%Giles Holland 2022, 23


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
openRect = devices.screen.openRect;
windowSize = devices.screen.windowSize;


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


%Load images
%---
    images = cell(1, numImages);
    sizes = zeros(numImages, 2);
for n_image = 1:numImages
    fileName = fileNames{n_image};
    dataExpr = dataExprs{n_image};
    bitDepth = bitDepths(n_image);
    crop = crops(n_image,:);
    height = heights{n_image};
    grayscale = grayscales(n_image);
    imageCode = imageCodes{n_image};
    
    
    %Load image data, crop, grayscale.
    %Maybe slow, so encapsulate in a function and do shares so only computes once
    %for all objects of this type with the same function input values.
    image = element_doShared(@loadImage, fileName, dataExpr, bitDepth, crop, grayscale);

    
    %Size image
    siz = [size(image, 2) size(image, 1)];
    if isa(height, 'char')        
        if      strcmpi(height, 'fit')
            %Fit whole image to window
            sizeMult = min(windowSize./siz);
        elseif  strcmpi(height, 'fitw')
            %Fit image width to window
            sizeMult = windowSize(1)/siz(1);
        elseif  strcmpi(height, 'fith')
            %Fit image height to winow
            sizeMult = windowSize(2)/siz(2);
        elseif  strcmpi(height, 'fill')
            %Fill window
            sizeMult = max(windowSize./siz);
        elseif  strcmpi(height, 'px')
            %Show image at 1 px image = 1 px screen.
            %Scale down by partial-window height if users set screen .openRect.
            sizeMult = openRect(4)-openRect(2);
        end
    else
            sizeMult = height/siz(2);
    end
    siz = siz*sizeMult;
    

    %Custom code.
    %Can't go in doShared cause could be anything and so result in different image
    %values for same imageCode values, e.g. if includes randomization.
    if ~isempty(imageCode)
        try
            image = evalImageCode(imageCode, image);
        catch X
                error(['Error running code in property .imageCode (or it did not leave a variable called "image").' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
        end
            if ~(isa(image, 'numeric') && ndims(image) <= 3 && size(image, 3) <= 4 && ~isempty(image))
                error('In property .imageCode: Output variable "image" must be an m x n x 1-4 numeric array.')
            end
    end
    
    
    images{n_image} = image;
    sizes(n_image,:) = siz;
end
%---


%Calculate image rects on texture, texture size, texture center offset from object position...
%---
    sizes_rot = sizes;
for i = find(rotations ~= 0)
    r = rotations(i);
    sizes_rot(i,:) = max(abs([
        cosd(r) -sind(r)
        sind(r)  cosd(r)
        ]*[
        sizes_rot(i,:)' [
           -sizes_rot(i,1)
            sizes_rot(i,2)
            ]
        ]), [], 2)';
end

rects_rot = repmat(positions, 1, 2)+[-sizes_rot/2 +sizes_rot/2];
rect = [min(rects_rot(:,1:2), [], 1) max(rects_rot(:,3:4), [], 1)];
rects = repmat(positions, 1, 2)+[-sizes/2 +sizes/2];
rects_texture = rects-repmat(rect(1:2), numImages, 2);
siz = rect(3:4)-rect(1:2);
centerOffset = rect(1:2)+(siz+1)/2;

%Format for input to PTB DrawTextures later
rects_texture = transpose(rects_texture);
%---


    this.numImages = numImages;
if isempty(imageCode)
    %Image data is large, so set shared so only holds one value in memory for
    %all objects of this type with the same type-specific property values set
    %by user
    %---
    this = element_setShared(this, 'images', images);
    %---
else
    %Don't set shared for this object cause image code could be anything, incl randomization
    this.images = images;
end
    this.rects_texture = rects_texture;
    this.size = siz;
    this.centerOffset = centerOffset;


%end script




function image = loadImage(fileName, dataExpr, bitDepth, crop, grayscale) %local function


if ~isempty(dataExpr)
    %GET IMAGE ARRAY IN BASE WORKSPACE
    

    imageName = dataExpr;
    
    try
        image = evalin('base', imageName);
    catch X
            error(['In property .dataExpr: Cannot get ' imageName ' in the base MATLAB workspace.'])
    end
        if ~(isa(image, 'numeric') && ndims(image) <= 3 && size(image, 3) <= 4 && ~isempty(image))
            error(['In property .dataExpr: ' imageName ' must be an m x n x 1-4 numeric array.'])
        end

    %Normalize color to 0-1 based on bitDepth set by user
    image = double(image)/(2^bitDepth-1);
else
    %LOAD IMAGE ARRAY FROM FILE
    
    
    imageName = fileName;
    
    try
        image = imreadish(imageName);
    catch X
            error(['In property .fileName: Cannot load ' imageName '.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
end


if ~all(crop == [0 0 inf inf])
    %Crop to part of image to show.
    %Do here rather than crop input to element_redraw in runFrame cause more memory efficient to store a smaller image until then.
    %crop(1:2) = pixels before part, so crop(3:4)-crop(1:2) = part [width height], same convention as Psychtoolbox rects.
    
    size_image = [size(image, 2) size(image, 1)];
        %Checked at input >= 0, 1 < 3, 2 < 4
        if ~all(crop(1:2) < size_image)
            error(['In property .crop for image "' imageName '": Crop area is outside image.'])
        end
    crop(3:4) = min(crop(3:4), size_image);
    image = image(crop(2)+1:crop(4),crop(1)+1:crop(3),:);
end


if grayscale
    %Cut to grayscale
    
    if      size(image, 3) == 4
        %Retain alpha
        rgb = image(:,:,1:3);
        a = image(:,:,4);
        l = im2gray(rgb);
        image = cat(3, l, a);
    elseif  size(image, 3) == 3
        image = im2gray(image);
    %else already grayscale
    end
end


end %loadImage




function image = evalImageCode(skdhfjksadhfdluwfehlushfd, image) %local function

%Evaluate custom code (possibly a script name) in a workspace containing
%with the variable "image" to operate on, and a variable containing the
%code, with a random name so won't interfere with any functions or scripts
%the code calls


eval(skdhfjksadhfdluwfehlushfd)

    
end %evalImageCode