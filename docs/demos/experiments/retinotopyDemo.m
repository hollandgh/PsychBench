% RETINOTOPY DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Each trial shows a retinotopic mapping stimulus for use in fMRI. Stimuli are
% based on a black & white dartboard pattern on a 50% gray background. The
% dartboard is positioned at screen center and spans 12.2 deg (6.1 deg
% eccentricity from center) with the middle 0.8 deg cut out and a white fixation
% dot placed at center. Each trial shows one of two types of stimuli: (1) an
% isolated wedge segment of the dartboard moving angularly in steps either
% clockwise or counterclockwise, and (2) an isolated "ring" segment of the
% dartboard moving radially in steps either outward from the center or inward
% toward the center. See property settings below for parameters. The stimulus
% starts 1 sec from sync trigger from scanner, received a short time after trial
% start, and runs for 2 loops of the stimulus (rotations around the dartboard or
% expansions/contractions through the dartboard). Here sync trigger is simulated
% as any key press from the default keyboard device. We run 2 repetitions of the
% sequence clockwise wedges, outward rings, counterclockwise wedges, inward
% rings.
%
% This scanner demo syncs in each trial and element timing is relative to sync.
% Syncing in blocks with trial timing relative to sync is also possible--see
% trial object property .start and scannerSyncInBlocksDemo.m.
%
% NOTE: In a real life you would want to modify this experiment to use more
% loops (longer stimuli) and more repetitions, in addition to listening for only
% the expected trigger signal from the specific scanner device.
%
% Similar to https://www.jneurosci.org/content/26/51/13128.
%
% http://www.scholarpedia.org/article/Visual_map



% Mark start of experiment script
newExperiment



% WEDGE TRIALS
% ==========
% 2 trial definitions numbered 1, 2 corresponding to clockwise, counterclockwise wedge steps
for direction = [1 -1]
    % Sync with scanner
    % ---
    % Use standard template for an object that registers a trigger to sync the experiment on an input that can be handled as a key press.
    % Gets a keyPress object with relevant properties pre-set, which you can tweak and/or add to if needed:
    % .registerTrigger  = true; 
    % .syncExperiment   = true; 
    % .start.t          = 0; 
    % .report           = "syncTime";
    syncer = getTemplate("keySyncer");
    
    % Listen for key press from default keyboard just for this demo
    syncer.n_device = [];
    % ---


    % Dartboard wedges
    % ---
    wedges = dartboardRetinotopyObject;

    % Basic dartboard parameters: 
    % size (deg), center cut-out size (deg), numbers of angular and radial checks
    wedges.diameter = 12.2;
    wedges.centerDiameter = 0.8;
    wedges.numAngularChecks = 48;
    wedges.numRadialChecks = 4.75;
    
    % Set alternating radial strips to move inward/outward at specific speed (radial cycles/sec), like an internally balanced phase shift.
    % Sign here effectively sets which strips go in which direction -> modulate by wedge direction +/-1 so clockwise/counterclockwise wedge stimuli are opposites.
    wedges.radialTemporalFrequencyBalanced = direction*5/6;
    
    % Show wedges
    wedges.showWedges = true;
    % Set wedge parameters, all based on units of angular checks in the dartboard: 
    % size (checks), movement increment (checks), movement time interval (sec).
    % Wedge movement direction +/-1 applied in movement increment.
    wedges.apertureSize = 6;
    wedges.apertureStep = direction*2;
    wedges.apertureInterval = 1;
    
    % Number of loops around the dartboard to show before object ends on its own
    wedges.maxNumLoops = 2;

    % Start 1 sec from experiment sync (done by syncer object above).
    % Don't need to set .end cause ends on its own based on .maxNumLoops above.
    wedges.start.t_sync = 1;
    
    % See start time, duration in experiment results output
    wedges.report = ["startTime" "duration"];
    % ---


    % Fixation dot
    % ---
    % Default dots object = 1 round white dot, diameter = 0.2 deg
    fixation = dotsObject;
    
    % Make sure it displays in front of the dartboard
    fixation.depth = -1;
    
    % Start at start of dartboard; End at end of dartboard
    fixation.start.startOf = "wedges";
    fixation.end.endOf = "wedges";
    % ---


    % Add trial definition with default numbering (1, 2, ...)
    addTrial(syncer, wedges, fixation);
end
% ==========



% RING TRIALS
% ==========
% 2 trial definitions numbered 3, 4 corresponding to outward, inward ring steps.
% Same as wedge trials except for wedge/ring parameters in the dartboardRetinotopy object.
for direction = [1 -1]
    % Sync with scanner
    % ---
    syncer = getTemplate("keySyncer");

    syncer.n_device = [];
    % ---


    % Dartboard wedges
    % ---
    rings = dartboardRetinotopyObject;

    rings.diameter = 12.2;
    rings.centerDiameter = 0.8;
    rings.numAngularChecks = 48;
    rings.numRadialChecks = 4.75;
    
    rings.radialTemporalFrequencyBalanced = direction*5/6;

    % Show rings
    rings.showRings = true;
    % Set wedge parameters, all based on units of angular checks in the dartboard: 
    % size (checks), movement increment (checks), movement time interval (sec).
    % Wedge movement direction +/-1 applied in movement increment.
    rings.apertureSize = 1;
    rings.apertureStep = direction*0.3125;
    rings.apertureInterval = 1;
    
    rings.maxNumLoops = 2;

    rings.start.t_sync = 1;
    
    rings.report = ["startTime" "duration"];
    % ---


    % Fixation dot
    % ---
    fixation = dotsObject;
    
    fixation.depth = -1;
    
    fixation.start.startOf = "rings";
    fixation.end.endOf = "rings";
    % ---


    % Add trial definition with default numbering (adds 3, 4 after 1, 2 defined above)
    addTrial(syncer, rings, fixation);
end
% ==========



% Make experiment object and set background color for the experiment to 50% gray.
% You can also just do this as a preference in pb_prefs(), but good to do it like this in case script runs on different computers.
experiment = experimentObject;
experiment.backColor = [0.5 0.5 0.5];

% Use addToExperiment() to add objects not specific to trial (don't need to use otherwise)
addToExperiment(experiment)



% Set trial list: 2 repetitions of the sequence clockwise, outward, counterclockwise, inward
nn = rep([1 3 2 4], 2);
setTrialList(nn)



% You can call "viewExperiment" and "viewExperiment -d" to visualize trials



% Run
[results, resultsMatrix] = runExperiment;