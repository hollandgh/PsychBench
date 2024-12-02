fileNames = this.fileName;
dataExprs = this.dataExpr;
bitDepths = this.bitDepth;
crops = this.crop;
heights = this.height;
grayscales = this.grayscale;
imageCodes = this.imageCode;
positions = this.positions;
rotations = this.rotations;
numImages = this.numImages;
openRect = devices.screen.openRect;
windowSize = devices.screen.windowSize;


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

rects_rot = repmat(positions, 1, 2)+[-(sizes_rot+1)/2 +(sizes_rot-1)/2];
rect = [min(rects_rot(:,1:2), [], 1) max(rects_rot(:,3:4), [], 1)];
rects = repmat(positions, 1, 2)+[-(sizes+1)/2 +(sizes-1)/2];
rects_texture = rects-repmat(rect(1:2), numImages, 2);
siz = rect(3:4)-rect(1:2);
centerOffset = rect(1:2)+(siz+1)/2;

%Format for input to PTB DrawTextures later
rects_texture = transpose(rects_texture);
%---
   

%Make texture(s)
%---
if numImages == 1 && rotations(1) == 0
    %One image, not rotated -> convert directly to texture
    
    n_texture = element_openTexture([], [], images{1});
else
    %Multiple images or rotated image -> draw to one larger texture
    
    %Request object background color = transparent.
    %Transparent version of mean color decreases artifacts if adjacent pixels are blended, e.g. if rotation.
    this = element_setBackColor(this, [0.5 0.5 0.5 0]);
    
    %Open texture for drawing, sized to fit display, background = object background color
    n_texture = element_openTexture(siz);

    %Convert each image data to a texture
        nn_imageTextures = zeros(1, numImages);
    for n_image = 1:numImages
        nn_imageTextures(n_image) = element_openTexture([], [], images{n_image});
    end

    %Draw image textures to texture to show.
    %Draw with first above last to match convention for property .depth (+ = behind).
    %Apply rotations if any.
    Screen('DrawTextures', n_texture, flip(nn_imageTextures), [], flip(rects_texture, 2), flip(rotations))

    %Close image textures
    Screen('Close', nn_imageTextures)
end
%---


%Static display with image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture, [], siz(2), centerOffset);


this.size = siz;
this.centerOffset = centerOffset;
this.n_texture = n_texture;


%end picture_open2




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