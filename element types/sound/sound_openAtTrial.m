volume = this.volume;
data = this.data;
n_masterStream = devices.speaker.n_masterStream;


%Open sound stream using PTB PsychPortAudio('OpenSlave').
%In openAtTrial instead of open cause Psychtoolbox holding sound streams open
%could use significant resources, so only hold for each object during its trial
%instead of for all objects at same time at experiment startup.
n_stream = PsychPortAudio('OpenSlave', n_masterStream);

%Fill stream buffer with sound data
PsychPortAudio('FillBuffer', n_stream, data);

%Scale volume
PsychPortAudio('Volume', n_stream, volume);


this.n_stream = n_stream;