frameRate = this.frameRate;
saveImage = this.saveImage;
saveMovie = this.saveMovie;
rect = this.rect;
outputSize = this.outputSize;
nn_midTextures = this.nn_midTextures;
i_element = this.i_element;
captureStartTime = this.captureStartTime;
numImagesCaptured = this.numImagesCaptured;
nn_textures = this.nn_textures;
n_movie = this.n_movie;
n_window = this.n_window;
isEnding = this.isEnding;
nextFrameTime = trial.nextFrameTime;


%Runs after all other objects and captures from draw buffer, so each frame
%captures what other objects have drawn to buffer to show on screen next frame.
%-> Capture starting in frame 0 (what other objects will show in frame 1) and
%ending in frame end-1 (since other objects with same end cue would not show
%anything in frame end+1, i.e. not draw anything in frame end).
if ~isEnding
    if ~isempty(i_element)
        %Target = element...
        
        element = element_getElement(i_element);
        
        if element.isRunning
            if isempty(rect)
                if ~isempty(element.displayRect)
                    %First frame target element running and showing a display during screenRecorder run 
                    %-> get rect and maybe size based on target element, start capture below
                    %---

                    siz = this.size;
                    outputWidth = this.outputWidth;
                    outputWidthSnap = this.outputWidthSnap;
                    windowSize = devices.screen.windowSize;


                    if numel(siz) == 1 && siz == inf
                        %Rect = target element display rect
                        rect = round(element.displayRect);
                            if any(rect(1:2) >= windowSize) || any(rect(3:4) <= 0)
                                error('In target element size and position: Whole capture area is outside the experiment window.')
                            end
                    else
                        %Rect size set in size, centered on target element display (usually but not always = target element .position).
                        %Separate round to always maintain size ratio.
                        rect = round([0 0 siz])+round(repmat(-(siz+1)/2+(element.displayRect(1:2)+element.displayRect(3:4))/2, 1, 2));
                            if any(rect(1:2) >= windowSize) || any(rect(3:4) <= 0)
                                error('In property .size and target element position: Whole capture area is outside the experiment window.')
                            end
                    end
                        %Clip to window edges
                        rect = [max(rect(1:2), [0 0]) min(rect(3:4), windowSize)];
                        siz = rect(3:4)-rect(1:2);
                        
                    if isempty(outputWidth)
                        %Size of output images (px) = size of input
                                outputSize = siz;
                        if saveMovie && outputWidthSnap > 1
                            %Movie -> snap size of output images to integer multiple of outputWidthSnap
                            r = mod(outputSize(1), outputWidthSnap);
                            if r > 0
                                    s = round((outputSize(1)-r)/outputSize(1)*outputSize);
                                if r > outputWidthSnap/2 || any(s <= 0)
                                    s = round((outputSize(1)+outputWidthSnap-r)/outputSize(1)*outputSize);
                                end
                                outputSize = s;
                            end
                        end
                    else
                        %Specified size of output images (px).
                        %If movie checked integer multiple of outputWidthSnap earlier.
                                outputSize = max(round(outputWidth/siz(1)*siz), 1);
                    end
                    if outputSize(1) == siz(1)
                            nn_midTextures = [];
                    else
                        %Output size ~= size on screen -> will need intermediate texture(s)
                            nn_midTextures(1) = element_openTexture(siz);
                        if saveMovie
                            nn_midTextures(2) = element_openTexture(outputSize);
                        end
                    end


                    this.size = siz;
                    this.rect = rect;
                    this.outputSize = outputSize;
                    this.nn_midTextures = nn_midTextures;
                    %---
                else
                    %Target element running but not showing display yet
                    return
                end
            %else continue capture
            end
        else
            if element.ran
                %Target element ended, will not have drawn anything to show next frame
                %-> END SCREENRECORDER ON ITS OWN and don't capture this frame

                this = element_end(this);
            %else target element not started yet
            end
            
            return
        end
    %else no target element -> just capture
    end
    
    
    %Capture...
    
    if isempty(captureStartTime)
        captureStartTime = nextFrameTime;
    end
    t = nextFrameTime-captureStartTime;
    %Image number we should be captured up to this frame.
    %floor + 1 cause t = 0 -> image 1
    n_image = 1+floor(t*frameRate);
    numImagesCapture = n_image-numImagesCaptured;

    if numImagesCapture > 0
        %Due to capture this frame based on frame rate

        if saveMovie
            %Movie...

            if isempty(n_movie)
                %First frame of movie -> create movie using PTB CreateMovie.
                %Here instead of open cause if target = element don't know rect until element is running.
                %---

                fileName = this.fileName;
                numberFile = this.numberFile;
                minNumDigitsInFileName = this.minNumDigitsInFileName;
                movieOptions = this.movieOptions;


                %CreateMovie is where file writing starts so handle file name and numbering for movie here
                if numberFile
                    %Auto number file name starting at 1, incrementing to not overwrite existing files.
                    %Apply minNumDigitsInFileName.
                    [p, fileNameBase, e] = fileparts(fileName);
                        n_file = 1;
                        pf = fullfile(p, [fileNameBase sprintf(['%0' num2str(minNumDigitsInFileName(1)) '.0f'], n_file) e]);
                    while ~isempty(whereFile(pf))
                        n_file = n_file+1;
                        pf = fullfile(p, [fileNameBase sprintf(['%0' num2str(minNumDigitsInFileName(1)) '.0f'], n_file) e]);
                    end
                    fileName = pf;
                else
                        n_file = [];
                            if ~isempty(whereFile(fileName))
                                error([fileName ' already exists or is in use.'])
                            end
                end

                %Recorded file name = file name without path
                [~, f, e] = fileparts(fileName);
                fileName_r = [f e];
                fileName_r = string(fileName_r);

                n_movie = Screen('CreateMovie', n_window, fileName, outputSize(1), outputSize(2), frameRate, movieOptions);


                this.fileName = fileName;
                this.n_movie = n_movie;
                this.fileName_r = fileName_r;
                this.n_file = n_file;
                %---
            end

            %Capture to movie using PTB AddFrameToMovie.
            %Buffer = draw buffer to match CopyWindow below (with imaging pipeline enabled).
            %Record as longer frame if start time of this frame was delayed.
            %numFrames input cannot be fractional.
            if isempty(nn_midTextures)
                Screen('AddFrameToMovie', n_window, rect, 'drawBuffer', n_movie, numImagesCapture)
            else
                %Output size ~= size on screen ->
                %AddFrameToMove always adds rect = size of movie regardless of rect argument, so use intermediate texture to resize.
                %CopyWindow can only copy to same size, so use 2 intermediate textures.
                Screen('CopyWindow', n_window, nn_midTextures(1), rect)
                Screen('DrawTexture', nn_midTextures(2), nn_midTextures(1), [], [0 0 outputSize])
                Screen('AddFrameToMovie', nn_midTextures(2), [], [], n_movie, numImagesCapture)
            end
        else
            %Image(s)...

            %Capture to texture using PTB CopyWindow.
            %Replicate by numFrames in case this image spans dropped frames at frameRate.
            n_texture = element_openTexture(outputSize);
            if isempty(nn_midTextures)
                Screen('CopyWindow', n_window, n_texture, rect)
            else
                %Output size ~= size on screen ->
                %CopyWindow can only copy to same size, so use intermediate texture to resize.
                Screen('CopyWindow', n_window, nn_midTextures(1), rect)
                Screen('DrawTexture', n_texture, nn_midTextures(1), [], [0 0 outputSize])
            end
            nn_textures = [nn_textures repmat(n_texture, 1, numImagesCapture)];

            if saveImage
                %Capture one image only -> END SCREENRECORDER ON ITS OWN.
                %-1 flag = end at end of next frame, just to match end time of image captured (won't capture next frame too cause of ~isEnding check above).
                this = element_end(this, '-1');
            end
        end

        numImagesCaptured = n_image;
    end
end


this.captureStartTime = captureStartTime;
this.numImagesCaptured = numImagesCaptured;
this.nn_textures = nn_textures;