%WALKER COORDS
%Standard walker is upright in +z walking in +x.
%Later projected onto screen coords for display:
%walker y ->  screen x
%walker z -> -screen y
%Functionality hard assumes upright in z at many places (sizing, scrambling, etc.).




%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.dataExpr = var2Char(this.dataExpr);
this.phase = var2Char(this.phase);
this.scrambleAreaSize = var2Char(this.scrambleAreaSize);

%Convert deg units to px
this.height = element_deg2px(this.height);
this.dotSize = element_deg2px(this.dotSize);
this.stickWidth = element_deg2px(this.stickWidth);
this.scrambleAreaSize = element_deg2px(this.scrambleAreaSize);
%---


dataExpr = this.dataExpr;
fps = this.fps;
height = this.height;
sizeMult = this.sizeMult;
azimuth = this.azimuth;
elevation = this.elevation;
azimuthVel = this.azimuthVel;
speed = this.speed;
transVelMult = this.transVelMult;
transVelOffset = this.transVelOffset;
dotSize = this.dotSize;
nn_showMarkers = this.nn_showMarkers;
stickWidth = this.stickWidth;
nn_stickMarkers = this.nn_stickMarkers;
color = this.color;
repeat = this.repeat;
phase = this.phase;
invert = this.invert;
invertLocal = this.invertLocal;
invertGlobal = this.invertGlobal;
scramble = this.scramble;
scrambleHorz = this.scrambleHorz;
scrambleVert = this.scrambleVert;
scrambleAreaSize = this.scrambleAreaSize;
numScrambleDots = this.numScrambleDots;
scramblePeriods = this.scramblePeriods;
scramblePeriodDelta = this.scramblePeriodDelta;
scramblePhases = this.scramblePhases;
opacity = this.opacity;
n_window = this.n_window;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(dataExpr) && ~isempty(dataExpr))
    error('Property .dataExpr must be a string.')
end
if ~(isOneNum(fps) && fps > 0)
    error('Property .fps must be a number > 0.')
end
if ~(isOneNum(sizeMult) && sizeMult > 0 || isempty(sizeMult))
    error('Property .sizeMult must be a number > 0, or [].')
end
if isempty(sizeMult)
    if isempty(height)
        error('One of properties .height or .sizeMult must be set.')
    end
    if ~(isOneNum(height) && height > 0)
        error('Property .height must be a number > 0, or [].')
    end
end

if ~isOneNum(azimuth)
    error('Property .azimuth must be a number.')
end
if ~isOneNum(elevation)
    error('Property .elevation must be a number.')
end
if ~isOneNum(azimuthVel)
    error('Property .azimuthVel must be a number.')
end
if ~isOneNum(speed)
    error('Property .speed must be a number.')
end
if ~isOneNum(transVelMult)
    error('Property .transVelMult must be a number.')
end
if ~isOneNum(transVelOffset)
    error('Property .transVelOffset must be a number.')
end

if ~(isOneNum(dotSize) && dotSize >= 0)
    error('Property .dotSize must be a number >= 0.')
end
if dotSize > 0
        %nn_showMarkers = [] -> show all, so if dotSize > 0 will always show something
    if ~(isRowNum(nn_showMarkers) && all(isIntegerVal(nn_showMarkers) & nn_showMarkers > 0) || isempty(nn_showMarkers))
        error('Property .nn_showMarkers must be a row vector of integers > 0, or [].')
    end
end
if ~(isOneNum(stickWidth) && stickWidth >= 0)
    error('Property .stickWidth must be a number >= 0.')
end
if stickWidth > 0
        %Can't be empty to be consistent with syntax for nn_showMarkers
    if ~(isa(nn_stickMarkers, 'numeric') && ismatrix(nn_stickMarkers) && size(nn_stickMarkers, 2) == 2 && ~isempty(nn_stickMarkers) && allish(isIntegerVal(nn_stickMarkers) & nn_stickMarkers > 0))
        error('Property .nn_stickMarkers must be an nx2 matrix containing integers > 0.')
    end
end
if ~(dotSize > 0 || stickWidth > 0)
    error('One of properties .dotSize or .stickWidth must be > 0.')
end

if ~(isRowNum(color) && numel(color) == 3 && all(color >= 0 & color <= 1))
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
if ~isTrueOrFalse(repeat)
    error('Property .repeat must be true/false.')
end
if ~(isOneNum(phase) || isa(phase, 'char') && strcmpi(phase, 'r'))
    error('Property .phase must be a number or the string "r".')
end
if ~isTrueOrFalse(invert)
    error('Property .invert must be true/false.')
end
if ~isTrueOrFalse(invertLocal)
    error('Property .invertLocal must be true/false.')
end
if ~isTrueOrFalse(invertGlobal)
    error('Property .invertGlobal must be true/false.')
end

if ~(isTrueOrFalse(scramble) || isOneNum(scramble) && scramble >= 0 && scramble <= 1)
    error('Property .scramble must be true/false or a number between 0-1.')
end
if ~isTrueOrFalse(scrambleHorz)
    error('Property .scrambleHorz must be true/false.')
end
if ~isTrueOrFalse(scrambleVert)
    error('Property .scrambleVert must be true/false.')
end
if scramble > 0 && ~(~scrambleHorz && ~scrambleVert)
    error('If property .scramble is > 0 then .scrambleHorz and .scrambleVert must = false.')
end
if scramble > 0 || scrambleHorz || scrambleVert   
    if ~(isRowNum(scrambleAreaSize) && numel(scrambleAreaSize) == 2 && all(scrambleAreaSize > 0) || isa(scrambleAreaSize, 'char') && strcmpi(scrambleAreaSize, 'f'))
        error('Property .scrambleAreaSize must be a 1x2 vector with numbers > 0, or the string "f".')
    end
    
    if ~(isOneNum(numScrambleDots) && numScrambleDots >= 0 || isempty(numScrambleDots))
        error('Property .numScrambleDots must be a number >= 0, or [].')
    end
    if ~isempty(numScrambleDots) && ~(dotSize > 0 && stickWidth == 0)
        error('If property .numScrambleDots is set then .dotSize must be > 0 and .stickWidth must = 0.')
    end
    
    if elevation ~= 0
        error('Currently if marker positions are scrambled then property .elevation must = 0.')
    end
end

if ~isTrueOrFalse(scramblePeriods)
    error('Property .scramblePeriods must be true/false.')
end
if scramblePeriods
    if ~(isOneNum(scramblePeriodDelta) && scramblePeriodDelta > 0)
        error('Property .scramblePeriodDelta must be a number > 0.')
    end
end

if ~(isTrueOrFalse(scramblePhases) || isOneNum(scramblePhases) && scramblePhases >= 0 && scramblePhases <= 1)
    error('Property .scramblePhases must be true/false or a number between 0-1.')
end
%---




if WITHPTB
        if dotSize > 0
            [minDotSize, maxDotSize] = Screen('DrawDots', n_window);
            if ~(dotSize >= minDotSize && dotSize <= maxDotSize)
                error(['In property .dotSize: ' num2str(dotSize) ' px is out of range. On your system dots must be between ' num2str(minDotSize) '-' num2str(maxDotSize) ' px.'])
            end
        end
        if stickWidth > 0
            [minLineWidth, maxLineWidth] = Screen('DrawLines', n_window);
            if ~(stickWidth >= minLineWidth && stickWidth <= maxLineWidth)
                error(['In property .stickWidth: ' num2str(stickWidth) ' px is out of range. On your system lines must be between ' num2str(minLineWidth) '-' num2str(maxLineWidth) ' px.'])
            end
        end
    
    
    %Merge into RGBA for PTB DrawDots, DrawLines
    color = [color opacity];
    
        
else %WITH MGL
    %Dot size = radius for mglGluDisk
    dotSize = dotSize/2;
    
    
end


%Load walker data from base workspace, get data format
%---
try
    data = evalin('base', dataExpr);
catch X
        error(['In property .dataExpr: Cannot get ' dataExpr ' in the base MATLAB workspace.'])
end
    if ~isa(data, 'numeric')
        error(['In property .dataExpr: ' dataExpr ' must be a matrix.'])
    end
    if ~any(ndims(data) == [2 3])
        error(['In property .dataExpr: ' dataExpr ' must be a 2D (mm) or 3D (md) matrix.'])
    end
if ndims(data) == 2 %#ok<ISMAT>
    dataRep = 'mm';
elseif ndims(data) == 3
    dataRep = 'md';
end
%---




%Processing different for mm/md data:
%Read and format data, center, invert, size
%===============================================================================
if strcmp(dataRep, 'mm')


    %Must have at least 1 marker
    if ~(size(data, 1) >= 4 && mod(size(data, 1)-1, 3) == 0 && size(data, 2) >= 2)
        error(['In property .dataExpr: Data in ' dataExpr ' appears to be mm format but must have numMarkers*3+1 rows and >= 2 columns.'])
    end
    
numMarkers = (size(data, 1)-1)/3;

%Get period, mm trans speed, get data.
%Period converted from images -> sec here. mm trans speed left cause need in mm/image for now.
%Don't need mm size factor--all gets plastered over when sizing.
%Note mm trans speed already scaled by mm size factor.
period = data(end,1)/fps;
transSpeed_mm = data(end,3);
data = data(1:end-1,:);

%Trim to number of harmonics--could be 0's in the matrix cause of info row.
%Can have no harmonics but still all-0 mean posns (colm 1) though.
    %Cut off trailing even col (e.g. 2, 8) as not a harmonic
data = data(:,1:end-mod(size(data, 2)-1, 2));
for n_harmonic = (size(data, 2)-1)/2:-1:1
    if allish(data(:,n_harmonic*2+[0 1]) == 0)
        data = data(:,1:n_harmonic*2-1);
    else
        break
    end
end
numHarmonics = (size(data, 2)-1)/2;

%Reshape into standard coords x markers x harmonics
data = permute(reshape(data, numMarkers, 3, []), [2 1 3]);


%Center at [0 0 0] in walker space.
%Based on mean of bounding marker mean positions -> marker motion time average discounting density of markers.
data(:,:,1) = data(:,:,1)-repmat(mean([min(data(:,:,1), [], 2) max(data(:,:,1), [], 2)], 2), 1, numMarkers);


%Invert
if invert || invertLocal
    data(3,:,2:end) = -data(3,:,2:end);
end
if invert || invertGlobal
    data(3,:,1) = -data(3,:,1);
end


%Size.
%Don't need to apply mm size factor for size--gets plastered over.
if isempty(sizeMult)
        %Use height in walker space.
        %Height = max-min z position.
        %Not mean position height cause that can be quite different, e.g. in md data case of a subject sitting then standing up.
        %Sample into md data, 30 points in period.
        %Based on all markers regardless of nn_showMarkers, before any replication of dots for scrambled mask cause don't want skew average.
                data_md = zeros(3,numMarkers,30);
        for n_image = 1:30
            t = (n_image-1)*period/30;

                data_md(3,:,n_image) = data(3,:,1);
            for n_harmonic = 1:numHarmonics
                data_md(3,:,n_image) = data_md(3,:,n_image)+data(3,:,2*n_harmonic).*sin(n_harmonic*(2*pi./period*t))+data(3,:,2*n_harmonic+1).*cos(n_harmonic*(2*pi./period*t));
            end
        end
        
        sizeMult = height/(max(max(data_md(3,:,:), [], 2), [], 3)-min(min(data_md(3,:,:), [], 2), [], 3));
    if sizeMult == inf
        sizeMult = 1;
    end
end
data = sizeMult*data;


%Dot mean positions and mean position size
dotMeanPositions = data(:,:,1);
meanSize = [repmat(max((dotMeanPositions(1,:).^2+dotMeanPositions(2,:).^2).^(1/2))*2, 1, 2) max(dotMeanPositions(3,:))-min(dotMeanPositions(3,:))+1];


numImages = [];




%===============================================================================
elseif strcmp(dataRep, 'md')
    

    if ~isOneNum(phase)
        error('For md data property .phase must be a number.')
    end
    if ~(~invertLocal && ~invertGlobal)
        error('Currently for md data properties .invertLocal and .invertGlobal must = false.')
    end
    if scramblePeriods
        error('Currently for md data property .scramblePeriods must = false.')
    end

    %Must have at least 1 marker and image
    if ~(size(data, 3) == 3 && ~isempty(data))
        error(['In property .dataExpr: Data in ' dataExpr ' appears to be md format but must be a numImages x numMarkers x 3 matrix.'])
    end
    
numMarkers = size(data, 2);
numImages = size(data, 1);

%Reshape into standard coords x markers x images
data = permute(data, [3 2 1]);


%Center
data = data-repmat(mean([min(mean(data, 3), [], 2) max(mean(data, 3), [], 2)], 2), 1, numMarkers, numImages);


%Invert
if invert
    data(3,:,:) = -data(3,:,:);
end


%Size
if isempty(sizeMult)
        sizeMult = height/(max(max(data(3,:,:), [], 2), [], 3)-min(min(data(3,:,:), [], 2), [], 3));
    if sizeMult == inf
        sizeMult = 1;
    end
end
data = sizeMult*data;


%Dot mean positions and mean position size
dotMeanPositions = mean(data, 3);
meanSize = [repmat(max((dotMeanPositions(1,:).^2+dotMeanPositions(2,:).^2).^(1/2))*2, 1, 2) max(dotMeanPositions(3,:))-min(dotMeanPositions(3,:))+1];


numHarmonics = [];




%===============================================================================
end




%Dots, Sticks
%---
if dotSize > 0
    if isempty(nn_showMarkers)
        nn_showDots = 1:numMarkers;
    else
        %Show set markers only.
        %dotSize, nn_showMarkers only makes dots invisible--could still draw sticks between them.
        nn_showDots = nn_showMarkers;
            if ~all(nn_showDots <= numMarkers)
                error('In property .nn_showMarkers: Some marker numbers > number of markers in data.')
            end
            
        %Remove duplicates cause don't want them in draw functions later
        nn_showDots = unique(nn_showDots);
    end
    
    if (scramble > 0 || scrambleHorz || scrambleVert) && ~isempty(numScrambleDots)
        %Mask: replicate from nn_showDots to numScrambleDots, so in this case dots not in nn_showMarkers actually gone.
        %Checked can only if dotSize > 0 (and nn_showMarkers always shows at least one dot), stickWidth = 0.
        m = floor(numScrambleDots/numel(nn_showDots));
        r = rem(numScrambleDots, numel(nn_showDots));
        data =             	[repmat(            data(:,nn_showDots,:), 1, m, 1)             data(:,1:r,:)];
        dotMeanPositions =	[repmat(dotMeanPositions(:,nn_showDots  ), 1, m   ) dotMeanPositions(:,1:r  )];
        nn_showDots = 1:numScrambleDots;
    end
else
        nn_showDots = [];
end

        %numDots = actual number of dots to compute (visible and invisible).
        % = either number of markers in data or number of mask dots.
        numDots = size(data, 2);
        

%Show sticks
if stickWidth > 0
        if ~allish(nn_stickMarkers <= numMarkers)
            error('In property .nn_stickMarkers: Some marker numbers > number of markers in data.')
        end
        
    x = nn_stickMarkers;
    
    %Remove sticks between same marker
    x(x(:,1) == x(:,2),:) = [];
    
    %Remove duplicate sticks
    tf = false(size(x, 1),1);
    for i = 1:size(x, 1)
        y = x;
        y(i,:) = -1;
        tf = tf | (x(i,1) == y(:,1) & x(i,2) == y(:,2) | x(i,1) == y(:,2) & x(i,2) == y(:,1));
    end
    x(tf,:) = [];
        
    nn_stickMarkers = reshape(transpose(x), 1, []);    
else
    nn_stickMarkers = [];
end
%---




if numDots > 0
    
    
    
    
%Processing different for mm/md data:
%Scrambling, periods/phases/speed, translation velocity
%===============================================================================
if strcmp(dataRep, 'mm')


%Dot positions.
%Maybe update mean size.
if scramble > 0 || scrambleHorz || scrambleVert
    [dotMeanPositions_scrambled, meanSize] = scrambleDotMeanPositions(dotMeanPositions, numDots, scramble, scrambleHorz, scrambleVert, meanSize, scrambleAreaSize);
    data(:,:,1) = dotMeanPositions_scrambled;
end


%Dot periods
if scramblePeriods
    %Scramble dot periods.
    %Period for each dot is divided by a number between 1/r ... r drawn from a logarithmic uniform distribution (i.e. uniform between -ln(r) ... ln(r) in log space).
    periods = period/speed./exp((2*rand(1,numDots)-1)*log(scramblePeriodDelta));
else
    %Dots have uniform period
    periods = repmat(period/speed, [1 numDots]);
end


%Dot phases (-> rad for later)
    if isa(phase, 'char') && strcmpi(phase, 'r')
        %Get veridical phase: random phase for mm data
        phases = repmat(2*pi*rand, [1 numDots]);
    else
        %Get veridical phase: set phase
        
        %s -> rad.
        %If outside 0 ... 2*pi and partial scrambling doesn't matter--mod formula below deals with that too.
        phase = phase*2*pi;
        phases = repmat(phase, [1 numDots]);
    end
if scramblePhases > 0
        %Get fully scrambled phases
        phases_scrambled = 2*pi*rand(1,numDots);
    if scramblePhases < 1
        %Partially scrambled
        phases_scrambled = phases+scramblePhases*(mod(phases_scrambled-phases+pi, 2*pi)-pi);
    end
        phases = phases_scrambled;
end


%Translation velocity (+/- horz).
%Scale by speed, size and convert from mm/image to mm/sec.
transVel = (transSpeed_mm*speed*transVelMult+transVelOffset)*sizeMult*fps;
transPosition = 0;




%===============================================================================
elseif strcmp(dataRep, 'md')


%Dot positions.
%Maybe update mean size.
if scramble > 0 || scrambleHorz || scrambleVert
    [dotMeanPositions_scrambled, meanSize] = scrambleDotMeanPositions(dotMeanPositions, numDots, scramble, scrambleHorz, scrambleVert, meanSize, scrambleAreaSize);
    data = data+repmat(-dotMeanPositions+dotMeanPositions_scrambled, [1 1 numImages]);
end


%For md if negative speed reverse data, phase so can use same algo in frames, esp picking out an image if scrambled phases
if speed < 0
    data = flip(data, 3);
    speed = -speed;
    phase = -phase;
end


%Dot phases.
%Do by shifting data cause better for scrambling and picking out a frame in runFrame script.
            %s -> fr
            phase = round(phase*fps);
            %Bring within [0 numImages-1] (important at least for no scramble, no repeat case)
            phase = mod(phase, numImages);
            phases = repmat(phase, [1 numDots]);
if scramblePhases > 0
            %Get fully scrambled phases between [0 numImages-1].
            %Assume rand never returns 0 or 1.
            phases_scrambled = round(numImages*rand(1,numDots)-0.5);
        if scramblePhases < 1
            %Partially scrambled
            phases_scrambled = round(phases+scramblePhases*(mod(phases_scrambled-phases+numImages/2, numImages)-numImages/2));
        end
            phases = phases_scrambled;
        
            %Circular shift data across time dimension
        for n_dot = 1:numDots
            data(:,n_dot,:) = circshift(data(:,n_dot,:), -phases(n_dot), 3);
        end
else    
    if repeat
            data =            circshift(data,            -phases(1),     3);
    else
            %If no phase scrambling and no repeat, phase just means start part-way in and end earlier
            data = data(:,:,phases(1)+1:end);
            numImages = size(data, 3);
    end
end


%Translation velocity
transVel = transVelOffset*sizeMult*fps;
transPosition = 0;


periods = [];




%===============================================================================
end




%Won't use texture method for showing object display, so tell PsychBench display size (approx)
displaySize = meanSize(2:3);
this = element_setDisplaySize(this, displaySize);


%Rotate.
%Order (important!): Azimuth + azimuth velocity, elevation.
%Walker centered at [0 0 0] in walker space in open script so rotate doesn't translate.
%If azimuth vel need to wait til frames.
if azimuthVel == 0
        az = azimuth;
        el = elevation;
        r = [cosd(el) 0 sind(el); 0 1 0; -sind(el) 0 cosd(el)]*[cosd(az) -sind(az) 0; sind(az) cosd(az) 0; 0 0 1];
    for i = 1:size(data, 3)
        data(:,:,i) = r*data(:,:,i);
    end
end




else
    periods = [];
    phases = [];
    transVel = [];
    transPosition = [];
end




this.speed = speed;
this.dotSize = dotSize;
this.nn_stickMarkers = nn_stickMarkers;
this.color = color;
this.phase = phase;
this.dataRep = dataRep;
this.data = data;
this.numHarmonics = numHarmonics;
this.numImages = numImages;
this.numDots = numDots;
this.nn_showDots = nn_showDots;
this.periods = periods;
this.phases = phases;
this.transVel = transVel;
this.transPosition = transPosition;




function [dotMeanPositions_scrambled, meanSize_scrambled] = scrambleDotMeanPositions(dotMeanPositions, numDots, scramble, scrambleHorz, scrambleVert, meanSize, scrambleAreaSize)


%Use cylindrical coords -> new mean positions within a cylinder, display will be y-z cross-section.
%Use cylinder instead of cube cause if have az vel need to rotate whole
%structure rigidly like a veridical walker, so this preserves average density of
%markers in cross-section display.
    
    dotMeanPositions_scrambled = dotMeanPositions;
    meanSize_scrambled = meanSize;
if scramble > 0 || scrambleHorz
    %Get fully scrambled horz mean positions
    if isa(scrambleAreaSize, 'char') && strcmpi(scrambleAreaSize, 'f')
        %Cylinder bounding walker
        w = meanSize(1);
    else
        %Set cylinder
        w = scrambleAreaSize(1);
    end
    rr  =  w/2*rand(1,numDots);
    tth = 2*pi*rand(1,numDots);
    dotMeanPositions_scrambled(1,:) = rr.*cos(tth);
    dotMeanPositions_scrambled(2,:) = rr.*sin(tth);
    
    meanSize_scrambled(1:2) = w;
end
if scramble > 0 || scrambleVert
    %Get fully scrambled vert mean positions
    if isa(scrambleAreaSize, 'char') && strcmpi(scrambleAreaSize, 'f')
        h = meanSize(3);
    else
        h = scrambleAreaSize(2);
    end
    zz  = h   *(rand(1,numDots)-0.5);
    dotMeanPositions_scrambled(3,:) = zz;
    
    meanSize_scrambled(3) = h;    
end
if scramble > 0 && scramble < 1
    %Partially scrambled.
    %Interpolate in spherical coords to preserve average size of walker across levels.
    %scrambleHorz and Vert checked = 0 in open script, so both horz and vert done above.

    %Random spin of walker data in 3D space.
    %Necessary because some markers in some walker data are defined in such a way
    %that one of their spherical coordinates is fixed at an accidental value (e.g.
    %phi = 0 or 180)--for such dots partial scrambling will not be random in
    %direction. e.g. the head dot in mm data will almost always bend backward.
    q = 2*pi*rand(1,3);
    R = [
        1          0          0
        0          cos(q(1))  -sin(q(1))
        0          sin(q(1))  cos(q(1))
        ]*[
        cos(q(2))  0          sin(q(2))
        0          1          0
        -sin(q(2)) 0          cos(q(2))
        ]*[
        cos(q(3))  -sin(q(3)) 0
        sin(q(3))  cos(q(3))  0
        0          0          1
        ];
    dotMeanPositions = R*dotMeanPositions;
    dotMeanPositions_scrambled = R*dotMeanPositions_scrambled;
    
    %Veridical to spherical coords
    rr  = (dotMeanPositions(1,:).^2+dotMeanPositions(2,:).^2+dotMeanPositions(3,:).^2).^(1/2);
    tth = acos(dotMeanPositions(3,:)./rr);
    pph = atan2(dotMeanPositions(2,:), dotMeanPositions(1,:));

    %Fully scrambled to spherical coords
    rr_scrambled  = (dotMeanPositions_scrambled(1,:).^2+dotMeanPositions_scrambled(2,:).^2+dotMeanPositions_scrambled(3,:).^2).^(1/2);
    tth_scrambled = acos(dotMeanPositions_scrambled(3,:)./rr_scrambled);
    pph_scrambled = atan2(dotMeanPositions_scrambled(2,:), dotMeanPositions_scrambled(1,:));

    %Interpolate.
    %mod formula interpolates along smallest distance between angles (e.g. 10 not 350 for 5, 355 deg).
    %Works by finding difference, adding 180, bringing that into 0...360, subtracting 180 to recover correct difference but now in -180...180.
    %Note: for spherical coords th is 0...180. If difference = 180 with tth < tth_scrambled 
    %then this will return -ve tth. To solve we assume chance of exactly 180
    %difference is infinitessimal.
    rr_scrambled =  rr+ scramble*(rr_scrambled-rr);
    tth_scrambled = tth+scramble*(mod(tth_scrambled-tth+pi, 2*pi)-pi);
    pph_scrambled = pph+scramble*(mod(pph_scrambled-pph+pi, 2*pi)-pi);

    %Partially scrambled to Cartesian
    dotMeanPositions_scrambled(1,:) = rr_scrambled.*sin(tth_scrambled).*cos(pph_scrambled);
    dotMeanPositions_scrambled(2,:) = rr_scrambled.*sin(tth_scrambled).*sin(pph_scrambled);
    dotMeanPositions_scrambled(3,:) = rr_scrambled.*cos(tth_scrambled);
    
    %Invert random spin
    dotMeanPositions_scrambled = R'*dotMeanPositions_scrambled;
    
    %Walker somewhere between veridical and scrambled.
    %Take mean size = max of them.
    meanSize_scrambled = max(meanSize, meanSize_scrambled);
end


end