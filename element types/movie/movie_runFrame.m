crop = this.crop;
height = this.height;
times = this.times;
speed = this.speed;
repeat = this.repeat;
n_movie = this.n_movie;
imageInterval_file = this.imageInterval_file;
n_texture = this.n_texture;
lastTextureEndTime = this.lastTextureEndTime;
n_window = this.n_window;
isStarting = this.isStarting;
isEnding = this.isEnding;
%mid time of next frame (frame being prepared)
nextFrameTime = trial.nextFrameTime;


if      isStarting
    %OBJECT FRAME 0
    %Object starting at next frame start (frame 1 start)
    %===

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


elseif	~isEnding
    %OBJECT RUNNING EXCEPT LAST FRAME
    %===

    if isempty(lastTextureEndTime)
                %Each texture output by GetMovieImage when due to show based on movie time course / audio, skipped if too late and some later one due.
                %Poll for new texture, don't wait cause would pause whole trial.
                [n_nextTexture, nextTextureTime] = Screen('GetMovieImage', n_window, n_movie, 0);
        if n_nextTexture > 0
            if repeat == 0 && (speed > 0 && nextTextureTime >= times(2) || speed < 0 && nextTextureTime <= times(1))
                %No repeat and at end time set in .times -> continue showing current image for its interval.
                %Assume it started showing at start of this frame.
                lastTextureEndTime = trial.frameStartTimes(3)+imageInterval_file/speed;
                if nextFrameTime >= lastTextureEndTime
                    %Past set end of last frame -> END OBJECT ON ITS OWN
                    
                    %Movie still playing so call PlayMovie 0
                    Screen('PlayMovie', n_movie, 0);
                    
                    this = element_end(this);
                    return
                end
            else
                %New texture available -> close current texture using PTB Close and switch
                Screen('Close', n_texture)
                n_texture = n_nextTexture;
            end
        elseif n_nextTexture == -1
                %No textures left -> continue showing current one for its interval
                lastTextureEndTime = trial.frameStartTimes(3)+imageInterval_file/speed;
                if nextFrameTime >= lastTextureEndTime
                    %Movie file end so don't need PlayMovie 0 call
                    
                    this = element_end(this);
                    return
                end
        %else n_nextTexture == 0
            %New texture not available -> continue showing current texture
        end
    elseif nextFrameTime >= lastTextureEndTime
                    %Movie maybe still playing if ending at end time set in .times, so call PlayMovie 0 in case
                    Screen('PlayMovie', n_movie, 0);
                    
                    this = element_end(this);
                    return
    end

    %Draw current image to window to show in next frame.
    %Don't draw in last object frame cause then there is no next frame.
    this = element_draw(this, n_texture, crop, height);
        
    
else
    %LAST OBJECT FRAME
    %Object running but will end at frame end at cue set by user
    %===
    
                    %Movie still playing so call PlayMovie 0
                    Screen('PlayMovie', n_movie, 0);

    
end


this.n_texture = n_texture;
this.lastTextureEndTime = lastTextureEndTime;