% GO/NO-GO EXPERIMENT DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% A go/no-go task using colored squares. Each trial shows either a red or blue
% square centered on screen (see property settings below for size). The subject
% responds with any key press if the square is blue, else does not respond if
% red. Time limit for response is 1 sec. The subject receives correct/incorrect
% text feedback for 1 sec. A fixation cross shows in inter-trial intervals. We
% run 10x each color trial = 20 trials, all in random order. The experiment
% starts with instructions and 6 training trials: 3 of each color, all in random
% order.



newExperiment



% TRIAL TEMPLATE
% ==========
% Make objects and set only properties that will be the same in all trials where we will use the template...


% Fixation cross
% ---
cross = crossObject;

% Leave properties at default for a small white cross

% Run in pre-trial interval
cross.start.pretrial = true;
% ---


% Square
% ---
square = rectangleObject;

% 5 deg square
square.size = 5;

% Start at trial start; End at response
square.start.t = 0;
square.end.response = true;
% ---


% Key press response handler
% ---
anyKey = keyPressObject;

% Leave .listenKeyNames at default = listen for any key

% Record response = NaN if no response before object ends so feedback below will also start at no response
anyKey.recordDefaultResponse = true;

% Start at trial start
anyKey.start.t = 0;
% End at duration = 1 sec -> time limit for response
anyKey.end.duration = 1;
% By default keyPress elements also end when they record one response
% ---


% Feedback
% ---
% Use standard template for correct/incorrect feedback text.
% Gets a 1x2 array of text objects (correct, incorrect) with relevant properties pre-set, which you can tweak and/or add to if needed:
%
% (1).text              = "CORRECT";
% (1).color             = [0.7 1 0.7];
% (1).start.response    = true;
% (1).start.and         = "responseScore == true";
% (1).end.duration      = 1;
% 
% (2).text              = "INCORRECT";
% (2).color             = [1 0.7 0.7];
% (2).start.response    = true;
% (2).start.and         = "responseScore == false";
% (2).end.duration      = 1;
feedbacks = getTemplate("feedbackText");
% ---


% Add template with name "trial"
addTemplate(cross, square, anyKey, feedbacks, "trial");
% ==========



% TASK TRIALS
% ==========
% 2 trial definitions numbered 1-2: one for each color
for n_color = 1:2
    % Start with objects as set in template "trial" above
    [cross, square, anyKey, feedbacks] = getTemplate("trial");
    
    
    % Fixation cross
    % ---
    % (Nothing to add)
    % ---


    % Square
    % ---
        % Set some information to see in experiment results output.
        % Also set RGB color.
        
        square.info.n_color = n_color;    
    if n_color == 1
        square.info.colorName = "red";
        square.color = [1 0 0];
    else
        square.info.colorName = "blue";
        square.color = [0 0 1];
    end
    % ---


    % Key press response handler
    % ---
    % Score correct/incorrect using custom scoring equation
    if n_color == 1
        % Red -> correct = no key press (response = NaN)
        anyKey.scoreResponse = "isnan(response)";
    else
        % Blue -> correct = any key press (response ~= NaN)
        anyKey.scoreResponse = "~isnan(response)";
    end

        % See response, score, response latency in results
        anyKey.report = ["response" "responseScore" "responseLatency"];
    % ---


    % Feedback
    % ---
    % (Nothing to add)
    % ---


    % Add trial definition with default numbering (1, 2, ...)
    addTrial(cross, square, anyKey, feedbacks);
end
% ==========



% TRAINING TRIALS
% ==========
% Same as task trial definitions except no experiment results output and different feedback
for n_color = 1:2
    [cross, square, anyKey, feedbacks] = getTemplate("trial");
    
    
    % Square
    % ---
    if n_color == 1
        square.color = [1 0 0];
    else
        square.color = [0 0 1];
    end
    
    % Don't set .info/report -> nothing in results for this object
    % ---


    % Mouse click response
    % ---
    if n_color == 1
        anyKey.scoreResponse = "isnan(response)";
    else
        anyKey.scoreResponse = "~isnan(response)";
    end
    
    % Don't set .info/report -> nothing in results for this object
    % ---


    % Feedback
    % ---
    % Increase feedback durations for longer text
    feedbacks(1).end.duration = 1.5;
    feedbacks(2).end.duration = 3;
    
    % Change text for incorrect feedback.
    % Strings in an array are separate lines.
    if n_color == 1
        feedbacks(2).text = [
            "INCORRECT"
            "Remember only press a key when the blue square appears..."
            ];
    else
        feedbacks(2).text = [
            "INCORRECT"
            "Remember press a key when the blue square appears..."
            ];
    end
    % ---


    % Add trial definition to group 100 (101, 102, ...)
    addTrial(cross, square, anyKey, feedbacks, 100);
end
% ==========



% INTRO, PAUSE TRIALS
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
% Each string in the array is a new line.
% Use in-line formatting options (color).
text.text = [
    "Press a key only when you see the <color = [0 0 1]>BLUE<color = [1 1 1]> square."
    "Let's start with a few tries to get the hang of it..."
    "Press any key to start--"
    ];

% Add trial definition with name "intro"
addTrial(text, anyKey, "intro");



[text, anyKey] = getTemplate("keyMessage");

text.text = "Okay! Now let's try it for real...";

%Add trial definition with name "pause"
addTrial(text, anyKey, "pause");
% ==========



% Set trial list:
% - intro
% - 3 x 2 training trial definitions in random order
% - pause
% - 10 x 2 task trial definitions in random order
nn = {"intro" randomOrder(rep(101:102, 3)) "pause" randomOrder(rep(1:2, 10))};
setTrialList(nn)



% You can call "viewExperiment" and "viewExperiment -d" to visualize trials



[results, resultsMatrix] = runExperiment;