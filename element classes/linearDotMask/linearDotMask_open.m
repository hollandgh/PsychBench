%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Convert deg units to px
this.size = element_deg2px(this.size);
this.dotSpeed = element_deg2px(this.dotSpeed);
this.dotSize = element_deg2px(this.dotSize);
%---


siz = this.size;
numDots = this.numDots;
dotDirection = this.dotDirection;
dotSpeed = this.dotSpeed;
dotLifetime = this.dotLifetime;
dotSize = this.dotSize;
color = this.color;
position = this.position;
opacity = this.opacity;
n_window = this.n_window;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if numel(siz) == 1
    siz = [siz siz];
end
if ~(isRowNum(siz) && numel(siz) == 2 && all(siz > 0))
    error('Property .size must be a number or 1x2 vector of numbers > 0.')
end
this.size = siz;

if ~(isOneNum(numDots) && isIntegerVal(numDots) && numDots >= 0)
    error('Property .numDots must be an integer >= 0.')
end

if ~(isRowNum(dotDirection) && any(numel(dotDirection) == [1 2]))
    error('Property .dotDirection must be a number, or a 1x2 vector with (2) >= 0.')
end
if numel(dotDirection) == 1
    dotDirection(2) = 0;
end
if ~(dotDirection(2) >= 0)
    error('Property .dotDirection must be a number, or a 1x2 vector with (2) >= 0.')
end
this.dotDirection = dotDirection;

if ~(isRowNum(dotSpeed) && any(numel(dotSpeed) == [1 2]))
    error('Property .dotSpeed must be a number >= 0, or a 1x2 vector with (1) >= 0, (2) >= 0, and (1)-(2) >= 0.')
end
if numel(dotSpeed) == 1
    dotSpeed(2) = 0;
end
if ~(dotSpeed(1) >= 0 && dotSpeed(2) >= 0 && dotSpeed(1)-dotSpeed(2) >= 0)
    error('Property .dotSpeed must be a number >= 0, or a 1x2 vector with (1) >= 0, (2) >= 0, and (1)-(2) >= 0.')
end
this.dotSpeed = dotSpeed;

if ~(isRowNum(dotLifetime) && any(numel(dotLifetime) == [1 2]))
    error('Property .dotLifetime must be a number >= 0, or a 1x2 vector with (1) >= 0, (2) >= 0, and (1)-(2) >= 0.')
end
if numel(dotLifetime) == 1
    dotLifetime(2) = 0;
end
if ~(dotLifetime(1) > 0 && dotLifetime(2) >= 0 && dotLifetime(1)-dotLifetime(2) > 0)
    error('Property .dotLifetime must be a number > 0, or a 1x2 vector with (1) >= 0, (2) >= 0, and (1)-(2) > 0.')
end
this.dotLifetime = dotLifetime;

if ~(isOneNum(dotSize) && dotSize > 0)
    error('Property .dotSize must be a number > 0.')
end
if ~(isRowNum(color) && numel(color) == 3 && all(color >= 0 & color <= 1))
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
%---


if WITHPTB
        [minDotSize, maxDotSize] = Screen('DrawDots', n_window);
        if ~(dotSize >= minDotSize && dotSize <= maxDotSize)
            error(['In property .dotSize: ' num2str(dotSize) ' px is out of range. On your system dots must be between ' num2str(minDotSize) '-' num2str(maxDotSize) ' px.'])
        end
    
    
    %Merge into RGBA for PTB DrawDots
    color = [color opacity];
    
        
else %WITH MGL
    %Dot size = radius for mglGluDisk
    dotSize = dotSize/2;
    
    
end


%Mask area rect centered at object position on screen.
%Using screen coordinates cause will direct draw to on-screen window later in frames.
%PsychBench translated position to relative to screen top left for class scripts.
rect = [0 0 siz]-repmat((siz+1)/2, 1, 2)+[position position];

%Won't use texture method for showing object display, so tell PsychBench display size (approx)
this = element_setDisplaySize(this, siz);

%Initial dot positions, directions, speeds, lifetimes, ages.
%Positions formatted for PTB DrawDots later.
%If numDots = 0 might increase by adjustment in frames.
dotPositions = [rect(1)+rand(1,numDots)*siz(1); rect(2)+rand(1,numDots)*siz(2)];
dotDirections = dotDirection(1)+(2*rand(1,numDots)-1)*dotDirection(2);
dotSpeeds = dotSpeed(1)+(2*rand(1,numDots)-1)*dotSpeed(2);
dotLifetimes = dotLifetime(1)+(2*rand(1,numDots)-1)*dotLifetime(2);
%Random initial ages within lifetimes, else dots with no lifetime randomization all regenerate at the same time
dotAges = rand(1,numDots).*dotLifetimes;


this.dotSize = dotSize;
this.color = color;
this.rect = rect;
this.dotPositions = dotPositions;
this.dotDirections = dotDirections;
this.dotSpeeds = dotSpeeds;
this.dotLifetimes = dotLifetimes;
this.dotAges = dotAges;