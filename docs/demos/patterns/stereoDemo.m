% STEREO DISPLAY DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Each trial shows a different random dot stereogram until the subject presses
% any key. This is a stimulus consisting of a background of noise with a smaller
% patch of noise on top. The smaller patch is offset horizontally by a small
% amount on one eye only. This simulates a binocular parallax depth cue when
% viewed in stereo. Trials test 6 noise offsets = -0.1, -0.2, -0.3, +0.1, +0.2,
% +0.3 deg. The direction of offset informs the direction of depth perceived (on
% top / behind). We run 2 repetitions of each offset for a total of 12 trials,
% all in random order.



% Mark start of experiment script
newExperiment


            % Background noise - same in all trials
            % ---
            backgroundNoise = noiseObject;

            % Rectangular intensity probability distribution from intensity 0-1, quantized
            % to 0/1 -> black/white noise
            backgroundNoise.sigma = inf;
            backgroundNoise.numLevels = 2;

            % Leave .size = default to show full screen.
            % Leave all other noise parameters like .maxFrequency at default.
            % Leave .nn_eyes = default [1 2] to show on both left/right eyes.

            % Start at trial start.
            % End at any response.
            backgroundNoise.start.t = 0;
            backgroundNoise.end.response = true;
            % ---


            % Object to listen for any key press - same in all trials
            % ---
            anyKey = keyPressObject;
            anyKey.start.t = 0;
            % ---


% 12 trial definitions: 6 offsets x 2 random patterns each.
% * Note difference from visual method: In coding method need a different trial
% definition for each random pattern because the objects input to addTrial()
% have set values. The rng() expression is already evaluated, so cannot be
% re-evaluated by repeat running a trial definition.
offsets = [-0.1 -0.2 -0.3 +0.1 +0.2 +0.3];
for o = 1:6
    for r = 1:2
        offset = offsets(o);
        
        % Generate a MATLAB random number generate state for this rep to use in .seed below
        seed = rng('shuffle');


        % Foreground noise patch
        % ---
        % Same parameters as background noise except we make two foreground noise
        % objects, one for left eye and one for right. They will be identical except for
        % position.

            foregroundNoises = noiseObject(2);
        for n = 1:2
            % Patch size = 8 deg square
            foregroundNoises(n).size = 8;

            foregroundNoises(n).sigma = inf;
            foregroundNoises(n).numLevels = 2;

            % Tell each foreground noise patch to use MATLAB's random number generator
            % seeded to the same state so they have precisely the same (pseudo)random
            % pattern
            foregroundNoises(n).seed = seed;

            foregroundNoises(n).start.t = 0;
            foregroundNoises(n).end.response = true;
        end

            % One foreground noise patch is shown on left eye, other on right eye, with opposite horizontal shifts with magnitude = 1/2 total offset
            foregroundNoises(1).position = [-offset/2 0];
            foregroundNoises(1).nn_eyes = 1;
            foregroundNoises(2).position = [+offset/2 0];
            foregroundNoises(2).nn_eyes = 2;
        % ---

        
        %See offset in trial results.
        %Use trial object cause not specific to one element.
        trial = trialObject;
        trial.info.offset = offset;
        

        % Add trial definition with default numbering (1, 2, 3, ...)
        addTrial(backgroundNoise, foregroundNoises, anyKey, trial);
    end
end


% Set stereo mode using screen object: 6 = red/green anaglyph.
% You can change this if you want to try different modes--see www.psychbench.org/docs/screen#stereo.
screen = screenObject;
screen.stereo = 6;

addToExperiment(screen)


% Trial list: run the trial definitions in random order
nn = randomOrder(1:12);
setTrialList(nn)


% Run
runExperiment;