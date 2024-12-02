fileName = this.fileName;
numberFile = this.numberFile;
minNumDigitsInFileName = this.minNumDigitsInFileName;
text = this.text;
n_boxTexture = this.n_boxTexture;
n_texture = this.n_texture;


%Close textures using PTB Close
Screen('Close', n_boxTexture)
Screen('Close', n_texture)


if this.ran && ~isempty(fileName)
    %Object ran and saving to text file...
    
    
            n_file = [];
    if numberFile
        %Auto number file name starting at 1, incrementing to not overwrite existing files.
        %Apply minNumDigitsInFileName.
        [p, fileNameBase, e] = fileparts(fileName);
            n_file = 1;
            pf = fullfile(p, [fileNameBase sprintf(['%0' num2str(minNumDigitsInFileName) '.0f'], n_file) e]);
            x = whereFile(pf);
        while ~isempty(x)
            n_file = n_file+1;
            pf = fullfile(p, [fileNameBase sprintf(['%0' num2str(minNumDigitsInFileName) '.0f'], n_file) e]);
            x = whereFile(pf);
        end
        fileName = pf;
    end
    
    %Recorded file name = file name without path
    [~, f, e] = fileparts(fileName);
    fileName_r = [f e];
    fileName_r = string(fileName_r);
    
    
    %Write text to file
    %---
    %Concatenated into one string except carriage returns inserted by enter stay -> line breaks
    response = [text{:}];
    response = strrep(response, char(13), char(10));
    if exist(fileName, 'file')
        %If appending to file that already exists separate from previous text with new line
        response = [10 response];
    end
    
    try
        %'a' starts new file or appends to existing.
        %'t' inserts 13's with 10's if on Windows.
        n = fopen(fileName, 'at');
            if n == -1
                error('Cannot open file.')
            end
        fwrite(n, response);
        fclose(n);
    catch X
            error(['Error from MATLAB writing text file.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
    %---
else
    fileName_r = [];
    n_file = [];    
end


this.fileName_r = fileName_r;
this.n_file = n_file;