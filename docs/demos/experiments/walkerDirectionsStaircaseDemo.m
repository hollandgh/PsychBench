% WALKER DIRECTIONS STAIRCASE EXPERIMENT DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Same as walkerDirectionsDemo.m except this demo uses a staircase to vary number
% of mask dots across trials.
%
% Staircase parameters:
% Method:                               fixed step
% Step rule:                            3 correct / 1 incorrect
% Initial value:                        35 (total number of mask dots = staircase value * 2 + 15--see below)
% Step sizes:                           +8 correct, -12 incorrect
% Minimum value:                        15
% Number of fast reversals (1/1 rule):	3
% Fast reversal step sizes:             (same)
% Maximum number of reversals:          30



% See walkerDirectionsDemo.m for more commenting.



newExperiment



% TASK TRIALS
% 2 trial definitions numbered 1-2: 2 directions
% ==========
for d = [1 2]
    % Walker
    % ---
        walker = bmlWalkerObject;

        % bmlWalkerData.mat comes with the bmlWalker element type.
        % Contains cell array "bmlWalkerData".
        % {2} contains the motion data we want to use.
        walker.fileName = "bmlWalkerData.mat";
        walker.dataExpr = "bmlWalkerData{2}";
        
    if d == 1
        % Facing left
        walker.azimuth = -90;
    else
        % Facing right
        walker.azimuth = +90;
    end
    
        % Start at trial start; End at response
        walker.start.t = 0;
        walker.end.response = true;
            
        % See direction # in results
        walker.info.direction = d;
    % ---


    % Walker mask
    % ---            
        % Use two bmlWalker objects superimposed: one for dots facing left, one for
        % facing right
        masks = bmlWalkerObject(2);

        % Mask 1 = same direction as walker, 2 = opposite
        masks(1).azimuth =  walker.azimuth;
        masks(2).azimuth = -walker.azimuth;

        % Staircase number of dots in each mask.
        % Mask 1 (same direction)     = staircase value for trial
        % Mask 2 (opposite direction) = staircase value for trial + 15
        masks(1).staircase.what = "numScrambleDots";
        masks(2).staircase.what = "numScrambleDots";
        masks(1).staircase.setExpr = "staircaseVal";
        masks(2).staircase.setExpr = "staircaseVal+15";

    % All other properties same for both objects...
    for n = 1:2
        % Same motion data as walker
        masks(n).fileName = "bmlWalkerData.mat";
        masks(n).dataExpr = "bmlWalkerData{2}";
        
        % .scramble = true makes it a random dot mask
        masks(n).scramble = true;
            
        % 12 deg square mask area
        masks(n).scrambleAreaSize = [12 12];
            
        % Random motion phase across dots
        masks(n).scramblePhases = true;
            
        % Start/End same as walker
        masks(n).start.t = 0;
        masks(n).end.response = true;
            
        % See number of dots in results.
        % Total number of mask dots = sum of them.
        masks(n).report = "numScrambleDots";
    end
    %---


    % Key press response
    % ---
    response = keyPressObject;

    % Listen for left/right arrow keys.
    % You can get these key names using showKey() at the MATLAB command line.
    % Response value recorded in record property .response will be number of the name in this list, i.e. 1 = left, 2 = right.
    response.listenKeyNames = ["left" "right"];
        
    % Score correct/incorrect.
    % Response values 1 = left, 2 = right conveniently match our loop variable "d", so we can just set correct response = that.
    response.scoreResponse = true;
    response.correctResponse = d;
        
    % Start at trial start
    response.start.t = 0;
    % By default keyPress elements end when they record a response -> don't need to set .end
    
    % See response, score, response latency in results
    response.report = ["response" "responseScore" "responseLatency"];
    % ---


    % Add trial definition with default numbering (1, 2, 3, ...)
    addTrial(walker, masks, response);
end
% ==========



% TRAINING TRIALS
% ==========
% WALKER WITH NO MASK
% 2 trial definitions numbered 101, 102: 2 directions, no mask
for d = [1 2]
        walker = bmlWalkerObject;
        walker.fileName = "bmlWalkerData.mat";
        walker.dataExpr = "bmlWalkerData{2}";
    if d == 1
        walker.azimuth = -90;
    else
        walker.azimuth = +90;
    end
        walker.start.t = 0;
        walker.end.response = true;


    response = keyPressObject;
    response.listenKeyNames = ["left" "right"];
    response.scoreResponse = true;
    response.correctResponse = d;
    response.start.t = 0;


    % Add trial definition to group 100 (101, 102, ...)
    addTrial(walker, response, 100);
end


% WALKER WITH MINIMAL MASK
% 2 trial definitions numbered 201, 202: 2 directions, same number of mask dots in each
for d = [1 2]
        walker = bmlWalkerObject;
        walker.fileName = "bmlWalkerData.mat";
        walker.dataExpr = "bmlWalkerData{2}";
    if d == 1
        walker.azimuth = -90;
    else
        walker.azimuth = +90;
    end
        walker.start.t = 0;
        walker.end.response = true;


    %Mask = 15 dots facing opposite direction 15-dot walker
    mask = bmlWalkerObject;
    mask.azimuth = -walker.azimuth;
    mask.numScrambleDots = 15;
    mask.fileName = "bmlWalkerData.mat";
    mask.dataExpr = "bmlWalkerData{2}";
    mask.scramble = true;
    mask.scrambleAreaSize = [12 12];
    mask.scramblePhases = true;
    mask.start.t = 0;
    mask.end.response = true;


    response = keyPressObject;
    response.listenKeyNames = ["left" "right"];
    response.scoreResponse = true;
    response.correctResponse = d;
    response.start.t = 0;


    % Add trial definition to group 200 (201, 202, ...)
    addTrial(walker, mask, response, 200);
end


% PAUSE TRIAL
% ---
pauseText = textObject;
pauseText.text = "Press any key to continue...";
pauseText.start.t = 0;
pauseText.end.response = true;


anyKey = keyPressObject;
anyKey.start.t = 0;


%Add trial definition with name "pause"
addTrial(pauseText, anyKey, "pause");
% ---
% ==========



% Set trial list:
%
% - 3 x 2 walker only training trial definitions in random order
% - pause
% - 3 x 2 walker + mask training trial definitions in random order
% - pause
% - 40 x 2 task trial definitions in random order
%
% Random order just to randomize left/right
nn = {randomOrder(rep(101:102, 3)) "pause" randomOrder(rep(201:202, 3)) "pause" randomOrder(rep(1:2, 40))};
setTrialList(nn)



% Staircase
% ---
staircase = fixedStepStaircaseObject;

% 3 correct / 1 incorrect rule
staircase.stepRule = [3 1];

% Staircase value will apply to number of mask dots.
% Need initial number of mask dots + any combination of steps = integer, don't step below 0, so mask .numDots always = valid value.
% Staircase value step sizes after correct/incorrect response trials = increase number of mask dots by 4, decrease by 6.
% These values translate to val1 = 35, step sizes = [+8 -12], min = 15 dots in overall display given how staircase applied above.
staircase.val1 = 10;
staircase.stepSizes = [4 -6];
staircase.min = 0;

% 3 fast (1/1 rule) reversals at start to get near subject's threshold fast
staircase.numFastReversals = 3;

% Staircase ends after 30 reversals
staircase.maxNumReversals = 30;

% Report staircase value, reversed true/false, threshold estimate, number of trials run, number of reversals in experiment results.
% For staircases these record properties report at each trial.
staircase.report = ["val" "reversed" "threshold" "numTrialsRan" "numReversals"];


addToExperiment(staircase)
% ---



% You can call "viewExperiment" and "viewExperiment -d" to visualize trials


[results, resultsMatrix] = runExperiment;