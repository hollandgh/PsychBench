n_masterStream = devices.microphone.n_masterStream;


%Open sound stream using PTB PsychPortAudio('OpenSlave')
n_stream = PsychPortAudio('OpenSlave', n_masterStream);

%Make sound input buffer = 10 sec
%[audiodata absrecposition overflow cstarttime] = PsychPortAudio('GetAudioData', pahandle [, amountToAllocateSecs][, minimumAmountToReturnSecs][, maximumAmountToReturnSecs][, singleType=0]);
PsychPortAudio('GetAudioData', n_stream, 10);


this.n_stream = n_stream;