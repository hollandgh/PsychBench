n_device = this.n_device;
fontSize = this.fontSize;
color = this.color;
margin = this.margin;
boxColor = this.boxColor;
enterResponds = this.enterResponds;
recordNumeric = this.recordNumeric;
cursorWidth = this.cursorWidth;
lineHeight = this.lineHeight;
stops = this.stops;
text = this.text;
cursorPosition = this.cursorPosition;
cursorPoints = this.cursorPoints;
n_boxTexture = this.n_boxTexture;
n_texture = this.n_texture;
n_characterDown = this.n_characterDown;
repeatTime = this.repeatTime;


%Time from object start
t = GetSecs-this.startTime;


if this.isStarting
    %OBJECT FRAME 0
    %Object starting at next frame start (frame 1 start)
    %===

    %Start keyboard queue using PTB KbQueueStart.
    %Clear any key events in queue since last object used it in case last object didn't stop it.
    KbQueueStart(n_device)
    KbEventFlush(n_device);
    
    if ~enterResponds
        %If mouse click to response show mouse cursor when object starts.
        %PsychBench automatically hides mouse cursor if no other objects using it when object ends.
        this = element_showMouseCursor(this);
    end


else
    %OBJECT RUNNING
    %===
    
            nn_drawCharacters = [];
    %Get key presses/releases since previous check using PTB KbEventGet.
    %In principle better than KbQueueCheck cause KbQueueCheck can miss > 2 presses of the same key since last check.
        [ee, numKeyEventsRemainingInBuffer] = KbEventGet(n_device);
    for n = 1:numKeyEventsRemainingInBuffer
        e = KbEventGet(n_device);
        ee = [ee e];
    end
    if ~isempty(ee)
        nn_charactersPressed = [ee([ee(:).Pressed] == 1 & ( ...
            [ee(:).CookedKey] == 8   | ... % backspace
            [ee(:).CookedKey] == 10  | ... % line feed
            [ee(:).CookedKey] == 13  | ... % enter
            [ee(:).CookedKey] >= 32  & ... % 32 = space
            [ee(:).CookedKey] <= 126   ... 
            )).CookedKey];
        if ~isempty(nn_charactersPressed)
            %Draw all character numbers in order pressed (maybe multiple since previous frame)
            nn_drawCharacters = nn_charactersPressed;
            
            %Setup repeat for most recent character pressed in case will hold down
            n_characterDown = nn_charactersPressed(end);
            repeatTime = t+0.5;
        end
        
        %PTB bug that .CookedKey is only reported for key presses, not releases, so just clear character down if any key released
        if any([ee(:).Pressed] == 0)
            n_characterDown = [];
        end
    end
        if ~isempty(n_characterDown) && t > repeatTime
            %Draw characters held down and time for repeat
            nn_drawCharacters = n_characterDown;

            %Update time for next repeat.
            %Allow for possible dropped frames since prev repeat.
            repeatTime = repeatTime+ceil((t-repeatTime)*10)/10;
        end
                
    if enterResponds
                    %Response if enter pressed.
                    %Initialize and check below.
                    respond = false;
    else
                    %Response if any mouse button clicked
                    [~, ~, tff] = GetMouse;
                    respond = any(tff);
    end
    for n_character = nn_drawCharacters
        if n_character == 8
            %Backspace

            if ~(numel(text) == 1 && isempty(text{1}))
                if isempty(text{end})
                    %Delete line break
                    text(end) = [];
                else
                    %Delete character
                    text{end}(end) = [];
                end

                %Redraw text without deleted character
                    Screen('FillRect', n_boxTexture, boxColor)
                    cursorPosition = [margin margin+fontSize];
                for n_line = 1:numel(text)-1
                    Screen('DrawText', n_boxTexture, text{n_line}, cursorPosition(1), cursorPosition(2), [], [], 1);
                    cursorPosition(2) = cursorPosition(2)+lineHeight;
                end
                if ~isempty(text{end})
                    [cursorPosition(1), cursorPosition(2)] = Screen('DrawText', n_boxTexture, text{end}, cursorPosition(1), cursorPosition(2), [], [], 1);
                end
                    cursorPoints = [cursorPosition cursorPosition]+[0.1*fontSize -0.9*fontSize 0.1*fontSize 0.1*fontSize];
            %else nothing to delete
            end
        else
            if n_character == 10 || n_character == 13
                %Enter

                if enterResponds
                    %Response
                    respond = true;
                    break
                elseif cursorPosition(2)+lineHeight < stops(2)
                    %New line with carriage return
                    text{end} = [text{end} 13];
                    text = [text {''}];

                    cursorPosition(1) = margin;
                    cursorPosition(2) = cursorPosition(2)+lineHeight;
                    cursorPoints = [cursorPosition cursorPosition]+[0.1*fontSize -0.9*fontSize 0.1*fontSize 0.1*fontSize];
                %else would go past bottom stop -> ignore
                end
            else
                %Printed character

                if n_character == 9
                    %tab
                    character = '    ';
                else
                    character = char(n_character);
                end

                text{end} = [text{end} character];

                [cursorPosition(1), cursorPosition(2)] = Screen('DrawText', n_boxTexture, character, cursorPosition(1), cursorPosition(2), [], [], 1);
                if character(end) ~= ' ' && cursorPosition(1) >= stops(1)
                    if cursorPosition(2)+lineHeight < stops(2)
                        %Cursor now past right stop -> wrap to next line

                        %Wrap at word break if any, but no carriage return
                        i = min([find(text{end} == ' ', 1, 'last') length(text{end})-1]);
                        text = [text {text{end}(i+1:end)}];
                        text{end-1} = text{end-1}(1:i);
                    else
                        %Would go past bottom stop -> ignore character

                        %Wrap at word break if any, but no carriage return
                        text{end}(end) = [];
                    end

                        %Redraw text with wrapped text on next line
                            Screen('FillRect', n_boxTexture, boxColor)
                            cursorPosition = [margin margin+fontSize];
                        for n_line = 1:numel(text)-1
                            Screen('DrawText', n_boxTexture, text{n_line}, cursorPosition(1), cursorPosition(2), [], [], 1);
                            cursorPosition(2) = cursorPosition(2)+lineHeight;
                        end
                            [cursorPosition(1), cursorPosition(2)] = Screen('DrawText', n_boxTexture, text{end}, cursorPosition(1), cursorPosition(2), [], [], 1);
                end
                cursorPoints = [cursorPosition cursorPosition]+[0.1*fontSize -0.9*fontSize 0.1*fontSize 0.1*fontSize];
            end
        end
    end
    
    if respond
        %Register response.
        %Also ends object at end of this frame if maximum number responses registered.
        %If max num responses reached and call element_registerResponse again in this loop, just does nothing.

                %Concatenate into one string except carriage returns inserted by enter stay -> line breaks
                response = [text{:}];
                response = strrep(response, char(13), char(10));
        if recordNumeric
            %Try convert to number
            r = str2double(response);
            if ~isnan(r)
                response = r;
            else
                respond = false;
                    %Convert to number failed -> beep and ignore response, wait 200 msec to allow mouse button release
                    beep
                    WaitSecs(0.2);
            end
        else            
                response = string(response);
        end
    if respond
        this = element_registerResponse(this, response);
    end
    end    

    
    if this.isEnding    
        %LAST OBJECT FRAME
        %Object will end at frame end at cue set by user or max num responses
        %===

        %Stop keyboard queue using PTB KbQueueStop
        KbQueueStop(n_device)
        
        
    end
end


if ~this.isEnding
    %Draw current image to window to show in next frame.
    %Don't draw in last object frame cause then there is no next frame.
    
    if mod(t, 1) < 0.5
        %Draw text box to window
        this = element_draw(this, n_boxTexture);
    else
        %Blinking cursor on -> overlay on text box and draw to window
        Screen('DrawTexture', n_texture, n_boxTexture)
        Screen('DrawLine', n_texture, color, cursorPoints(1), cursorPoints(2), cursorPoints(3), cursorPoints(4), cursorWidth)
        this = element_draw(this, n_texture);
    end
end


this.text = text;
this.cursorPosition = cursorPosition;
this.cursorPoints = cursorPoints;
this.n_characterDown = n_characterDown;
this.repeatTime = repeatTime;