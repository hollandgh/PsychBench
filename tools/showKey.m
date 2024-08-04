function varargout = showKey(varargin)

% 
% SHOWKEY
% 
% SHOWKEY waits for you to press a key on the keyboard, then displays its
% PsychBench key name(s) as well as key number(s) on all operating systems 
% (Windows, Mac, Linux). If multiple keys are down, SHOWKEY shows each of them.
%
% OR
%
% "showKey all" outputs a cell array of all key names indexed by key number for
% the operating system you are on. Or "showKey windows", "showKey mac", "showKey linux" 
% does the same for a specified system.
%
% Notes:
% - Key names only generally match physical key markings on U.S. keyboards.
% - Linux key numbers are only available if you are currently on Linux.
%
%
% KEY NAMES/NUMBERS
%
% Key numbers are integers between 1-256 and depend on operating system. They
% are the same as used by Psychtoolbox functions like <a href="matlab:disp([10 10 10 '------------']), help KbCheck">KbCheck</a>.
%
% PsychBench key names are common across operating systems. They are intended to
% be simple and convenient--see below. Some keys also respond to multiple names
% for convenience, listed in brackets below. Key names are all lower case and
% generally correspond to the non-shifted characters on the keys.
%
% Letter keys:
%     a, b, c, ...
% Number keys on the main keyboard:
%     0, 1, 2, ...
% Punctuation keys:
%     `, -, =, ...
% Modifier keys:
%     leftshift,  leftctrl  (leftcontrol),  leftalt  (leftalternate,  leftopt,  leftoption),   leftsys  (leftwin,  leftwindows,  leftcmd,  leftcommand)
%     rightshift, rightctrl (rightcontrol), rightalt (rightalternate, rightopt, rightoption),  rightsys (rightwin, rightwindows, rightcmd, rightcommand)
%     capslock
% Action keys:
%     space, backspace (del, delete), enter (return), esc (escape), ins (insert), fwdel (fwdelete, forwarddelete)
% Navigation keys on the main keyboard:
%     left, right, up, down, home, end, pgup (pageup), pgdn (pagedown)
% Function keys:
%     f1, f2, f3, ...
% Keypad:
%     kp0, kp1, kp2, kp3, ... , kp., kp/, kp*, ... , kpenter (kpreturn)
% Other keys and keyboard signals:
%     Same as Psychtoolbox "unified" key names, except all lower case.
%     See Psychtoolbox <a href="matlab:disp([10 10 10 '------------']), help KbName">KbName</a>. 
%
% (Note PsychBench key names are not generally the same as Psychtoolbox unified
% key names.)
% 
% 
% See also keyName2Num, keyNum2Name.


% Giles Holland 2023


persistent keyNames_windows keyNames_mac keyNames_linux names2standards


flags = varargin;


try
    AssertOpenGL
catch
        error('Psychtoolbox framework failed (command AssertOpenGL()). Check that Psychtoolbox is installed correctly and on the MATLAB search path. See http://psychtoolbox.org.')
end

if ismac
    %Check for macOS security warning
    try
        PsychHID('Devices');
    catch X
            error(['Error from Psychtoolbox initializing input devices. Is MATLAB added and enabled in System Settings -> Privacy & Security -> Input Monitoring?' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
end


            varargout = {};
if nargin > 0
    if isempty(keyNames_windows)
        [keyNames_windows, keyNames_mac, keyNames_linux, names2standards] = getKeyNames;
    end
    
        
    if      any(strcmpi(flags, 'all'))
        if ispc
            varargout{1} = keyNames_windows;
        elseif ismac
            varargout{1} = keyNames_mac;
        else
            varargout{1} = keyNames_linux;
        end
        
    elseif  any(strcmpi(flags, {'windows' 'win'}))
            varargout{1} = keyNames_windows;
            
    elseif  any(strcmpi(flags, {'mac' 'macos'}))
            varargout{1} = keyNames_mac;
            
    elseif  any(strcmpi(flags, 'linux'))
                if ~(isunix && ~ismac)
                    error('Linux key name -> number mapping is only available on Linux.')
                end
                if isempty(keyNames_linux)
                    error('Key names are not available on this Linux distribution. Please use showKey() with no inputs to get key numbers and use those instead.')
                end
            varargout{1} = keyNames_linux;
            
    end
    
    
else
    %Get key press
    %---
        ListenChar(2)

    try
        [~, ~, tf_keysDownPrev] = KbCheck(-1); tf_keysDownPrev = logical(tf_keysDownPrev);

            tf_keysPressed = false(1, 256);
        while ~any(tf_keysPressed)
            %WaitSecs needed not just to not load processor but cause some keys with multiple numbers take time for both numbers to activate
            WaitSecs(0.01);

            [~, ~, tf_keysDown] = KbCheck(-1); tf_keysDown = logical(tf_keysDown);
            tf_keysPressed = tf_keysDown & ~tf_keysDownPrev;
            tf_keysDownPrev = tf_keysDown;
        end
    catch X
        ListenChar(0)
        rethrow(X)
    end

        ListenChar(0)

        
    if isempty(keyNames_windows)
        [keyNames_windows, keyNames_mac, keyNames_linux, names2standards] = getKeyNames;
    end
    
    
        nn = find(tf_keysPressed);
    if ~(isunix && ~ismac) || ~isempty(keyNames_linux)
        names = keyNum2Name(nn);
    else
        %On Linux distro where no key names available
        names = [];
    end
    %---


    %Display
    %---
    for i = 1:numel(nn)
        n = nn(i);
        
                        n_s = num2str(n);
        
        if ~isempty(names)
            name = names{i};

            if ~isempty(name)
                    n_windows = find(strcmp(keyNames_windows, name));
                    if isempty(n_windows)
                        n_windows_s = '(unknown)';
                    else
                        n_windows_s = num2str(n_windows);
                    end

                    n_mac = find(strcmp(keyNames_mac, name));
                    if isempty(n_mac)
                        n_mac_s = '(unknown)';
                    else
                        n_mac_s = num2str(n_mac);
                    end

                if ~isempty(keyNames_linux)
                    n_linux = find(strcmp(keyNames_linux, name));
                    if isempty(n_linux)
                        n_linux_s = '(unknown)';
                    else
                        n_linux_s = num2str(n_linux);
                    end
                else
                        n_linux_s = '(key numbers only available on Linux)';
                end

                    for j = row(find(strcmpi(names2standards(:,2), name)))
                        name = [name '  ' names2standards{j,1}]; %#ok<*AGROW>
                    end
            else
                        n_windows_s = '(unknown)';

                        n_mac_s = '(unknown)';

                    if ~isempty(keyNames_linux)
                        n_linux_s = '(unknown)';
                    else
                        n_linux_s = '(key numbers only available on Linux)';
                    end

                        name = '(unknown)';
            end
        else
            %On Linux distro where no key names available
                        
                        name = '(key names not available on this Linux distribution)';
                        n_windows_s = '(unknown)';
                        n_mac_s = '(unknown)';
                        n_linux_s = n_s;
        end

        disp([10 ...
            'Number pressed: ' n_s 10 ...
            'Names:          ' name 10 ...
            'Numbers' 10 ...
            '    Windows:    ' n_windows_s 10 ...
            '    Mac:        ' n_mac_s 10 ...
            '    Linux:      ' n_linux_s 10 ...
            ...
            ])
    end
    %---
    
    
end