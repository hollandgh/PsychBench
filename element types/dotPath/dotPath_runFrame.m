fps = this.fps;
speed = this.speed;
phase = this.phase;
repeat = this.repeat;
dotSize = this.dotSize;
color = this.color;
data = this.data;
numImages = this.numImages;
numImagesWithBreak = this.numImagesWithBreak;
n_texture = this.n_texture;
startTime = this.startTime;
isEnding = this.isEnding;
%mid time of next frame (frame being prepared)
nextFrameTime = trial.nextFrameTime;


if ~isEnding
    %Update display for next frame...
    %Don't draw in last frame.


    %Time relative to object start (object frame 1 start)
    t = nextFrameTime-startTime;
    
    %Get image [x; y] that will show for next frame.
    %Apply speed, phase here.
    %phase in images.
            %floor + 1 cause mid of frame with t = 0 -> image 1
            n_image = floor(speed*fps*t+phase)+1;
    if n_image > numImages
        if repeat
            %Wrap image number
            n_image = mod(n_image-1, numImagesWithBreak)+1;
            if n_image > numImages
                %In inter-repeat interval -> don't draw display next frame
                return
            end
        else
            %End of images and not set to repeat -> END OBJECT ON ITS OWN
                this = element_end(this);
                return
        end
    end
    d = data(:,n_image);
    
    %Draw display to show in next frame centered on texture using PTB DrawDots.
    %Circular dots.
    Screen('DrawDots', n_texture, d, dotSize, color, [], 1);
    %Draw texture to window.
    %Dynamic display so use element_draw instead of element_redraw.
    %Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
    %Don't draw in last object frame cause then there is no next frame.
    %Tell element_draw to blank the texture so ready for next draw in next runFrame iteration.
    %element_draw automatically applies all core display functionality.
    this = element_draw(this, n_texture, [], [], [], '-reset');
end