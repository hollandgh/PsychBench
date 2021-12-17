startTimeInMovie = this.startTimeInMovie;
speed = this.speed;
volume = this.volume;
imageInterval_file = this.imageInterval_file;
height = this.height;
n_movie = this.n_movie;
n_texture = this.n_texture;
n_nextTexture = this.n_nextTexture;
nextTextureStartTime = this.nextTextureStartTime;
lastTextureEndTime = this.lastTextureEndTime;
startTime = this.startTime;
n_window = this.n_window;
isStarting = this.isStarting;
isEnding = this.isEnding;
%start time of next frame (frame being prepared)
nextFrameTime = trial.nextFrameTime;


if      isStarting
    %OBJECT FRAME 0
    %Object starting at frame end / frame 1 start (this.startTime)
    %===

    if volume == 0
        %SYNC START METHOD (NO AUDIO)
        %Manual timing.
        %Movie textures available ahead of time in GetMovieImage buffer, not dependent on real-time, never skipped.
        %Sync movie time course start = display and object start time (this.startTime, = screen refresh at object frame 1 start).
        %---
            %Get texture 1
            [n_texture, textureStartTimeInMovie] = Screen('GetMovieImage', n_window, n_movie);
            textureStartTime = (textureStartTimeInMovie-startTimeInMovie)/speed+startTime;

            %Get texture 2
            [n_nextTexture, nextTextureStartTimeInMovie] = Screen('GetMovieImage', n_window, n_movie);
        if n_nextTexture > 0
            nextTextureStartTime = (nextTextureStartTimeInMovie-startTimeInMovie)/speed+startTime;
        else
            %Only one texture in movie -> show texture 1 for its interval
            lastTextureEndTime = textureStartTime+imageInterval_file/speed;
        end    
        %---
    else
        %AUDIO METHOD
        %Auto timing.
        %Each texture returned from GetMovieImage when due to show, skipped if too late and next one due.
        %First GetMovieImage call starts movie time course and audio, approx immediately but precise start time unknown.
        %---
            %Get texture 1.
            %Wait instead of poll like in runFrame cause need it to show.
            n_texture = Screen('GetMovieImage', n_window, n_movie);
        %---
    end

    %Draw current image to screen to show in next frame.
    %Scale to specified height.
    %Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
    %element_draw automatically applies all core display functionality.
    this = element_draw(this, n_texture, height);


elseif	isEnding
    %LAST OBJECT FRAME
    %Object running but will end at frame end based on cue set by user
    %===
    
    %Stop movie time course play, incl audio
    Screen('PlayMovie', n_movie, 0);

    
else
    %OBJECT FRAMES 1+ EXCEPT LAST FRAME ABOVE
    %Object running
    %===

    if isempty(lastTextureEndTime)
        if volume == 0
            %SYNC START METHOD (NO AUDIO)
            %---
            while nextFrameTime > nextTextureStartTime
                    %Due to show next texture -> close current texture using PTB Close and switch.
                    %while cause could miss show of next movie texture (e.g. dropped frames) and need to skip.
                    Screen('Close', n_texture)
                    n_texture = n_nextTexture;
                    textureStartTime = nextTextureStartTime;                    

                    %Get next texture
                    [n_nextTexture, nextTextureStartTimeInMovie] = Screen('GetMovieImage', n_window, n_movie);
                if n_nextTexture > 0
                    nextTextureStartTime = (nextTextureStartTimeInMovie-startTimeInMovie)/speed+startTime;
                else
                    %No textures left after current one -> show current one for its interval
                    lastTextureEndTime = textureStartTime+imageInterval_file/speed;
                    if nextFrameTime > lastTextureEndTime
                        %Past end time of last texture -> END OBJECT ON ITS OWN.
                        %Movie time course ended so don't need PlayMovie 0 call.
                        this = element_end(this);
                        return
                    else
                        break
                    end
                end
            %else 
                    %Not due to show next texture -> continue showing current one
            end
            %---
        else
            %AUDIO METHOD
            %---        
                    %Poll for new texture, don't wait cause would pause whole trial
                    n_nextTexture = Screen('GetMovieImage', n_window, n_movie, 0);
            if n_nextTexture > 0
                    %New texture available -> close current texture using PTB Close and switch
                    Screen('Close', n_texture)
                    n_texture = n_nextTexture;
            elseif n_nextTexture == -1
                    %No textures left -> continue showing current one for its interval.
                    %Assume it started showing at start of this frame.
                    lastTextureEndTime = trial.frameStartTimes(2)+imageInterval_file/speed;
                    if nextFrameTime > lastTextureEndTime
                        %Past end time of last texture -> END OBJECT ON ITS OWN.
                        %Movie time course ended so don't need PlayMovie 0 call.
                        this = element_end(this);
                        return
                    end                        
            %else n_nextTexture == 0
                    %New texture not available -> continue showing current one
            end
                    n_nextTexture = [];
            %---
        end
    elseif nextFrameTime > lastTextureEndTime
        %Due to end showing last texture -> END OBJECT ON ITS OWN.
        %Movie time course ended so don't need PlayMovie 0 call.
        this = element_end(this);
        return
    end

    %Draw current image to screen to show in next frame.
    %Scale to specified height.
    %Don't draw in last object frame cause then there is no next frame.
    %element_draw automatically applies all core display functionality.
    this = element_draw(this, n_texture, height);
        
        
end


this.n_texture = n_texture;
this.n_nextTexture = n_nextTexture;
this.nextTextureStartTime = nextTextureStartTime;
this.lastTextureEndTime = lastTextureEndTime;