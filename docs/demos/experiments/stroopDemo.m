% STROOP EXPERIMENT DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Stroop task. Each trial shows one of three color words, and the word is shown
% in one of the three colors. The subject responds by key press with the "ink"
% color of the word, not the word itself (left/down/right arrow key = red/green/blue). 
% If the Stroop effect applies, we expect more incorrect responses and greater
% response latency for congruent trials where ink color and word match, than for
% incongruent trials where they don't.
%
% 9 conditions: 3 red/green/blue ink x 3 words "red"/"green"/"blue". In each
% block we run 2 repetitions of each of these 9 trials for a total of 18 trials,
% all in random order. We run 2 blocks. We also run an intro trial, a break
% trial between the blocks, and an outro trial.
%
% https://en.wikipedia.org/wiki/Stroop_effect
%
% For a more classic implementation where the subject responds verbally, see stroopSoundDemo.m.



newExperiment



% TASK TRIALS
% ==========
% Define 3 words
words = [
    "RED"
    "GREEN"
    "BLUE"
    ];

% Define 3 ink colors (RGB)
colors = [
    1 0 0   % red
    0 1 0   % green
    0 0 1   % blue
    ];

% 9 trial definitions numbered 1-9: 3 words x 3 ink colors
for w = 1:3
    for i = 1:3
        % Text
        % ---
        text = textObject;
        
        % Set word and display color using word #, color #
        text.text = words(w);
        text.color = colors(i,:);
        
        % Make this text a bit bigger than default (deg)
        text.fontSize = 1.5;

        % Start at trial start; End at response
        text.start.t = 0;
        text.end.response = true;

        % See word #, ink color #, congruent (true/false), text, color in results
        text.info.n_word = w;
        text.info.n_ink = i;
        % Congruent if word # matches ink color #
        text.info.congruent = w == i;
        text.report = ["text" "color"];
        % ---


        % Key press response
        % ---
        response = keyPressObject;

        % Listen for left/down/right arrow keys.
        % You can get these key names using showKey() at the MATLAB command line.
        % Response value recorded in record property .response will be number of the name in this list, i.e. 1 = left, 2 = down, 3 = right.
        response.listenKeyNames = ["left" "down" "right"];

        % Score correct/incorrect.
        % Response values 1 = left, 2 = down, 3 = right conveniently match our loop variable "c", so we can just set correct response = that.
        response.scoreResponse = true;
        response.correctResponse = i;

        % Start at trial start
        response.start.t = 0;
        % By default keyPress elements end when they record a response -> don't need to set .end

        % See response, score, latency in results
        response.report = ["response" "responseScore" "responseLatency"];
        % ---


        % Add trial definition with default numbering (1, 2, 3, ...)
        addTrial(text, response);
    end
end
% ==========



% INTRO, BREAK, OUTRO TRIALS
% ==========
% Intro
text = textObject;
% Each string in the array is a new line
text.text = [
    "Press the color of the ink, not what the word says."
    "Respond as fast as possible while still trying to be correct."
    ""
    "left = red ink"
    "down = green ink"
    "right = blue ink"
    ""
    "Press any key to start..."
    ];
% Make this text a bit smaller than default (deg)
text.fontSize = 0.7;
% Change font color from default white to black cause we will use a white background
text.color = [0 0 0];
% Align left instead of center
text.alignment = "l";
text.start.t = 0;
text.end.response = true;

% Default keyPress object = press any key
anyKey = keyPressObject;
anyKey.start.t = 0;

%Add trial definition with name "intro"
addTrial(text, anyKey, "intro");


%Break trial.
%Use same objects from above, just change the text.
text.text = [
    "Take a break."
    "Press any key when you are ready to continue..."
    ];
addTrial(text, anyKey, "break");


%Outro trial
text.text = "Done--thank-you!";
addTrial(text, anyKey, "outro");
% ==========



% Set trial list:
%
% - intro trial
% - 2 repetitions of each task trial definition in random order 
% - break trial
% - 2 repetitions of each task trial definition in random order 
% - outro trial
%
% Random order just to randomize left/right
nn = {"intro" randomOrder(rep(1:9, 2)) "break" randomOrder(rep(1:9, 2)) "outro"};
setTrialList(nn)



% Set experiment background color to white in an experiment object
experiment = experimentObject;
experiment.backColor = [1 1 1];
addToExperiment(experiment)



% You can call "viewExperiment" and "viewExperiment -d" to visualize trials

[results, resultsMatrix] = runExperiment;