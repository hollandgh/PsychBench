n_movie = this.n_movie;
n_texture = this.n_texture;


%Close movie
Screen('CloseMovie', n_movie)

%Close textures using PTB Close if open
if ~isempty(n_texture)
    Screen('Close', n_texture)
end