saveMovie = this.saveMovie;
n_movie = this.n_movie;
fileName = this.fileName;


if saveMovie && ~isempty(n_movie)
    %Finalize and delete incomplete movie file.
    %try cause movie will already be closed if error occurred at AddFrameToMovie.
    
    try %#ok<TRYNC>
        Screen('FinalizeMovie', n_movie);
    end
    delete(fileName)
end