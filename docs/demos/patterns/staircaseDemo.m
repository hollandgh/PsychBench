% STAIRCASE DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Each trial shows a picture twice for 0.5 sec each time with 0.5 sec interval
% between them. The first picture is rotated at a random angle. The second
% picture is the same or rotated at a different angle. The subject responds with
% up arrow key press if the pictures have same rotation, or down arrow if they
% have different rotation. Across trials where the rotations are different, the
% magnitude of the difference is staircased using a staircase, and the direction
% of the difference (rotation 2 - rotation 1 = +/-) is balanced. We run 30
% trials with same rotation and 30 trials with different rotations, all in
% random order.
%
% Staircase parameters:
% Method:                               fixed step
% Step rule:                            3 correct / 1 incorrect
% Initial value:                        10 (rotation difference magnitude, deg)
% Step sizes:                           -1.5 correct, +2.5 incorrect
% Minimum value:                        0
% Number of fast reversals (1/1 rule):	3
% Fast reversal step sizes:             -3   correct, +5   incorrect
% Maximum number of reversals:          no limit



% Mark start of experiment script
newExperiment



% TRIALS
% 60 trial definitions: 2 same/different x 2 sign x 15 random rotations each.
% * Note difference from visual method: In coding method need a different trial
% definition for each random rotation because the objects input to addTrial()
% have set values. The randomNum() expression is already evaluated, so cannot be
% re-evaluated by repeat running a trial definition.
% ---
for isSame = [true false]
    for sign = [-1 +1]
        for n_rep = 1:15
                    % Make 2 picture objects for the trial
                    pics = pictureObject(2);

                    % Properties the same for both pictures
                for n = 1:2
                    pics(n).fileName = "green cylinder.png";
                    pics(n).height = 10;
                    pics(n).report = "rotation";
                end

                    % Picture 1 - random rotation
                    pics(1).rotation = randomNum(0, 360);
                    pics(1).start.t = 0;
                    pics(1).end.t = 0.5;

                    % Picture 2...
            if isSame
                    % Same rotation as picture 1
                    pics(2).rotation = pics(1).rotation;
            else
                    % Different rotation than picture 1.
                    % Staircase difference magnitude, balanced difference direction across trials.
                    % Note this takes advantage of number + "string" syntax, e.g. 2+"hello" = "2hello"
                    pics(2).staircase.what = "rotation";
                if sign == -1
                    pics(2).staircase.setExpr = pics(1).rotation + "-staircaseVal";
                else
                    pics(2).staircase.setExpr = pics(1).rotation + "+staircaseVal";
                end
            end
                    pics(2).start.t = 1;
                    pics(2).end.t = 1.5;


            % Response handler for the trial - up/down arrow key press.
            % You can get key names using showKey() at the MATLAB command line.
            % Raw response value is number of the name in the list we set in .listenKeyNames, i.e. 1 = up, 2 = down.
            % Then translate 1/2 -> true/false (same rotation / not) for all purposes including scoring and recording.
            % Need response scoring on for staircase.
            % Correct response = same rotation / not from loop variable "isSame".
            % By default keyPress elements end when they record a response -> don't need to set .end.
            recorder = keyPressObject;
            recorder.listenKeyNames = ["up" "down"];
            recorder.translateResponse = [
                1 true
                2 false
                ];
            recorder.scoreResponse = true;
            recorder.correctResponse = isSame;
            recorder.start.t = 0;
            recorder.report = ["response" "correctResponse" "responseScore" "responseLatency"];
            

            % Add trial definition with default numbering (1, 2, 3, ...)
            addTrial(pics, recorder);
        end
    end
end
% ---



% Trial list: run the trial definitions in random order.
% Randomization of isSame, sign implemented here.
nn = randomOrder(1:60);
setTrialList(nn);



% STAIRCASE OBJECT
% ---
staircase = fixedStepStaircaseObject;

% 3 correct / 1 incorrect rule.
staircase.stepRule = [3 1];

% Staircase value will apply to picture rotation difference magnitude.
% Initial rotation difference magnitude = 10 deg.
% Staircase value step sizes after correct/incorrect response trials = decrease rotation difference magnitude by 1.5 deg, increase by 2.5 deg.
% Don't step below 0 deg.
staircase.val1 = 10;
staircase.stepSizes = [-1.5 2.5];
staircase.min = 0;

% 3 fast (1/1 rule) reversals at start to get near subject's threshold fast.
% Step sizes for fast reversals = -3, +5.
staircase.numFastReversals = 3;
staircase.fastStepSizes = [-3 5];

% Report staircase value, reversed true/false, threshold estimate, number of trials run, number of reversals in experiment results.
% For staircases these record properties report at each trial.
staircase.report = ["val" "reversed" "threshold" "numTrialsRan" "numReversals"];


% Add staircase object to experiment
addToExperiment(staircase)
% ---



% Run
[results, resultsMatrix] = runExperiment;



% See also: 
% - response handler property .scoreResponseForStaircase - www.psychbench.org/docs/responsehandler#scoreresponse
% - trial object     property .withStaircase             - www.psychbench.org/docs/trial#withstaircase