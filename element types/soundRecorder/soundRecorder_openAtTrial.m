n_masterStream = devices.microphone.n_masterStream;


%Open sound stream using PTB PsychPortAudio('OpenSlave').
%In openAtTrial instead of open cause Psychtoolbox holding sound streams open
%could use significant resources, so only hold for each object during its trial
%instead of for all objects at same time at experiment startup.
n_stream = PsychPortAudio('OpenSlave', n_masterStream);

%Make sound input buffer = 10 sec
%[audiodata absrecposition overflow cstarttime] = PsychPortAudio('GetAudioData', pahandle [, amountToAllocateSecs][, minimumAmountToReturnSecs][, maximumAmountToReturnSecs][, singleType=0]);
PsychPortAudio('GetAudioData', n_stream, 10);


this.n_stream = n_stream;