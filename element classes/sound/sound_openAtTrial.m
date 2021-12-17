fileName = this.fileName;
volume = this.volume;
data = this.data;
n_portAudioDevice = this.n_portAudioDevice;


if WITHPTB
    %Open sound stream as virtual subdevice.
    %Allows any number of sound objects to play at same time, each using their own subdevice.
    %In openAtTrial instead of open cause Psychtoolbox holding sound streams open
    %could use significant resources, so only hold for each object during its trial
    %instead of for all objects at same time at experiment startup.
    n_stream = PsychPortAudio('OpenSlave', n_portAudioDevice);

    %Fill stream buffer with sound data
    PsychPortAudio('FillBuffer', n_stream, data);

    %Set volume
    PsychPortAudio('Volume', n_stream, volume);


else %WITHMGL
    %Open sound stream.
    %In openAtTrial instead of open cause MGL holding sounds open could use
    %significant memory, so only hold for each object during its trial instead of
    %for all objects at same time at experiment startup.
    %Checked MGL loading file is fast enough for openAtTrial.
    n_stream = mglInstallSound(fileName);


end


this.n_stream = n_stream;