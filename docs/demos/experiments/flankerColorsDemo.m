% FLANKER COLORS EXPERIMENT DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Eriksen flanker task with colored squares. Each trial shows a "target" square
% centered on screen and four other "flanker" squares arranged two on each side
% (see property settings below for sizes and positions). The target can be red,
% green, blue, or orange. The flankers can be red, green, blue, orange, or gray.
% All the flankers in a trial are the same. The subject responds with left arrow
% key if the target is red OR green, or right arrow key if orange OR gray,
% trying to ignore the flankers. A further factor is:
%
% Target = red/green,   Flankers = red/green    -> CONGRUENT
% Target = blue/orange, Flankers = blue/orange  -> CONGRUENT
% Target = red/green,   Flankers = blue/orange  -> INCONGRUENT
% Target = blue/orange, Flankers = red/green    -> INCONGRUENT
% Target = red/green,   Flankers = gray         -> NEUTRAL
% Target = blue/orange, Flankers = gray         -> NEUTRAL
%
% Each combination of 4 targets x 5 flankers is tested x2 = 40 trials, all in
% random order. The experiment starts with instructions and a prompt to press
% any key to start.
%
% https://en.wikipedia.org/wiki/Eriksen_flanker_task
%
% For the same paradigm except with arrows, see flankerArrowsDemo.m.



newExperiment



% TASK TRIALS
% ==========

%Define 5 RGB colors and color names
colors = [
    0.5 0.8 0.5
    0.8 0.5 0.5
    0.5 0.5 0.5
    0.5 0.5 0.8
    0.9 0.4 0.2
    ];
colorNames = ["red" "green" "gray" "blue" "orange"];

% 20 trial definitions numbered 1-20: each combination of 4 target colors x 5 flanker colors
for n_targetColor = [1 2 4 5]
    for n_flankerColor = 1:5
        % Trial object
        % ---
            % Set some information to see in experiment results output.
            % Do here because it isn't always specific to any one rectangle object below.
            
            trial = trialObject;
            
            trial.info.n_targetColor = n_targetColor;
            trial.info.targetColorName = colorNames(n_targetColor);
            trial.info.targetColor = colors(n_targetColor,:);
            
            trial.info.n_flankerColor = n_flankerColor;
            trial.info.flankerColorName = colorNames(n_flankerColor);
            trial.info.flankerColor = colors(n_flankerColor,:);
            
        if      n_flankerColor == 3
            trial.info.n_condition = 2;
            trial.info.conditionName = "neutral";
        elseif  ismember(n_targetColor, [1 2]) && ismember(n_flankerColor, [1 2]) || ...
                ismember(n_targetColor, [3 4]) && ismember(n_flankerColor, [3 4])
            
            trial.info.n_condition = 1;
            trial.info.conditionName = "congruent";
        else
            trial.info.n_condition = 0;
            trial.info.conditionName = "incongruent";
        end
        % ---


        % Target square
        % ---
        target = rectangleObject;

        % Set color using color #
        target.color = colors(n_targetColor,:);
        
        % 3 deg square
        target.size = 3;        

        % Start at trial start; End at response
        target.start.t = 0;
        target.end.response = true;
        % ---
        
        
        % Flanker squares
        % ---
            flankers = rectangleObject(4);
            
            % Space 4 deg apart
            flankers(1).position = [-8 0];
            flankers(2).position = [-4 0];
            flankers(3).position = [+4 0];
            flankers(4).position = [+8 0];            
            
        for n = 1:4
            flankers(n).color = colors(n_flankerColor,:);

            flankers(n).size = 3;        

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
        if ismember(n_targetColor, [1 2])
            % Target = red/green -> correct = left (1)
            response.correctResponse = 1;
        else
            % Target = blue/orange -> correct = right (2)
            response.correctResponse = 2;
        end

            % Start at trial start
            response.start.t = 0;
            % By default keyPress elements end when they record a response -> don't need to set .end

            % See response, score, response latency in results
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

% Change to instructions text.
% Use in-line formatting options (color).
text.text = "Look at the square in the middle and press the left arrow key if it is <color = [0.5 0.8 0.5]>green<color = [1 1 1]> OR <color = [0.8 0.5 0.5]>red<color = [1 1 1]>, or the right arrow key if it is <color = [0.5 0.5 0.8]>blue<color = [1 1 1]> OR <color = [0.9 0.4 0.2]>orange<color = [1 1 1]>. Try to ignore the squares on the sides. Respond as fast as you can while still trying to answer correctly.";

% Add trial definition with name "intro"
addTrial(text, anyKey, "intro");
% ==========



% Set trial list: Intro, then 2 reps of each trial definition all in random order
nn = {"intro" randomOrder(rep(1:20, 2))};
setTrialList(nn)



% You can call "viewExperiment" and "viewExperiment -d" to visualize trials



[results, resultsMatrix] = runExperiment;