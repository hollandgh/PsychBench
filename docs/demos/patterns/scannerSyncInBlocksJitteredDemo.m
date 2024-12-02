% SCANNER (SYNC IN EACH BLOCK, JITTERED STIMULUS INTERVAL) DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Same as scannerSyncInBlocksDemo.m except here we randomly jitter stimulus
% interval (start to start) across 5, 6, 7, 8 sec evenly sampled within blocks
% of 12 stimuli, with total interval from the block's sync to the start of the
% last stimulus in the block = 73.75 sec. We run two blocks and sync with the
% scanner before each one.



% See scannerSyncInBlocksDemo.m for more commenting.



% Mark start of experiment script
newExperiment


% Define trial containing keyPress object to register trigger and sync experiment
% -
    syncer = keyPressObject;
    syncer.n_device = [];
    syncer.registerTrigger = true;
    syncer.syncExperiment = true;
    syncer.start.t = 0;
    syncer.report = "syncTime";

    
    addTrial(syncer, "sync");
% -


fileNames = ["red cone.png" "green cylinder.png" "blue cube.png"];

% 2 blocks of task trials.
% Each trial that runs in the experiment needs its own trial definition since
% each has a different combination of picture file + value in trial object
% property .start (-> stimulus interval).
for n_block = 1:2
    % 12 stimulus interval offsets randomly evenly sampled from 0, 1, 2, 3 sec.
    % Random order here randomizes which offsets go with which picture trials.
    isiOffsets = randomOrder(rep([0 1 2 3], 3));
    
    % 12 trial definitions in the block: 3 pictures x 4 repetitions
            n_trialInBlock = 0;
    for n_rep = 1:4
        for f = 1:3
            n_trialInBlock = n_trialInBlock+1;


            % Picture stimulus
            pic = pictureObject;
            pic.fileName = fileNames(f);
            pic.height = 10;
            pic.start.t = 0;
            pic.end.response = true;
            pic.report = ["fileName" "startTime"];


            % Response handler - any key press from subject
            recorder = keyPressObject;
            recorder.start.t = 0;
            recorder.report = "responseTime";


            % Set trial to start at fixed time relative to sync in a past trial using trial object property .start field .t_sync.
            % Baseline 0.75 sec from sync if this is the first trial to run after it, 5 sec increments for subsequent trials.
            % Then + random offset.
            % So last trial in block always starts 0.75 + 11*5 + 3*0 + 3*1 + 3*2 + 3*3 = 73.75 sec from the block's sync.
            trial = trialObject;
            trial.start.t_sync = [0.75 5]+isiOffsets(n_trialInBlock);


            % Add trial definition with default numbering (1, 2, 3, ...)
            addTrial(pic, recorder, trial);
        end
    end
end


% Set trial list: sync, block, sync, block.
% Random order here randomizes order of picture trials.
nn = {"sync" randomOrder(1:12) "sync" randomOrder(13:24)};
setTrialList(nn)


% Run
[results, resultsMatrix] = runExperiment;