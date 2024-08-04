siz = this.size;
saveMovie = this.saveMovie;
outputSize = this.outputSize;
i_element = this.i_element;
n_window = this.n_window;


if isempty(i_element)
    if outputSize(1) == siz(1)
            nn_midTextures = [];
    else
        %Output size ~= size on screen -> will need intermediate texture(s)
        %In openAtTrial instead of open cause textures Psychtoolbox holds can use
        %significant memory, so only hold for each object during its trial instead of
        %for all objects at same time at experiment startup.
            nn_midTextures(1) = Screen('OpenOffscreenWindow', n_window, [], [0 0 siz]);
        if saveMovie
            nn_midTextures(2) = Screen('OpenOffscreenWindow', n_window, [], [0 0 outputSize]);
        end
    end
else
            nn_midTextures = [];
end


this.nn_midTextures = nn_midTextures;