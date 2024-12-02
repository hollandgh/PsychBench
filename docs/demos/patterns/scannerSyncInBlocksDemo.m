% SCANNER (SYNC IN EACH BLOCK) DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Each trial shows one of three pictures and the subject responds with any key
% press. Trials start at fixed times from sync trigger from a scanner at the
% start of each block: 0.75 sec for the first trial after sync, and 5 sec
% increments for subsequent trials. In each trial the picture shows until the
% subject responds or until the pre-trial interval for the next trial needs to
% start, whichever occurs first. In each block we run 4 repetitions of each of
% the 3 picture trials for a total of 12 trials, all in random order. We run 2
% blocks and sync at the start of each one.
%
% This scanner demo syncs in each block of trials, trial timing is relative to
% sync, and element timing is relative to trial. See also scannerSyncInTrialsDemo.m.



% Mark start of experiment script
newExperiment


% Define trial containing keyPress object to register trigger and sync experiment
% -
    % Simulate trigger by key press for this tutorial.
    % Many scanners send triggers as key presses, in which case would use a keyPress object in a real experiment too.
    % By default listens for any key (could be changed in property .listenKeyNames).
    syncer = keyPressObject;
    % Listen for key press from default keyboard just for this demo.
    % In a real experiment would need to set this to point to whatever device the trigger is coming from.
    syncer.n_device = [];
    % Register input as a trigger instead of response from subject
    syncer.registerTrigger = true;
    % Sync experiment at trigger so can set subsequent trials to start at times from sync
    syncer.syncExperiment = true;
    % Start at trial start
    syncer.start.t = 0;
    % By default keyPress elements end when they record a trigger/response -> don't need to set .end.
    % Report sync time ( = trigger time).
    syncer.report = "syncTime";

    
    % Define trial with custom label "sync"
    addTrial(syncer, "sync");
% -


% 3 task trial definitions: 3 pictures
fileNames = ["red cone.png" "green cylinder.png" "blue cube.png"];
for f = 1:3
    % Picture stimulus.
    % Start at trial start.
    % End at response.
    pic = pictureObject;
    pic.fileName = fileNames(f);
    pic.height = 10;
    pic.start.t = 0;
    pic.end.response = true;
    pic.report = ["fileName" "startTime"];


    % Response handler - any key press, this time for response from subject.
    % Start at trial start.
    % By default ends on its own at response.
    recorder = keyPressObject;
    recorder.start.t = 0;
    recorder.report = "responseTime";

    
    % Set trial to start at fixed time relative to sync in a past trial using trial object property .start field .t_sync.
    % 0.75 sec from sync if this is the first trial after it, 5 sec increments for subsequent trials.
    % Refers to the order trials run in set in trial list below.
    % - Prevents timing drift which could occur with default flexible trial timing
    % - Will wait to start if previous trial ends early
    % - Will end previous trial if it would run late
    % - Will also end this trial similarly if it's the last one in a sequence with .start.t_sync set
    trial = trialObject;
    trial.start.t_sync = [0.75 5];
    
    % Note pre-trial interval still needs to run, so check not set so long that previous trial gets cut off early.
    % e.g. 0.75 sec maximum (first trial after sync), or 5 - 2 = 3 sec maximum (subsequent trials).
    % Default pre-trial interval = 0.75 sec, or can change in trial object property .preTrialInterval.
    
    
    % Add trial definition with default numbering (1, 2, 3, ...)
    addTrial(pic, recorder, trial);
end


% Set trial list:
%
% 1. sync with scanner
% 2. block of 4 x task trial definitions in random order
% 3. re-sync with scanner
% 4. block of 4 x task trial definitions in random order
nn = {"sync" randomOrder(rep(1:3, 4)) "sync" randomOrder(rep(1:3, 4))};
setTrialList(nn)


% Run
[results, resultsMatrix] = runExperiment;


% See also:
% - element types cedrusPress, responsepixxPress, etc. for button boxes
% - pb_prefs() -> screen tab -> flip horizontal/vertical (screen object 
%   properties .flipHorz/flipVert) for display through a mirror