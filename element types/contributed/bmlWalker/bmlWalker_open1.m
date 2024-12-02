%Giles Holland 2022-24


%WALKER COORDS
%Standard walker is upright in +z walking in +x.
%Later projected onto screen coords for display:
%walker y ->  screen x
%walker z -> -screen y
%Functionality hard assumes upright in z at many places (sizing, scrambling, etc.).




        %(Handle deprecated)
        %---
        if isfield(this, 'azimuthVel')
            if ~isempty(this.azimuthVel)
                this.azimuthVelocity = this.azimuthVel;
            %else default value in azimuthVelocity
            end
        end
        if isfield(this, 'transVel')
            if ~isempty(this.transVel)
                this.translationVelocity = this.transVel;
            %else default value in translationVelocity
            end
        end
        if isfield(this, 'translationVel')
            if ~isempty(this.translationVel)
                this.translationVelocity = this.translationVel;
            %else default value in translationVelocity
            end
        end
        if isfield(this, 'repeat')
            if ~isempty(this.repeat)
                if is01(this.repeat)
                    if this.repeat
                        this.maxNumLoops = inf;
                    else
                        this.maxNumLoops = 1;
                    end
                end
            %else default value in maxNumLoops
            end
        end
        if isfield(this, 'invertLocal')
            if ~isempty(this.invertLocal)
                if this.invertLocal
                    this.invert = "local";
                end
            %else default value in invert
            end
        end
        if isfield(this, 'invertGlobal')
            if ~isempty(this.invertGlobal)
                if this.invertGlobal
                    this.invert = "global";
                end
            %else default value in invert
            end
        end
        %---


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.height = element_deg2px(this.height);
this.sizeMult = element_deg2px(this.sizeMult);
this.dotSize = element_deg2px(this.dotSize);
this.stickWidth = element_deg2px(this.stickWidth);
this.scrambleAreaSize = element_deg2px(this.scrambleAreaSize);

%Standardize strings from "x"/'x' to 'x'
this.fileName = var2char(this.fileName);
this.dataExpr = var2char(this.dataExpr);
this.phase = var2char(this.phase);
this.invert = var2char(this.invert);
this.scrambleAreaSize = var2char(this.scrambleAreaSize);
%---


fileName = this.fileName;
dataExpr = this.dataExpr;
fps = this.fps;
nn_markers = this.nn_markers;
nn_showMarkers = this.nn_showMarkers;
height = this.height;
sizeMult = this.sizeMult;
azimuth = this.azimuth;
elevation = this.elevation;
azimuthVelocity = this.azimuthVelocity;
dotSize = this.dotSize;
color = this.color;
times = this.times;
showTimes = this.showTimes;
maxNumLoops = this.maxNumLoops;
breakInterval = this.breakInterval;
phase = this.phase;
speed = this.speed;
translate = this.translate;
translationVelocity = this.translationVelocity;
stickWidth = this.stickWidth;
nn_stickMarkers = this.nn_stickMarkers;
showMarkerNums = this.showMarkerNums;
invert = this.invert;
scramble = this.scramble;
scrambleHorz = this.scrambleHorz;
scrambleVert = this.scrambleVert;
scrambleAreaSize = this.scrambleAreaSize;
numScrambleDots = this.numScrambleDots;
scramblePeriods = this.scramblePeriods;
scramblePeriodDelta = this.scramblePeriodDelta;
scramblePhases = this.scramblePhases;
scrambleSeed = this.scrambleSeed;
n_window = this.n_window;
position = this.position;
windowSize = devices.screen.windowSize;
windowCenter = devices.screen.windowCenter;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(fileName) || isempty(fileName))
    error('Property .fileName must be a string or [].')
end
if ~isempty(fileName)
    [~, ~, e] = fileparts(fileName);
    if isempty(e)
        fileName = [fileName '.mat'];
    elseif ~any(strcmpi(e, {'.mat' '.c3d'}))
        error('In property .fileName: Must be a .mat or .c3d file.')
    end
    this.fileName = fileName;
end

if ~(isRowChar(dataExpr) || isempty(dataExpr))
    error('Property .dataExpr must be a string.')
end

if ~(~isempty(fileName) || ~isempty(dataExpr))
    error('One of properties .fileName or .dataExpr must be set.')
end

if ~(isOneNum(fps) && fps > 0 || isempty(fps))
    error('Property .fps must be a number > 0, or [].')
end

nn_markers = row(nn_markers);
if ~(isa(nn_markers, 'numeric') && all(isIntegerVal(nn_markers) & nn_markers > 0) || isempty(nn_markers))
    error('Property .nn_markers must be a vector of integers > 0, or [].')
end
this.nn_markers = nn_markers;

    if ~(~isempty(height) || ~isempty(sizeMult))
        error('One of properties .height or .sizeMult must be set.')
    end
if ~isempty(sizeMult)
    if ~(isOneNum(sizeMult) && sizeMult > 0)
        error('Property .sizeMult must be a number > 0, or [].')
    end
else
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
if ~isOneNum(azimuthVelocity)
    error('Property .azimuthVelocity must be a number.')
end
if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
if ~(isRowNum(times) && numel(times) == 2 && all(times >= 0))
    error('Property .times must be a 1x2 vector of numbers >= 0.')
end
if ~(isRowNum(showTimes) && numel(showTimes) == 2 && all(showTimes >= 0))
    error('Property .showTimes must be a 1x2 vector of numbers >= 0.')
end
if ~(isOneNum(maxNumLoops) && maxNumLoops > 0)
    error('Property .maxNumLoops must be a number > 0.')
end
if ~(isOneNum(breakInterval) && breakInterval >= 0)
    error('Property .breakInterval must be a number >= 0.')
end
if ~isOneNum(phase)
    error('Property .phase must be a number.')
end
if ~isOneNum(speed)
    error('Property .speed must be a number.')
end
if ~is01(translate)
    error('Property .translate must be true/false.')
end
if ~isOneNum(translationVelocity)
    error('Property .translationVelocity must be a number.')
end

if ~(isOneNum(dotSize) && dotSize >= 0)
    error('Property .dotSize must be a number >= 0.')
end
if dotSize > 0
        %nn_showMarkers = [] -> show all, so if dotSize > 0 will always show something
    nn_showMarkers = row(nn_showMarkers);
    if ~(isa(nn_showMarkers, 'numeric') && all(isIntegerVal(nn_showMarkers) & nn_showMarkers > 0) || isempty(nn_showMarkers))
        error('Property .nn_showMarkers must be a vector of integers > 0, or [].')
    end
    this.nn_showMarkers = nn_showMarkers;
    
    if ~is01(showMarkerNums)
        error('Property .showMarkerNums must be true/false.')
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

if ~(is01(invert) || isRowChar(invert) && any(strcmpi(invert, {'local' 'global'})))
    error('Property .invert must be true/false or a string "local"/"global".')
end
invertLocal = strcmpi(invert, 'local');
invertGlobal = strcmpi(invert, 'global');
if invertLocal || invertGlobal
    invert = false;
end

if ~(is01(scramble) || isOneNum(scramble) && scramble >= 0 && scramble <= 1)
    error('Property .scramble must be true/false or a number between 0-1.')
end
if ~is01(scrambleHorz)
    error('Property .scrambleHorz must be true/false.')
end
if ~is01(scrambleVert)
    error('Property .scrambleVert must be true/false.')
end
if scramble > 0 && ~(~scrambleHorz && ~scrambleVert)
    error('If property .scramble is > 0 then .scrambleHorz and .scrambleVert must = false.')
end
if scramble > 0 || scrambleHorz || scrambleVert
    if isOneNum(scrambleAreaSize)
        %Square
        scrambleAreaSize = [scrambleAreaSize scrambleAreaSize];
    end    
    if ~(isRowNum(scrambleAreaSize) && numel(scrambleAreaSize) == 2 && all(scrambleAreaSize > 0) || isa(scrambleAreaSize, 'char') && strcmpi(scrambleAreaSize, 'f'))
        error('Property .scrambleAreaSize must be a number or 1x2 vector of numbers > 0, or the string "f".')
    end
    this.scrambleAreaSize = scrambleAreaSize;
    
    
    if ~(isOneNum(numScrambleDots) && isIntegerVal(numScrambleDots) && numScrambleDots >= 0 || isempty(numScrambleDots))
        error('Property .numScrambleDots must be an integer >= 0, or [].')
    end
    if ~isempty(numScrambleDots) && ~(dotSize > 0 && stickWidth == 0)
        error('If property .numScrambleDots is set then .dotSize must be > 0 and .stickWidth must = 0.')
    end
    
    if elevation ~= 0
        error('Currently if marker positions are scrambled then property .elevation must = 0.')
    end
end

if ~is01(scramblePeriods)
    error('Property .scramblePeriods must be true/false.')
end
if scramblePeriods
    if ~(isOneNum(scramblePeriodDelta) && scramblePeriodDelta > 0)
        error('Property .scramblePeriodDelta must be a number > 0.')
    end
    if maxNumLoops < inf
        error('If property .scramblePeriods = true, .maxNumLoops must = inf.')
    end
end

if ~(is01(scramblePhases) || isOneNum(scramblePhases) && scramblePhases >= 0 && scramblePhases <= 1)
    error('Property .scramblePhases must be true/false or a number between 0-1.')
end
%---


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

    
if ~isempty(scrambleSeed)
    %Seed matlab rng to reproduce all scrambling/randomization
    try
        rng(scrambleSeed);
    catch X
            error(['Property .scrambleSeed must be a MATLAB random number generator state as returned by rng(), or [].' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
end


%Load data.
%Encapsulate in a function and share so only computes once for all objects of
%this type with the same function input values. 
%---
[fps, dataRep, data, numMarkers, numHarmonics, period, translationSpeed_mm] = element_doShared(@loadData, fileName, dataExpr, fps, nn_markers, times);
%---




%Processing different for mm/md data:
%Invert, size
%===============================================================================
if strcmp(dataRep, 'mm')

    
    if ~isequaln(times, [0 inf])
        error('For mm data, property .times cannot be set.')
    end
    if ~isequaln(showTimes, [0 inf])
        error('For mm data, property .showTimes cannot be set.')
    end


%Size.
%Don't need to apply mm size factor for size--gets plastered over.
if isempty(sizeMult)
        %Use height in walker space.
        %Use bounding height, not mean position height, cause can be quite different, e.g. in md data case of a subject sitting then standing up.
        %Sample one cycle into md data at .fps.
        %Based on all markers regardless of nn_showMarkers, before any replication of dots for scrambled mask cause don't want skew average.
                data_md = zeros(1,numMarkers,round(period*fps));
        for n_image = 1:size(data_md, 3)
            t = (n_image-1)/fps;

                data_md(1,:,n_image) = data(3,:,1);
            for n_harmonic = 1:numHarmonics
                data_md(1,:,n_image) = data_md(1,:,n_image)+data(3,:,2*n_harmonic).*sin(n_harmonic*(2*pi./period*t))+data(3,:,2*n_harmonic+1).*cos(n_harmonic*(2*pi./period*t));
            end
        end
        maxHeight = transpose(max(max(data_md, [], 2), [], 3)-min(min(data_md, [], 2), [], 3));
        
        sizeMult = height/maxHeight;
    if sizeMult == inf
        sizeMult = 1;
    end
end
data = sizeMult*data;


%Invert
if invert || invertLocal
    data(3,:,2:end) = -data(3,:,2:end);
end
if invert || invertGlobal
    data(3,:,1) = -data(3,:,1);
end


%Dot mean positions and mean position size
dotMeanPositions = data(:,:,1);
meanSize = [repmat(max((dotMeanPositions(1,:).^2+dotMeanPositions(2,:).^2).^(1/2))*2, 1, 2) max(dotMeanPositions(3,:))-min(dotMeanPositions(3,:))];


numImages = [];




%===============================================================================
elseif strcmp(dataRep, 'md')
    

    if invertLocal || invertGlobal
        error('Currently for md or C3D data, property .invert cannot = "local"/"global".')
    end
    if scramblePeriods
        error('Currently for md or C3D data, property .scramblePeriods must = false.')
    end


%Size
if isempty(sizeMult)
        sizeMult = height/(max(max(data(3,:,:), [], 2), [], 3)-min(min(data(3,:,:), [], 2), [], 3));
    if sizeMult == inf
        sizeMult = 1;
    end
end
data = sizeMult*data;


%Invert
if invert
    data(3,:,:) = -data(3,:,:);
end


%Dot mean positions and mean position size
dotMeanPositions = mean(data, 3);
meanSize = [repmat(max((dotMeanPositions(1,:).^2+dotMeanPositions(2,:).^2).^(1/2))*2, 1, 2) max(dotMeanPositions(3,:))-min(dotMeanPositions(3,:))];


%Trim to times to show after using all loaded times for centering and sizing
showTimes = floor(showTimes*fps);
showTimes(2) = min(showTimes(2), size(data, 3));
    if ~(showTimes(1) < showTimes(2))
        error(['In property .showTimes: .showTimes(1) must be < .showTimes(2) and loaded motion data duration (' num2str(size(data, 3)/fps) ' sec).'])
    end
data = data(:,:,showTimes(1)+1:showTimes(2));

numImages = size(data, 3);




%===============================================================================
end




%Dots
%---
if isempty(nn_showMarkers)
    nn_showDots = 1:numMarkers;
else
    %Show set markers only.
    %dotSize, nn_showMarkers only makes dots invisible--could still draw sticks between them.
    nn_showDots = nn_showMarkers;
        if ~all(nn_showDots <= numMarkers)
            error(['In property .nn_showMarkers: Some marker numbers > number of markers loaded in data (' num2str(numMarkers) ').'])
        end

    %Remove duplicates cause don't want them in draw functions later
    [~, ii] = ismember(nn_showDots, nn_showDots);
    ii = ii(ii == 1:numel(nn_showDots));
    nn_showDots = nn_showDots(ii);
end
if (scramble > 0 || scrambleHorz || scrambleVert) && ~isempty(numScrambleDots)
    %Mask: replicate from nn_showDots to numScrambleDots, so in this case dots not in nn_showMarkers actually gone.
    %Checked can only if dotSize > 0 (and nn_showMarkers always shows at least one dot), stickWidth = 0.
    
    m = floor(numScrambleDots/numel(nn_showDots));
    r = rem(numScrambleDots, numel(nn_showDots));
    
    nn_r = randperm(numel(nn_showDots), r);
    data =             	[repmat(            data(:,nn_showDots,:), 1, m, 1)             data(:,nn_r,:)];
    dotMeanPositions =	[repmat(dotMeanPositions(:,nn_showDots  ), 1, m   ) dotMeanPositions(:,nn_r  )];
    nn_showDots = 1:numScrambleDots;
end
%Maybe still have sticks
if dotSize == 0
    nn_showDots = [];
end

%numDots = actual number of dots to compute (visible and invisible).
% = either number of markers in data or number of mask dots.
numDots = size(data, 2);
%---
 

%Sticks
%---
if stickWidth > 0
        if ~allish(nn_stickMarkers <= numMarkers)
            error(['In property .nn_stickMarkers: Some marker numbers > number of markers loaded in data (' num2str(numMarkers) ').'])
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


this.fps = fps;
this.nn_stickMarkers = nn_stickMarkers;
this.dataRep = dataRep;
this.numHarmonics = numHarmonics;
this.numImages = numImages;
this.numDots = numDots;
this.nn_showDots = nn_showDots;




if numDots > 0
    
    
    
    
%Processing different for mm/md data:
%Scrambling, periods/phases/speed, translation velocity
%===============================================================================
if strcmp(dataRep, 'mm')


%Dot positions.
%Maybe update mean size.
if scramble > 0 || scrambleHorz || scrambleVert
    dotMeanPositions_scrambled = scrambleDotMeanPositions(dotMeanPositions, numDots, scramble, scrambleHorz, scrambleVert, meanSize, scrambleAreaSize);
    data(:,:,1) = dotMeanPositions_scrambled;
end


%Rotate if azimuth velocity = 0.
%Order (important!): Azimuth + azimuth velocity, elevation.
%Walker centered at [0 0 0] in walker space in open script so rotate doesn't translate.
if azimuthVelocity == 0
        az = azimuth;
        el = elevation;
        r = [cosd(el) 0 sind(el); 0 1 0; -sind(el) 0 cosd(el)]*[cosd(az) -sind(az) 0; sind(az) cosd(az) 0; 0 0 1];
    for i = 1:size(data, 3)
        data(:,:,i) = r*data(:,:,i);
    end
%else need to wait for frames for azimuth, so also elevation
end


%Dot periods
if scramblePeriods
    %Scramble dot periods.
    %Period for each dot is divided by a number between 1/r ... r drawn from a logarithmic uniform distribution (i.e. uniform between -ln(r) ... ln(r) in log space).
    
    periods = period/speed./exp((2*rand(1, numDots)-1)*log(scramblePeriodDelta));
else
    %Dots have uniform period
    periods = repmat(period/speed, [1 numDots]);
end


%Dot phases (-> rad for later)
        %s -> rad.
        %If outside 0 ... 2*pi and partial scrambling doesn't matter--mod formula below deals with that too.
        phase = phase*2*pi;
        phases = repmat(phase, [1 numDots]);
if scramblePhases > 0
        %Get fully scrambled phases
        phases_scrambled = 2*pi*rand(1, numDots);
    if scramblePhases < 1
        %Partially scrambled
        phases_scrambled = phases+scramblePhases*(mod(phases_scrambled-phases+pi, 2*pi)-pi);
    end
        phases = phases_scrambled;
end


%Translation
if translate
    %Apply translation velocity in mm data.
    %Convert time from images to sec.
    translationVelocity = translationSpeed_mm*fps;
%else maybe user set translationVelocity
end
    %Convert distance from mm to px (includes scaling by height/sizeMult), scale by speed.
    translationVelocity = translationVelocity*sizeMult*speed;
translationPosition = 0;


%Texture size.
%Sized to fit walker display at any time point, + padding = dotSize on each side, then dots won't be clipped when they are at the edges.
%(dotSize/2 padding would be sufficient in theory but we use dotSize to be safe and for simplicity.)
%Walker mean position will be centered on texture, so use greatest deviation from mean position.
%Use upper bound on on bounding size by triangle inequality: bounding size <= sum of lengths of Fourier coefficients.
    d = abs(data);
if translationVelocity ~= 0
    %horz translation velocity not = 0 -> width = whole window
    w = windowSize(1)+2*abs(position(1)-windowCenter(1));
elseif azimuthVelocity ~= 0
    %azimuth velocity not = 0 -> width = horz radius
    w = 2*max((sum(d(1,:,:), 3).^2+sum(d(2,:,:), 3).^2).^(1/2), [], 2);
else
    %width = walker y
    w = 2*max(sum(d(2,:,:), 3), [], 2);
end
if azimuthVelocity ~= 0 && elevation ~= 0
    %elevation not applied and not = 0, and azimuth velocity not = 0 -> height = spherical radius
    h = 2*max((sum(d(1,:,:), 3).^2+sum(d(2,:,:), 3).^2+sum(d(3,:,:), 3).^2).^(1/2), [], 2);
else
    %elevation applied or = 0 -> height = walker z
    h = 2*max(sum(d(3,:,:), 3), [], 2);
end
    textureSize = [w h]+2*dotSize;
    textureCenter = (textureSize+1)/2;


numImagesWithBreak = [];




%===============================================================================
elseif strcmp(dataRep, 'md')


%Dot positions.
%Maybe update mean size.
if scramble > 0 || scrambleHorz || scrambleVert
    dotMeanPositions_scrambled = scrambleDotMeanPositions(dotMeanPositions, numDots, scramble, scrambleHorz, scrambleVert, meanSize, scrambleAreaSize);
    data = data+repmat(-dotMeanPositions+dotMeanPositions_scrambled, [1 1 numImages]);
end


%Rotate if azimuth velocity not = 0
if azimuthVelocity == 0
        az = azimuth;
        el = elevation;
        r = [cosd(el) 0 sind(el); 0 1 0; -sind(el) 0 cosd(el)]*[cosd(az) -sind(az) 0; sind(az) cosd(az) 0; 0 0 1];
    for i = 1:size(data, 3)
        data(:,:,i) = r*data(:,:,i);
    end
end


%If negative speed reverse data, then also speed, phase so can use same algo in frames.
%Also then if phase = 0 and no repeat, plays in reverse instead of ends immediately.
if speed < 0
    data = flip(data, 3);
    speed = -speed;
    phase = -phase;
end


%Phase -> images, wrap to 0 ... numImages
phase = mod(phase*fps, numImages);
            
if scramblePhases > 0
    %Scramble dot phases.
    %Will scramble centered on .phase when .phase is applied in runFrame.
    
        %Get fully scrambled phases between [0 numImages-1].
        %Assume rand never returns 0 or 1.
        phases_scrambled = round(numImages*rand(1, numDots)-0.5);
    if scramblePhases < 1
        %Partially scrambled
        phases_scrambled = round(scramblePhases*(mod(phases_scrambled+numImages/2, numImages)-numImages/2));
    end

        %Circular shift data across time dimension
    for n_dot = 1:numDots
        data(:,n_dot,:) = circshift(data(:,n_dot,:), -phases_scrambled(n_dot), 3);
    end
end


%Number of images with repeat break
%Scale by speed so break interval stays as set in sec for speeds ~= 1 given algo in runFrames.
numImagesWithBreak = numImages+round(breakInterval*fps*speed);


%Translation.
%Convert distance from mm to px (includes scaling by height/sizeMult), scale by speed.
translationVelocity = translationVelocity*sizeMult*speed;
translationPosition = 0;


%Texture size
if translationVelocity ~= 0
    %horz translation velocity not = 0 -> width = whole window
    w = windowSize(1)+2*abs(position(1)-windowCenter(1));
elseif azimuthVelocity ~= 0
    %azimuth velocity not = 0 -> width = horz radius
    w = 2*max(max((data(1,:,:).^2+data(2,:,:).^2).^(1/2), [], 2), [], 3);
else
    %width = walker y
    w = 2*max(max(abs(data(2,:,:)), [], 2), [], 3);
end
if azimuthVelocity ~= 0 && elevation ~= 0
    %elevation not applied and not = 0, and azimuth velocity not = 0 -> height = spherical radius
    h = 2*max(max((data(1,:,:).^2+data(2,:,:).^2+data(3,:,:).^2).^(1/2), [], 2), [], 3);
else
    %elevation applied or = 0 -> height = walker z
    h = 2*max(max(abs(data(3,:,:)), [], 2), [], 3);
end
    textureSize = [w h]+2*dotSize;
    textureCenter = (textureSize+1)/2;


periods = [];
phases = [];




%===============================================================================
end




if ~isempty(scrambleSeed)
    %Re-shuffle rng for other elements
    rng('shuffle')
end


this.speed = speed;
this.phase = phase;
this.data = data;
this.numImagesWithBreak = numImagesWithBreak;
this.periods = periods;
this.phases = phases;
this.translationVelocity = translationVelocity;
this.translationPosition = translationPosition;
this.textureSize = textureSize;
this.textureCenter = textureCenter;


end




function [fps, dataRep, data, numMarkers, numHarmonics, period, translationSpeed_mm] = loadData(fileName, dataExpr, fps, nn_markers, times) %local


%Load walker data, get data format
%---
if ~isempty(fileName)
    %Load from file
    
        %Standardize this error message across mat, c3d
        if ~exist(fileName, 'file')
            error(['In property .fileName: ' fileName ' does not exist or is not on the MATLAB search path.'])
        end
    
    if strendsi(fileName, '.mat')
        try
            s = load(fileName);
        catch X
                error(['In property .fileName: Cannot load ' fileName '.' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
        end

        varNames = row(fieldnames(s));
        if isempty(dataExpr) && numel(varNames) == 1
            %One variable in file and no data expr set -> take variable

                data = s.(varNames{1});
        else
            %More than one variable in file or data expr set

                    if isempty(dataExpr)
                        error([fileName ' contains more than one variable. You must specify variable name in property .dataExpr.'])
                    end
                i = min([find(ismember(dataExpr, '({.'), 1) length(dataExpr)+1]);
                dataVarName = dataExpr(1:i-1);
                dataIndexes = dataExpr(i:end);    
                    if ~any(strcmp(dataVarName, fieldnames(s)))
                        error(['Variable "' dataVarName '" does not exist in ' fileName '.'])
                    end
                dataVar = s.(dataVarName); %#ok<NASGU>
            try
                data = eval(['dataVar' dataIndexes]);
            catch X
                    error(['In property .dataExpr: Cannot get ' dataExpr ' in ' fileName '.' 10 ...
                        '->' 10 ...
                        10 ...
                        X.message])
            end
        end
            if isempty(fps)
                %Default fps = 120 Hz for mm/md data
                fps = 120;
            end
    else
        %Load from c3d file, get fps and convert to md matrix.
        try
                c3d = readc3d(fileName);
                data = zeros(length(c3d.VideoData.Channels(1).xdata), numel(c3d.VideoData.Channels), 3);
            for n_marker = 1:numel(c3d.VideoData.Channels)
                data(:,n_marker,1) = c3d.VideoData.Channels(n_marker).xdata;
                data(:,n_marker,2) = c3d.VideoData.Channels(n_marker).ydata;
                data(:,n_marker,3) = c3d.VideoData.Channels(n_marker).zdata;
            end
            %readc3d applies header scale automatically if applicable
            if isempty(fps)
                %Default fps = from file for C3D
                fps = c3d.Header.VideoHZ;
            end
        catch X
            error(['In property .fileName: Cannot load ' fileName '.' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
        end
    end
else
    %Load from base workspace
    
    try
        data = evalin('base', dataExpr);
    catch X
            error(['In property .dataExpr: Cannot get ' dataExpr ' in the base MATLAB workspace.'])
    end
    if isempty(fps)
        %Default fps = 120 Hz for mm/md data
        fps = 120;
    end
end

    if ~(isa(data, 'numeric') && any(ndims(data) == [2 3]))
        error('Data must be a 2D (mm) or 3D (md) matrix or a .c3d file.')
    end
if ndims(data) == 2 %#ok<ISMAT>
    dataRep = 'mm';
elseif ndims(data) == 3
    dataRep = 'md';
end
%---




%Processing different for mm/md data:
%Read and format data, center
%===============================================================================
if strcmp(dataRep, 'mm')


    %Must have at least 1 marker
    if ~(size(data, 1) >= 4 && mod(size(data, 1)-1, 3) == 0 && size(data, 2) >= 2)
        error('Data appears to be mm format but must have (number of markers)*3 + 1 rows and >= 2 columns.')
    end
    
%Get period, mm trans speed, get data.
%Period converted from images -> sec here. mm trans speed left cause need in mm/image for now.
%Don't need mm size factor--all gets plastered over when sizing.
%Note mm trans speed already scaled by mm size factor.
period = data(end,1)/fps;
translationSpeed_mm = data(end,3);
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

%Reshape into standard coords x markers x harmonics
data = permute(reshape(data, size(data, 1)/3, 3, []), [2 1 3]);

%Cut to markers to keep
if ~isempty(nn_markers)
        if ~all(nn_markers <= size(data, 2))
            error(['In property .nn_markers: Some marker numbers > number of markers in data (' size(data, 2) ').'])
        end
    data = data(:,nn_markers,:);
end

numMarkers = size(data, 2);
numHarmonics = (size(data, 3)-1)/2;


%Center at [0 0 0] in walker space.
%Based on mean of bounding marker mean positions -> marker motion time average discounting density of markers.
data(:,:,1) = data(:,:,1)-repmat(mean([min(data(:,:,1), [], 2) max(data(:,:,1), [], 2)], 2), 1, numMarkers);




%===============================================================================
elseif strcmp(dataRep, 'md')
    

    %Must have at least 1 marker and image
    if ~(size(data, 3) == 3 && ~isempty(data))
        error('Data appears to be md format but must be a (number of images) x (number of markers) x (3 coordinates) matrix.')
    end
    
%Reshape into standard coords x markers x images
data = permute(data, [3 2 1]);

%Cut to markers to keep
if ~isempty(nn_markers)
        if ~all(nn_markers <= size(data, 2))
            error(['In property .nn_markers: Some marker numbers > number of markers in data (' num2str(size(data, 2)) ').'])
        end
    data = data(:,nn_markers,:);
end

%Trim to time
times = floor(times*fps);
times(2) = min(times(2), size(data, 3));
    if ~(times(1) < times(2))
        error(['In property .times: .times(1) must be < .times(2) and motion data duration (' num2str(size(data, 3)/fps) ' sec).'])
    end
data = data(:,:,times(1)+1:times(2));

numMarkers = size(data, 2);
numImages = size(data, 3);


%Center
data = data-repmat(mean([min(mean(data, 3), [], 2) max(mean(data, 3), [], 2)], 2), 1, numMarkers, numImages);


numHarmonics = [];
period = [];
translationSpeed_mm = [];




%===============================================================================
end


end %loadData




function dotMeanPositions_scrambled = scrambleDotMeanPositions(dotMeanPositions, numDots, scramble, scrambleHorz, scrambleVert, meanSize, scrambleAreaSize) %local


%Use cylindrical coords -> new mean positions within a cylinder, display will be y-z cross-section.
%Use cylinder instead of cube cause if have az vel need to rotate whole
%structure rigidly like a veridical walker, so this preserves average density of
%markers in cross-section display.
    
    dotMeanPositions_scrambled = dotMeanPositions;
%     meanSize_scrambled = meanSize;
if scramble > 0 || scrambleHorz
    %Get fully scrambled horz mean positions
    
    if isa(scrambleAreaSize, 'char') && strcmpi(scrambleAreaSize, 'f')
        %Cylinder bounding walker
        w = meanSize(1);
    else
        %Set cylinder
        w = scrambleAreaSize(1);
    end
    rr  = w/2*rand(1, numDots);
    tth = 2*pi*rand(1, numDots);
    dotMeanPositions_scrambled(1,:) = rr.*cos(tth);
    dotMeanPositions_scrambled(2,:) = rr.*sin(tth);
%     
%     meanSize_scrambled(1:2) = w;
end
if scramble > 0 || scrambleVert
    %Get fully scrambled vert mean positions
    
    if isa(scrambleAreaSize, 'char') && strcmpi(scrambleAreaSize, 'f')
        h = meanSize(3);
    else
        h = scrambleAreaSize(2);
    end
    zz  = h*(rand(1, numDots)-0.5);
    dotMeanPositions_scrambled(3,:) = zz;
%     
%     meanSize_scrambled(3) = h;    
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
    q = 2*pi*rand(1, 3);
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
%     
%     %Walker somewhere between veridical and scrambled.
%     %Take mean size = max of them.
%     meanSize_scrambled = max(meanSize, meanSize_scrambled);
end


end %scrambleDotMeanPositions