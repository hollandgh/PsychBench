areaRects = this.areaRects;
cursorShape = this.cursorShape;
tf_buttonsDown_prev = this.tf_buttonsDown_prev;
pollTime_prev = this.pollTime_prev;
n_window = this.n_window;
isStarting = this.isStarting;


%Get mouse cursor position and button #s down using PTB GetMouse
[x, y, tf_buttonsDown] = GetMouse(n_window);
%Get mouse poll time using PTB GetSecs
pollTime = GetSecs;


if isStarting
    %OBJECT FRAME 0
    %Object starting at next frame start (frame 1 start)
    %===
    
    %Show mouse cursor when object starts.
    %PsychBench automatically hides mouse cursor if no other objects using it when object ends.
    this = element_showMouseCursor(this, cursorShape);
    
    
else
    %OBJECT RUNNING
    %===
    
    %Look for mouse button PRESS: if buttons are down and different from prev frame.
    %Omit check in object frame 0 cause don't have buttons down or poll time from prev
    %frame. Also if a buttons is already down from before object starts we don't
    %want to register it. So first frame object can register a button press is 
    %object frame 1.

    tf_buttonsClicked = tf_buttonsDown & ~tf_buttonsDown_prev;
    if any(tf_buttonsClicked)
        if isempty(areaRects)
            %Mouse button mode -> response = button #(s)
            responses = find(tf_buttonsClicked);
        else
            %Screen area mode -> response = rect #(s).
            %Check if click was in a rect.
            responses = transpose(find(x > areaRects(:,1) & x <= areaRects(:,3) & y > areaRects(:,2) & y <= areaRects(:,4)));
        end
        for response = responses
            %Register response.
            %Also ends object at end of this frame if maximum number responses registered.
            %If max num responses reached and call element_registerResponse again in this loop, just does nothing.
            
            this = element_registerResponse(this, response, pollTime_prev, pollTime);
        end
    end
    
%     %[TEST]
%     Screen('FillRect', n_window, [], transpose(areaRects))
end


this.tf_buttonsDown_prev = tf_buttonsDown;        
this.pollTime_prev = pollTime;