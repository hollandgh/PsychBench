% FLANKER ARROWS EXPERIMENT DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Eriksen flanker task with left/right arrows. Each trial shows a "target" arrow
% centered on screen and four other "flanker" arrows arranged two on each side
% (see property settings below for sizes and positions). The target can be left
% or right. The flankers can be left, right, or a dash which is just an arrow
% tail extended to the same length as the arrows. All the flankers in a trial
% are the same. The subject responds with left arrow key if the target is left,
% or right arrow key if right, trying to ignore the flankers. A further factor
% is:
%
% Target = left,  Flankers = left   -> CONGRUENT
% Target = right, Flankers = right  -> CONGRUENT
% Target = left,  Flankers = right  -> INCONGRUENT
% Target = right, Flankers = left   -> INCONGRUENT
% Target = left,  Flankers = dash   -> NEUTRAL
% Target = right, Flankers = dash   -> NEUTRAL
%
% Each combination of 2 targets x 3 flankers is tested x3 = 18 trials, all in
% random order. The experiment starts with instructions and a prompt to press
% any key to start.
%
% https://en.wikipedia.org/wiki/Eriksen_flanker_task
% 
% For the same paradigm except with colors, see flankerColorsDemo.m.



newExperiment



% TASK TRIALS
% ==========

% Define 3 arrows and arrow names.
% Arrow and fash files are in <PsychBench folder>/materials.
arrowFileNames = ["left white.png" "right white.png" "horizontal white.png"];
arrowNames = ["left" "right" "dash"];

% 6 trial definitions numbered 1-6: each combination of 2 target arrows x 3 flanker arrows
for n_targetArrow = 1:2
    for n_flankerArrow = 1:3
        % Trial object
        % ---
            % Set some information to see in experiment results output.
            % Do here because it isn't always specific to any one picture object below.
            
            trial = trialObject;
            
            trial.info.n_targetArrow = n_targetArrow;
            trial.info.targetArrowName = arrowNames(n_targetArrow);
            
            trial.info.n_flankerArrow = n_flankerArrow;
            trial.info.flankerArrowName = arrowNames(n_flankerArrow);
            
        if      n_flankerArrow == 3
            trial.info.n_condition = 0;
            trial.info.conditionName = "neutral";
        elseif  n_targetArrow == n_flankerArrow
            trial.info.n_condition = +1;
            trial.info.conditionName = "congruent";
        else
            trial.info.n_condition = -1;
            trial.info.conditionName = "incongruent";
        end
        % ---
        

        % Target arrow
        % ---
        target = pictureObject;
        
        % Set file name using arrow #
        target.fileName = arrowFileNames(n_targetArrow);
        
        % 3 deg height
        target.height = 3;

        % Start at trial start; End at response
        target.start.t = 0;
        target.end.response = true;
        % ---
        
        
        % Flanker arrows
        % ---
            flankers = pictureObject(4);
            
            % Space 4 deg apart
            flankers(1).position = [-8 0];
            flankers(2).position = [-4 0];
            flankers(3).position = [+4 0];
            flankers(4).position = [+8 0];            
            
        for n = 1:4
            flankers(n).fileName = arrowFileNames(n_flankerArrow);

            flankers(n).height = 3;        

            flankers(n).start.t = 0;
            flankers(n).end.response = true;
        end
        % ---


        % Key press response handler
        % ---
            response = keyPressObject;

            % Listen for left/right arrow keys.
            % You can get these key names using showKey() at the MATLAB command line.
            % Response value recorded in record property .response will be number of the name in this list, i.e. 1 = left, 2 = right.
            response.listenKeyNames = ["left" "right"];
        
        % Score correct/incorrect
            response.scoreResponse = true;
        if n_targetArrow == 1
            % Target = left -> correct = left (1)
            response.correctResponse = 1;
        else
            % Target = right -> correct = right (2)
            response.correctResponse = 2;
        end

            % Start at trial start
            response.start.t = 0;
            % By default keyPress elements end when they record a response -> don't need to set .end

            % See response, score, latency in results
            response.report = ["response" "responseScore" "responseLatency"];
        % ---
        
        
        % Add trial definition with default numbering (1, 2, 3, ...)
        addTrial(target, flankers, response, trial);
    end
end
% ==========



% INTRO TRIAL
% ==========
    % Use standard template for a trial that shows a message until the subject presses any key.
    % Gets text and keyPress objects with relevant properties pre-set, which you can tweak and/or add to if needed:
    %
    % <text>.text           = "Press any key to continue...";
    % <text>.fontSize       = 0.7;
    % <text>.wrapWidth      = 60;
    % <text>.start.t        = 0;
    % <text>.end.response	= true;
    %
    % <keyPress>.start.t    = 0;
    [text, anyKey] = getTemplate("keyMessage");

    % Change to instructions text
    text.text = "Look at the arrow in the middle and press the arrow key corresponding to it: left or right. Try to ignore the shapes on the sides. Respond as fast as you can while still trying to be correct.";

    % Add trial definition with name "intro"
    addTrial(text, anyKey, "intro");
% ==========



% Set trial list: Intro, then 2 reps of each trial definition all in random order
nn = {"intro" randomOrder(rep(1:6, 3))};
setTrialList(nn)



% You can call "viewExperiment" and "viewExperiment -d" to visualize trials



[results, resultsMatrix] = runExperiment;