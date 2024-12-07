fileName = this.fileName;
numberFile = this.numberFile;
minNumDigitsInFileName = this.minNumDigitsInFileName;
saveImage = this.saveImage;
saveImages = this.saveImages;
saveMovie = this.saveMovie;
nn_midTextures = this.nn_midTextures;
nn_textures = this.nn_textures;
n_movie = this.n_movie;
fileName_r = this.fileName_r;
n_file_r = this.n_file;


if saveMovie && ~isempty(n_movie)
    %Captured movie...
    
    Screen('FinalizeMovie', n_movie);
    
    %Exists error check, file name and numbering done at CreateMovie in runFrame
    
    
elseif saveImage && ~isempty(nn_textures)
    %Captured an image...
            
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
                    error([fileName ' already exists.'])
                end
    end

    %Write texture to image files.
    %Slow so do this in close.
    data = Screen('GetImage', nn_textures(1));
    try
        imwrite(data, fileName)
    catch X
            error(['Error from MATLAB writing image file.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end

    %Recorded file name = file name without path
    [~, f, e] = fileparts(fileName);
    fileName_r = [f e];
    fileName_r = string(fileName_r);
    n_file_r = n_file;
    
    
elseif saveImages && ~isempty(nn_textures)
    %Captured images...
    
    [p0, fileNameBase, e] = fileparts(fileName);
            
    if numberFile
        %Auto number folder name starting at 1, incrementing to not overwrite existing folders.
        %Apply minNumDigitsInFileName(1).
            n_folder = 1;
            p = fullfile(p0, [fileNameBase sprintf(['%0' num2str(minNumDigitsInFileName(1)) '.0f'], n_folder)]);
            [~, x] = whereFile(p);
        while ~isempty(x)
            n_folder = n_folder+1;
            p = fullfile(p0, [fileNameBase sprintf(['%0' num2str(minNumDigitsInFileName(1)) '.0f'], n_folder)]);
            [~, x] = whereFile(p);
        end
    else
            n_folder = [];
            p = fullfile(p0, fileNameBase);
            
                [~, x] = whereFile(p);
                if ~isempty(x)
                    if any(p == filesep)
                        error(['Folder ' p ' already exists.'])
                    else
                        error(['Folder "' p '" already exists.'])
                    end
                end
    end
    
    %Make folder
    try
        [tf, XMsg] = mkdir(p); if ~tf, error(XMsg), end
    catch X
            error(['Cannot make folder ' p '.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
            
        n_file = 0;
    for n_texture = nn_textures
        %Auto number file name starting at 1, incrementing.
        %Apply minNumDigitsInFileName(2).
        %Always number and overwrite for files in folder.
        n_file = n_file+1;
        pf = fullfile(p, [fileNameBase sprintf(['%0' num2str(minNumDigitsInFileName(2)) '.0f'], n_file) e]);

        %Write texture to image file.
        %Slow so do this in close.
        data = Screen('GetImage', n_texture);
        try
            imwrite(data, pf)
        catch X
                error(['Error from MATLAB writing image file.' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
        end
    end

    %Recorded file name = folder name without path
    [~, fileName_r] = fileparts(p);
    fileName_r = string(fileName_r);
    n_file_r = n_folder;
    
    
end


%Close textures
if ~isempty(nn_midTextures)
    Screen('Close', nn_midTextures)
end
if ~isempty(nn_textures)
    Screen('Close', nn_textures)
end

    
this.fileName_r = fileName_r;
this.n_file = n_file_r;