data = this.data;
n_window = this.n_window;    
    
    
if WITHPTB
    %Convert image data to texture using PTB MakeTexture.
    %In openAtTrial instead of open cause textures Psychtoolbox holds can use
    %significant memory, so only hold for each object during its trial instead of
    %for all objects at same time at experiment startup.
    n_texture  = Screen('MakeTexture', n_window, data);
    
    
else %WITHMGL
    %MGLTODOTENT
%     n_texture = mglMetalCreateTexture(data);
    
    
end


this.n_texture = n_texture;