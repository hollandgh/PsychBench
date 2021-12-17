width = this.width;
color = this.color;
nn_eyes = this.nn_eyes;
numLines = this.numLines;
coords = this.coords;
n_window = this.n_window;
isEnding = this.isEnding;
stereo = resources.screen.stereo;


if WITHPTB
    %Draw display to screen to show in next frame.
    %Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
    %Don't draw in last object frame cause then there is no next frame.
    %Direct draw to screen instead of texture method cause uses PTB DrawLines with
    %smoothing, which needs alpha blending enabled on target surface, which means
    %final background must be present.
    %width, color, nn_eyes, opacity applied here.
    if ~isEnding
        if stereo == 0
                Screen('DrawLines', n_window, coords, width, color, [], 2);
        else
            for n_eye = nn_eyes
                this = element_setEye(this, n_eye);
                Screen('DrawLines', n_window, coords, width, color, [], 2);
            end
        end
    end
    
    
else %WITHMGL
    %MGLTODOTENT VECTORIZE ONCE HAVE SYNTAX, INCLUDING SYNTAX FOR WIDTH/COLOR
        if stereo == 0
                for n_line = 1:numLines
                    mglLines2(coords(1,n_line), coords(2,n_line), coords(1,n_line+1), coords(2,n_line+1), width, color(n_line,:))
                end
        else
            for n_eye = nn_eyes
                this = element_setEye(this, n_eye);

                for n_line = 1:numLines
                    mglLines2(coords(1,n_line), coords(2,n_line), coords(1,n_line+1), coords(2,n_line+1), width, color(n_line,:))
                end
            end
        end    
    
        
end