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
    %MGLTODOTENT
%     siz = this.size;
%     showFill = this.showFill;
%     color = this.color;
%     position = this.position;
%     nn_eyes = this.nn_eyes;
%     isEnding = this.isEnding;
%     stereo = resources.screen.stereo;
% 
% 
%     if ~isEnding
%         %MGL needs direct draw to screen
%         if stereo == 0
%                 if showFill
%                     mglFillRect(position(1), position(2), siz, color)
%                 end
%                 %No MGL function to show border
%         else
%             for n_eye = nn_eyes
%                 this = element_setEye(this, n_eye);
%                 
%                 if showFill
%                     mglFillRect(position(1), position(2), siz, color)
%                 end
%             end
%         end        
%     end    
    
    
end