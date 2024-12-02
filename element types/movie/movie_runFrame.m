crop = this.crop;
height = this.height;
times = this.times;
n_movie = this.n_movie;
imageInterval_file = this.imageInterval_file;
endAtDuration = this.endAtDuration;
n_texture = this.n_texture;
lastTextureEndTime = this.lastTextureEndTime;
n_window = this.n_window;
isStarting = this.isStarting;
isEnding = this.isEnding;
startTime = this.startTime;
%mid time of next frame (frame being prepared)
nextFrameTime = trial.nextFrameTime;


if      isStarting
    %OBJECT FRAME 0
    %Object starting at next frame start (frame 1 start)

    %Get texture 1.
    %Wait instead of poll cause need it to show.
    %First GetMovieImage call starts movie time course / audio with some unspecified latency, not precisely synced to screen refresh when first image starts.
    n_texture = Screen('GetMovieImage', n_window, n_movie);

    %Draw current image to window to show in next frame.
    %Dynamic display so use element_draw instead of element_redraw.
    %Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
    %element_draw automatically applies all core display functionality.
    %Also apply crop, height here.
    this = element_draw(this, n_texture, crop, height);

elseif	~isempty(lastTextureEndTime)
    %Showing last image in movie file
    
    if nextFrameTime > lastTextureEndTime
        %Past last image end time -> END OBJECT ON ITS OWN

        %Movie file end so don't need PlayMovie 0 call

        this = element_end(this);
    else
        this = element_draw(this, n_texture, crop, height);
    end
    
elseif	~isEnding
    %OBJECT RUNNING EXCEPT LAST FRAME
    
    if nextFrameTime-startTime > endAtDuration
        %Past time range or maximum number of loops -> END OBJECT ON ITS OWN

        %Movie still playing so call PlayMovie 0
        Screen('PlayMovie', n_movie, 0);

        this = element_end(this);
        
    else
        %Each texture output by GetMovieImage when due to show based on movie time course / audio, skipped if too late and some later one due.
        %Poll for new texture, don't wait cause would pause whole trial.
        [n_nextTexture, nextTextureTime_movie] = Screen('GetMovieImage', n_window, n_movie, 0);
        if n_nextTexture == -1
            %No more images in file

            %Compensate for PTB GetMovieImage bug that returns n_nextTexture = -1 immediately, not when current image should end.
            %Assume current (last) image started at start of this frame = trial.frameTimes(3).
            lastTextureEndTime = trial.frameTimes(3)+imageInterval_file;
            
            if nextFrameTime > lastTextureEndTime
                %Already past last image end time -> END OBJECT ON ITS OWN

                %Movie file end so don't need PlayMovie 0 call

                this = element_end(this);
            else
                this = element_draw(this, n_texture, crop, height);
            end

        else
            if n_nextTexture > 0
                %New texture available...
                
                if ~isempty(times)
                    if nextTextureTime_movie > times(2) || nextTextureTime_movie < times(1)
                        %Went later than max time or (if max time = movie file end) looped to movie file start and now earlier than min time
                        %-> manually loop to min time.
                        %This code is for speed > 0 but currently this is checked limited to speed = 1 so okay.
                        %Wait instead of poll cause need it to show.
                        Screen('SetMovieTimeIndex', n_movie, times(1));
                        Screen('Close', n_nextTexture)
                        n_nextTexture = Screen('GetMovieImage', n_window, n_movie);
                    end
                end
                    
                %Close current texture using PTB Close and switch
                Screen('Close', n_texture)
                n_texture = n_nextTexture;

            %else new texture not available yet -> continue showing current texture
            end
            
            this = element_draw(this, n_texture, crop, height);
            
        end
        
    end
    
else
    %LAST OBJECT FRAME
    %Object running but will end at frame end at cue set by user
    
    %Movie still playing so call PlayMovie 0
    Screen('PlayMovie', n_movie, 0);

    %Don't draw in last object frame cause then there is no next frame.
    
end


this.n_texture = n_texture;
this.lastTextureEndTime = lastTextureEndTime;