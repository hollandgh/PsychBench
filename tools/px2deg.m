function [x, screenHeight_px, screenHeight_cm, screenDistance_cm] = px2deg(x, screenHeight_px, screenHeight_cm, screenDistance_cm, exponent, varargin)

% 
% [val_deg, screenHeight_px, screenHeight_cm, screenDistance_cm] = PX2DEG(val_px, [screenHeight_px], [screenHeight_cm], [screenDistance_cm], [exponent], [flag])
%     [input] = for default you can input [], or omit if you don't use any inputs after it.
% 
% Converts pixels to degrees visual angle using the standard formula:
%
% val_deg = atan2d(val_px/screenHeight_px*screenHeight_cm/2, screenDistance_cm)*2;
%
% You can convert values with any exponent on the px, e.g. 1/px. You can also 
% input a flag to use the small angle approximation tan(theta) =~ theta.
% 
% Overall usage is analogous to deg2px()--see help for that function.
%
% Requires Psychtoolbox if you don't specify screen sizes explicitly.
% 
% 
% See also deg2px.


% Giles Holland 2022, 2024


if nargin < 2 || isempty(screenHeight_px)
    screenHeight_px = [];
end
if nargin < 3 || isempty(screenHeight_cm)
    screenHeight_cm = [];
end
if nargin < 4 || isempty(screenDistance_cm)
    screenDistance_cm = [];
end
if nargin < 5 || isempty(exponent)
    exponent = 1;
end
flags = varargin;


    if nargin < 1
        error('Not enough inputs.')
    end
    if ~isa(x, 'numeric')
        error('Value must be numeric.')
    end
    if  ~( ...
        isOneNum(screenHeight_px) && screenHeight_px > 0 || ...
      	isa(screenHeight_px, 'cell') && numel(screenHeight_px) == 1 && isOneNum(screenHeight_px{1}) && isIntegerVal(screenHeight_px{1}) && screenHeight_px{1} >= 0 || ...
        isempty(screenHeight_px) ...
        )
    
        error('Display panel height in px must be a number > 0, a cell containing an integer {x} >= 0, or [].')
    end
    if  ~( ...
        isOneNum(screenHeight_cm) && screenHeight_cm > 0 || ...
      	isa(screenHeight_cm, 'cell') && numel(screenHeight_cm) == 1 && isOneNum(screenHeight_cm{1}) && isIntegerVal(screenHeight_cm{1}) && screenHeight_cm{1} >= 0 || ...
        isempty(screenHeight_cm) ...
        )
    
        error('Display panel height in cm must be a number > 0, a cell containing an integer {x} >= 0, or [].')
    end
    if ~(isOneNum(screenDistance_cm) && screenDistance_cm > 0 || isempty(screenDistance_cm))
        error('Display panel distance must be a number > 0, or [].')
    end
    if ~(isOneNum(exponent) && isIntegerVal(exponent) && exponent ~= 0)
        error('Exponent must be an integer not = 0.')
    end
    
flags = var2char(flags);

    
    n_screen = [];
    
if isempty(screenHeight_px)
    %Get screen height automatically using PTB if only one screen attached
    
        n_screen = Screen('Screens');
            if numel(n_screen) ~= 1
                error('Multiple display devices are attached, so you must specify values or a screen number for display panel heights in px and cm. (Or if you recently disconnected some display devices, type "clear Screen" so Psychtoolbox knows about it.)')
            end
        
        [~, screenHeight_px] = Screen('WindowSize', n_screen);
elseif isa(screenHeight_px, 'cell')
    %Get screen height automatically using PTB from specified screen number
    
        n_screen = screenHeight_px{1};
            if n_screen > max(Screen('Screens'))
                error('Specified display device is not attached. (Or if you recently connected the device, type "clear Screen" so Psychtoolbox knows about it.)')
            end
        
        [~, screenHeight_px] = Screen('WindowSize', n_screen);
%else height specified
end

if isempty(screenHeight_cm)
    %Get screen height automatically using PTB if only one screen attached
    
    if isempty(n_screen)
        %Screen height (px) specified directly above
        n_screen = Screen('Screens');
            if numel(n_screen) ~= 1
                error('Multiple display devices are attached, so you must specify values or a screen number for display panel heights in px and cm. (Or if you recently disconnected some display devices, type "clear Screen" so Psychtoolbox knows about it.)')
            end
    %else already got n_screen above
    end
    
        [~, screenHeight_cm] = Screen('DisplaySize', n_screen);
            if ~(isOneNum(screenHeight_cm) && screenHeight_cm > 0)
                error('Psychtoolbox could not get display panel height in cm. Please input it manually.')
            end
        screenHeight_cm = screenHeight_cm/10;
elseif isa(screenHeight_cm, 'cell')
    %Get screen height automatically using PTB from specified screen number
    
        n_screen = screenHeight_cm{1};
            if n_screen > max(Screen('Screens'))
                error('Specified display device is not attached. (Or if you recently connected the device, type "clear Screen" so Psychtoolbox knows about it.)')
            end
        
        [~, screenHeight_cm] = Screen('DisplaySize', n_screen);
            if ~(isOneNum(screenHeight_cm) && screenHeight_cm > 0)
                error('Psychtoolbox could not get display panel height in cm. Please input it manually.')
            end
        screenHeight_cm = screenHeight_cm/10;
%else height specified
end

if isempty(screenDistance_cm)
    %Default distance
    screenDistance_cm = 3*screenHeight_cm;
end


%Convert
%---
%Handle exponent on deg unit
s = sign(x);
x = abs(x).^(1/exponent);

if any(strcmpi(flags, '--'))
    x = x/pi*180/screenDistance_cm*screenHeight_cm/screenHeight_px;
else
    x = atan2d(x/screenHeight_px*screenHeight_cm/2, screenDistance_cm)*2;
end

x = s.*x.^exponent;
%---