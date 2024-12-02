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
            nn_midTextures(1) = element_openTexture(siz);
        if saveMovie
            nn_midTextures(2) = element_openTexture(outputSize);
        end
    end
else
            nn_midTextures = [];
end


this.nn_midTextures = nn_midTextures;