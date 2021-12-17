if WITHPTB
    %Close texture using PTB Close
    Screen('Close', this.n_texture)
    
    
else %WITHMGL
    %MGLTODOTENT
%     mglDeleteTexture(this.n_texture)
    
    
end