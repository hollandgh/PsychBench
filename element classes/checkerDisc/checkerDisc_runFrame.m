position = this.position;
nn_eyes = this.nn_eyes;
rotate = this.rotate;
n_texture = this.n_texture;
isEnding = this.isEnding;
stereo = resources.screen.stereo;


if WITHPTB
    %Draw display to screen to show in next frame.
    %Static display so use element_redraw instead of element_draw for efficiency.
    %Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
    %Don't draw in last object frame cause then there is no next frame.
    %element_redraw automatically applies all core display functionality.
    if ~isEnding
        this = element_redraw(this, n_texture);
    end
    
    
else %WITHMGL
    %MGLTODOTENT
%     if ~isEnding
%         %MGL needs direct draw to screen
%         if stereo == 0
%                 mglMetalBltTexture(n_texture, position, 0, 0, rotate)
%         else
%             for n_eye = nn_eyes
%                 this = element_setEye(this, n_eye);
%                 mglMetalBltTexture(n_texture, position, 0, 0, rotate)
%             end
%         end
%     end
    
    
end