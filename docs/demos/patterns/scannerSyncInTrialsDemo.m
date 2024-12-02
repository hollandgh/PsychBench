% SCANNER (SYNC IN EACH TRIAL) DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Each trial shows one of three pictures and the subject responds with any key
% press. Picture onset is 0.75 sec after sync trigger from a scanner in each
% trial. The picture shows until the subject responds or for 2 sec, whichever
% occurs first. We run 4 repetitions of each of the 3 picture trials for a total
% of 12 trials, all in random order.
%
% This scanner demo syncs in each trial and element timing is relative to sync.
% See also scannerSyncInBlocksDemo.m.



% Mark start of experiment script
newExperiment


% 3 trial definitions: 3 pictures
fileNames = ["red cone.png" "green cylinder.png" "blue cube.png"];
for f = 1:3
    % Simulate trigger by key press for this tutorial.
    % Many scanners send triggers as key presses, in which case would use a keyPress object in a real experiment too.
    % By default listens for any key (could be changed in property .listenKeyNames).
    syncer = keyPressObject;
    % Listen for key press from default keyboard just for this demo.
    % In a real experiment would need to set this to point to whatever device the trigger is coming from.
    syncer.n_device = [];
    % Register input as a trigger instead of response from subject
    syncer.registerTrigger = true;
    % Sync experiment at trigger so can set elements to start/end at times from sync
    syncer.syncExperiment = true;
    % Start at trial start
    syncer.start.t = 0;
    % By default keyPress elements end when they record a trigger/response -> don't need to set .end.
    % Report sync time ( = trigger time).
    syncer.report = "syncTime";
    
    
    % Picture stimulus.
    % Start at time from sync = 0.75 sec.
    % End at response or time from sync = 2.75 sec (2 sec duration), whichever occurs first.
    pic = pictureObject;
    pic.fileName = fileNames(f);
    pic.height = 10;
    pic.start.t_sync = 0.75;
    pic.end(1).response = true;
    pic.end(2).t_sync = 2.75;
    pic.report = ["fileName" "startTime"];


    % Response handler - any key press, this time for response from subject.
    % Start at time from sync = 0.75 sec.
    % By default ends on its own at response.
    % Also end at time from sync = 2.75 sec if that occurs first.
    recorder = keyPressObject;
    recorder.start.t_sync = 0.75;
    recorder.end.t_sync = 2.75;
    recorder.report = "responseTime";
    
    
    % Note make sure each trial starts soon enough to allow it to receive its trigger.
    % e.g. here minimum time between triggers = 0.75 + 2 + pre-trial interval sec.
    % Default pre-trial interval = 0.75 sec, or can change in trial object property .preTrialInterval.
    
    
    % Add trial definition with default numbering (1, 2, 3, ...)
    addTrial(syncer, pic, recorder);
end


% Trial list: run 4 of each trial definition in random order
nn = randomOrder(rep(1:3, 4));
setTrialList(nn)


% Run
[results, resultsMatrix] = runExperiment;


% See also:
% - element types cedrusPress, responsepixxPress, etc. for button boxes
% - pb_prefs() -> screen tab -> flip horizontal/vertical (screen object 
%   properties .flipHorz/flipVert) for display through a mirror