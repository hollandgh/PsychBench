%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.fileName = var2Char(this.fileName);
this.dataExpr = var2Char(this.dataExpr);
this.height = var2Char(this.height);

%Convert deg units to px
this.height = element_deg2px(this.height);
%---


fileName = this.fileName;
dataExpr = this.dataExpr;
height = this.height;
bpc = this.bpc;
windowSize = resources.screen.windowSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(dataExpr) || isempty(dataExpr))
    error('Property .dataExpr must be a string or [].')
end
if isempty(dataExpr)
    if isempty(fileName)
        error('One of properties .fileName or .dataExpr must be set.')
    end
    if ~isRowChar(fileName)
        error('Property .fileName must be a string or [].')
    end
end

if ~(isOneNum(height) && height > 0 || isa(height, 'char') && strcmpi(height, 'f'))
    error('Property .height must be a number > 0, or the string "f".')
end
if ~(isOneNum(bpc) && isIntegerVal(bpc) && bpc > 0)
    error('Property .bpc must be an integer > 0.')
end
%---


%Load, process picture data.
%Maybe slow, so encapsulate in a function and share so only computes once for
%all objects of the class with the same function input values.
%---
data = element_doShared(@load__processPicture, fileName, dataExpr, bpc);
%---


%Set display dimensions
if strcmpi(height, 'f')
    %Fit to screen
    siz_data = [size(data, 2) size(data, 1)];
    siz = siz_data*min(windowSize./siz_data);
    height = siz(2);
end
    scale = height/size(data, 2);


%data is large, so set shared so only holds one value in memory for all objects
%of the class with the same index property values.
%---
this = element_setShared(this, 'data', data, {'fileName' 'dataExpr' 'bpc'});
%---
this.height = height;
this.scale = scale;


%end script




function data = load__processPicture(fileName, dataExpr, bpc) %local function


if ~isempty(dataExpr)
    %GET RGB(A) IMAGE ARRAY IN BASE WORKSPACE
    

    try
        data = evalin('base', dataExpr);
    catch X
            error(['In property .dataExpr: Cannot get ' dataExpr ' in the base MATLAB workspace.'])
    end
        if ~(isa(data, 'numeric') && ndims(data) <= 3 && size(data, 3) <= 4 && ~isempty(data))
            error(['In property .dataExpr: ' dataExpr ' must be an n x m x 1-4 numeric array.'])
        end

    %Normalize color to 0-1 based on bpc set by user
    data = double(data)/(2^bpc-1);
else
    %LOAD IMAGE ARRAY FROM PICTURE FILE
    
    
    try
        [data, colorMap, alpha] = imread(fileName);
    catch X
            error(['Cannot load ' fileName '.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end

    %Disable warning cause of buggy warning in MATLAB
    warning('off', 'imageio:tifftagsread:badTagValueDivisionByZero');
    imageInfo = imfinfo(fileName);

    if strcmp(imageInfo.ColorType, 'indexed')
        %Look for transparency info
        ii_transparentPixels = [];
        if isfield(imageInfo, 'TransparentColor')
            t = imageInfo.TransparentColor;
            if isOneNum(t) && isIntegerVal(t) && t > 0 && t <= size(colorMap, 1)
                if isinteger(data)
                    ii_transparentPixels = data == t-1;
                else
                    ii_transparentPixels = data == t;
                end
            end
        end

        %Convert indexed picture data to RGB
        data = ind2rgb(data, colorMap);

        %Color already normalized to 0-1 so don't need to get or apply bpc

        %Apply transparency info if any
        if ~isempty(ii_transparentPixels)
            x = zeros(size(data(:,:,1)));
            x(~ii_transparentPixels) = 1;
            data = cat(3, data, x);
        end
    else
        %Add alpha channel
        data = cat(3, data, alpha);

        %Get bpc and normalize color to 0-1
        bpc_file = [];
        if isfield(imageInfo, 'NumberOfSamples')
            b = imageInfo.BitDepth;
            n = imageInfo.NumberOfSamples;
            if isOneNum(b) && isIntegerVal(b) && b > 0 && isOneNum(n) && isIntegerVal(n) && n > 0
                bpc_file = b/n;
            end
            if ~isIntegerVal(bpc_file)
                bpc_file = [];
            end
        end
        if ~isempty(bpc_file)
            bpc = bpc_file;
        end
        data = double(data)/(2^bpc-1);
    end        

    %Apply orientation info if any
    if isfield(imageInfo, 'Orientation')
                    o = imageInfo.Orientation;
        if isOneNum(o)
            if      o == 2
                data = fliplr(data);
            elseif  o == 3
                data = fliplr(data);            
                data = flipud(data); %#ok<*FLUDLR>
            elseif  o == 4
                data = flipud(data);
            elseif  o == 5
                data = permute(data, [2 1 3]);
            elseif  o == 6
                data = flipud(data);
                data = permute(data, [2 1 3]);
            elseif  o == 7
                data = flipud(data);
                data = fliplr(data);                        
                data = permute(data, [2 1 3]);
            elseif  o == 8
                data = fliplr(data);
                data = permute(data, [2 1 3]);
            end
        end
    end
end


end %load__processPicture