n_movie = this.n_movie;
loopMode = this.loopMode;
speed = this.speed;
volume = this.volume;


%PTB PlayMovie starts movie buffering in memory.
%Movie starts playing later at first GetMovieImage call in runFrame.
Screen('PlayMovie', n_movie, speed, loopMode, volume);