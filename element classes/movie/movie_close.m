%Close movie
Screen('CloseMovie', this.n_movie)

%Close textures if any using PTB Close
if ~isempty(this.n_texture)
    Screen('Close', this.n_texture)
end
if ~isempty(this.n_nextTexture)
    Screen('Close', this.n_nextTexture)
end