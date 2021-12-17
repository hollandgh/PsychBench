if WITHPTB
    %Draw display to screen to show in next frame.
    %Static display so use element_redraw instead of element_draw for efficiency.
    %Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
    %Don't draw in last object frame cause then there is no next frame.
    %element_redraw automatically applies all core display functionality.
    if ~this.isEnding
        this = element_redraw(this, this.n_texture);
    end
    
    
else %WITHMGL
    siz = this.size;
    lineWidth = this.lineWidth;
    color = this.color;
    position = this.position;
    nn_eyes = this.nn_eyes;
    isEnding = this.isEnding;
    stereo = resources.screen.stereo;


    if ~isEnding
        %MGL needs direct draw to screen
        if stereo == 0
                mglFixationCross(siz, lineWidth, color, position)
        else
            for n_eye = nn_eyes
                this = element_setEye(this, n_eye);
                mglFixationCross(siz, lineWidth, color, position)
            end
        end        
    end


end