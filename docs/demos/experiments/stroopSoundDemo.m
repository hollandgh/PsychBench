% STROOP W/ SOUND RECORDING EXPERIMENT DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Same as Stroop experiment demo except here the subject actually SAYS the ink
% color and the experiment records it as sound, then the subject presses any key
% when they're ready for the next word. The disadvantage is results analysis is
% a bit more work: For each trial, the start times of sound recording and visual
% stimulus are in experiment results output, but the sound recording itself is
% saved to a .wav file in your MATLAB current folder. To measure response
% latency, you could use a sound editor app to visualize and measure the time of
% onset of the subject speaking relative to stimulus onset, based on the two
% time numbers in results.



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

        % Start at 0.5 sec from trial start to give some buffer from when sound recording starts (below).
        % Just in case there is some latency in sound recording start, so we don't miss a response.
        % End at key press.
        text.start.t = 0.5;
        text.end.response = true;

        % See word #, ink color #, congruent (true/false), text, color, start time in results
        text.info.n_word = w;
        text.info.n_ink = i;
        % Congruent if word # matches ink color #
        text.info.congruent = w == i;
        text.report = "startTime";
        % ---


        % Sound recorder
        % ---
        response = soundRecorderObject;

        % Base file name to record to in MATLAB current folder.
        % Sound recorder will automatically add 01, 02, 03, ...
        response.fileName = "stroop.wav";
        response.minNumDigitsInFileName = 2;

        % Start at trial start; End at key press
        response.start.t = 0;
        response.end.response = true;

        % See file name and number, recording start time in results
        response.report = ["fileName_r" "n_file" "startTime"];
        % ---


        % Key press
        % ---
        anyKey = keyPressObject;

        % By default listens for any key, then ends on its own.
        % Just need to say start when text starts:
        anyKey.start.t = 0.5;
        % ---


        % Add trial definition with default numbering (1, 2, 3, ...)
        addTrial(text, response, anyKey);
    end
end
% ==========



% INTRO, BREAK, OUTRO TRIALS
% ==========
% Intro
text = textObject;
% Each string in the array is a new line
text.text = [
    "Say the color of the ink, not what the word says."
    "Respond as fast as possible while still trying to be correct."
    "Then press any key for the next word."
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