% WISCONSIN CARD SORTING EXPERIMENT DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Wisconsin card sorting task using a deck of 64 card images. Each card shows a
% number (1-4) of one of 4 shapes (circle, cross, star, triangle) in one of 4
% colors (red, green, blue, yellow) (4x4x4 = 64).
%
% Each trial shows one "test" card, and four "reference" cards arranged
% horizontally below it (see property settings below for sizes and positions).
% The test card is different in each trial. The set of four reference cards is
% the same across trials. The reference cards are chosen randomly for the
% experiment such that all four possibilities for number, color, and shape are
% in the set (e.g. 1 red circle, 2 green crosses, 3 blue stars, 4 yellow triangles). 
% The subject responds by mouse click on one of the reference cards with which
% one matches the test card. The correct match is by one of three rules: number,
% shape, color. The match rule changes every 10 trials. The subject sees
% correct/incorrect feedback after each choice, and they need to figure out the
% rule by trial and error each time it changes. We run 60 trials, one for each
% of the 60 cards not among the four reference cards (i.e. reference cards are
% not test cards), all in random order. This corresponds to 2 10-trial blocks
% for each of the 3 rules, also in random order.
%
% https://en.wikipedia.org/wiki/Wisconsin_Card_Sorting_Test



newExperiment



%Card file names, copied from <PsychBench folder>/materials/Wisconson cards/list_matlab.txt.
%Could also just load them into the workspace using MATLAB readlines().
fileNames = [
    "1-blue-circle.png"
    "1-blue-cross.png"
    "1-blue-star.png"
    "1-blue-triangle.png"
    "1-green-circle.png"
    "1-green-cross.png"
    "1-green-star.png"
    "1-green-triangle.png"
    "1-red-circle.png"
    "1-red-cross.png"
    "1-red-star.png"
    "1-red-triangle.png"
    "1-yellow-circle.png"
    "1-yellow-cross.png"
    "1-yellow-star.png"
    "1-yellow-triangle.png"
    "2-blue-circle.png"
    "2-blue-cross.png"
    "2-blue-star.png"
    "2-blue-triangle.png"
    "2-green-circle.png"
    "2-green-cross.png"
    "2-green-star.png"
    "2-green-triangle.png"
    "2-red-circle.png"
    "2-red-cross.png"
    "2-red-star.png"
    "2-red-triangle.png"
    "2-yellow-circle.png"
    "2-yellow-cross.png"
    "2-yellow-star.png"
    "2-yellow-triangle.png"
    "3-blue-circle.png"
    "3-blue-cross.png"
    "3-blue-star.png"
    "3-blue-triangle.png"
    "3-green-circle.png"
    "3-green-cross.png"
    "3-green-star.png"
    "3-green-triangle.png"
    "3-red-circle.png"
    "3-red-cross.png"
    "3-red-star.png"
    "3-red-triangle.png"
    "3-yellow-circle.png"
    "3-yellow-cross.png"
    "3-yellow-star.png"
    "3-yellow-triangle.png"
    "4-blue-circle.png"
    "4-blue-cross.png"
    "4-blue-star.png"
    "4-blue-triangle.png"
    "4-green-circle.png"
    "4-green-cross.png"
    "4-green-star.png"
    "4-green-triangle.png"
    "4-red-circle.png"
    "4-red-cross.png"
    "4-red-star.png"
    "4-red-triangle.png"
    "4-yellow-circle.png"
    "4-yellow-cross.png"
    "4-yellow-star.png"
    "4-yellow-triangle.png"
    ];

% Reshape into a 4x4x4 (number x color x shape) string array for easier indexing below
fileNames = reshape(fileNames, [4 4 4]);
fileNames = permute(fileNames, [3 2 1]);

% Randomly select 4 reference cards with all 4 values for each of number, color, shape present.
% 4x3 matrix with rows containing [number, color, shape] indexes to fileNames above.
% Uses randomOrder() in <PsychBench folder>/tools.
nn_refNums      = randomOrder(1:4);
nn_refColors    = randomOrder(1:4);
nn_refShapes    = randomOrder(1:4);
    nn_refCards = zeros(4, 3);
for n = 1:4
    nn_refCards(n,:) = [nn_refNums(n) nn_refColors(n) nn_refShapes(n)];
end

% 4x2 matrix with rows containing reference card positions: 4 deg down from center (+y = down), centered horizontally, spaced horizontally 5 deg apart
refCardPositions = [
    -7.5    4
    -2.5    4
     2.5    4
     7.5    4
     ];



% TRIAL TEMPLATE
% ==========
    % Make objects and set only properties that will be the same in all trials where we will use the template...


    % Test card
    % ---
        testCard = pictureObject;

        % Position centered horizontally, 4 deg up
        testCard.position = [0 -4];

        % 5 deg height
        testCard.height = 5;

        % Start at trial start; End at response
        testCard.start.t = 0;
        testCard.end.response = true;
    % ---


    %Reference cards
    % ---
        % 1x4 array of picture objects
        refCards = pictureObject(4);
    for n = 1:4
        % Get file name from file names array using number, color, shape indexes
        refCards(n).fileName = fileNames(nn_refCards(n,1),nn_refCards(n,2),nn_refCards(n,3));

        % Get position from positions matrix
        refCards(n).position = refCardPositions(n,:);

        refCards(n).height = 5;

        refCards(n).start.t = 0;
        refCards(n).end.response = true;
    end
    % ---


    % Mouse click response
    % ---
    response = mouseClickObject;

    % Define 4 areas on screen that can be clicked.
    % Centers = reference card positions, sizes [width height] = reference card sizes -> effect of click on reference cards.
    % Possible response values = area #s = reference card #s.
    response.areaPositions = refCardPositions;
    response.areaSize = [3.55 5];

    % Score correct/incorrect
    response.scoreResponse = true;

    % Start at trial start
    response.start.t = 0;
    % By default mouseClick elements end when they record a response -> don't need to set .end
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


    % Trial object
    % ---
    trial = trialObject;

    % (All properties not left at default will be specific to trial -> nothing more to set in template here)
    % ---


    % Add template with name "trial"
    addTemplate(testCard, refCards, response, feedbacks, trial, "trial");
% ==========



% TASK TRIALS
% ==========

% Generate 64x3 matrix with rows = all possible combinations of 1-4 in each column.
% This can be done with tool setprod() in <PsychBench folder>/tools.
% -> 64x3 matrix with rows containing [number, color, shape] indexes to fileNames above.
nn_cards_test = setprod(1:4, 1:4, 1:4);
% Use MATLAB ismember() to remove the 4 reference card rows
tff = ismember(nn_cards_test, nn_refCards, "rows");
nn_cards_test(tff,:) = [];
% Randomize order of rows
nn_cards_test = randomOrder(nn_cards_test, 1);

% Define 3 match rule names
ruleNames = ["number" "color" "shape"];

% Generate 1x6 vector match rule indexes with each match rule appearing x2, all in random order.
    nn_rules_test = randomOrder(rep(1:3, 2));
% Constrain that match rule must change each time.
% There is probably an elegant way to do this but may as well do by brute force: just try random orders until get one that works...
while any(nn_rules_test(1:end-1) == nn_rules_test(2:end))
    disp('.')
    nn_rules_test = randomOrder(rep(1:3, 2));
end

% 60 trial definitions numbered 1-60: 6 rules x 10 trial definitions each, 60 test cards distributed across them
        i_testCard = 0;
for n_rule = nn_rules_test
    for n_rep = 1:10
        i_testCard = i_testCard+1;

        ruleName = ruleNames(n_rule);
        n_testCard = nn_cards_test(i_testCard,:);

        
        % Start with objects as set in template "trial" above
        [testCard, refCards, response, feedbacks, trial] = getTemplate("trial");
    
    
        % Test card
        % ---
            % File name
            testCard.fileName = fileNames(n_testCard(1),n_testCard(2),n_testCard(3));

            % Set some information to see in experiment results output
            testCard.info.num = n_testCard(1);
            testCard.info.n_color = n_testCard(2);
            testCard.info.n_shape = n_testCard(3);
            testCard.report = "fileName";
        % ---


        %Reference cards
        % ---
        for n = 1:4
            refCards(n).info.n = n;
            refCards(n).info.num = nn_refCards(n,1);
            refCards(n).info.n_color = nn_refCards(n,2);
            refCards(n).info.n_shape = nn_refCards(n,3);
            refCards(n).report = "fileName";
        end
        % ---


        % Mouse click response
        % ---
        % Get correct response value (reference card #) based on match rule for the trial
        if      n_rule == 1
            % Number of shapes -> reference card # for number = test card number
            response.correctResponse = find(nn_refCards(:,1) == n_testCard(1), 1);
        elseif  n_rule == 2
            % Color -> reference card # for color = test card color
            response.correctResponse = find(nn_refCards(:,2) == n_testCard(2), 1);
        else    % 3
            % Shape -> reference card # for shape = test card shape
            response.correctResponse = find(nn_refCards(:,3) == n_testCard(3), 1);
        end
        
        % See response, correct response, score, latency in results
        response.report = ["response" "correctResponse" "responseScore" "responseLatency"];
        % ---
        
        
        % Feedback
        % ---
        % (Nothing to add)
        % ---
        
        
        % Trial object
        % ---
        % Set some information to see in experiment results output at trial level, not specific to any one element object
        trial.info.n_rule = n_rule;
        trial.info.ruleName = ruleName;
        % ---


        % Add trial definition with default numbering (1, 2, 3, ...)
        addTrial(testCard, refCards, response, feedbacks, trial);
    end
end
% ==========



% TRAINING TRIALS
% ==========
% Same as task trial definitions except no experiment results output...

% Use 10 random test cards
nn_cards_test = setprod(1:4, 1:4, 1:4);
nn_cards_test = randomChoose(nn_cards_test, 10, 1);

% Use 1 random match rule
n_rule = randomChoose(1:3);

% 10 trial definitions numbered 101-110: 1 rule x 10 trial definitions, 10 test cards distributed across them
    i_testCard = 0;
for n_rep = 1:10
    i_testCard = i_testCard+1;

    n_testCard = nn_cards_test(i_testCard,:);


    [testCard, refCards, response, feedbacks, trial] = getTemplate("trial");


    % Test card
    % ---
    testCard.fileName = fileNames(n_testCard(1),n_testCard(2),n_testCard(3));
    % ---


    % Reference cards
    % ---
    % (Nothing to add)
    % ---


    % Mouse click response
    % ---
    if      n_rule == 1
        response.correctResponse = find(nn_refCards(:,1) == n_testCard(1), 1);
    elseif  n_rule == 2
        response.correctResponse = find(nn_refCards(:,2) == n_testCard(2), 1);
    else    % 3
        response.correctResponse = find(nn_refCards(:,3) == n_testCard(3), 1);
    end
    % ---


    % Feedback
    % ---
    % (Nothing to add)
    % ---


    % Trial object
    % ---
    % (Nothing to add)
    % ---


    % Add trial definition to group 100 (101, 102, 103, ...)
    addTrial(testCard, refCards, response, feedbacks, trial, 100);
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
    text.text = [
        "Use the mouse to match the card on the top with one of the four cards on the bottom. Each time we will tell you whether you were right or wrong. The correct match is based on ONE of the following rules:"
        ""
        "NUMBER of shapes (1, 2, 3, 4)"
        "COLOR (blue, green, red, yellow)"
        "SHAPE (circle, cross, star, triangle)"
        ""
        "We won't tell you which rule it is. The rule lasts for a few choices and you need to figure it out by trial and error across those choices. From time to time the rule will change and you need to figure it out again when that happens."
        "We'll start with a few choices to get the idea..."
        ];

    %Add trial definition with name "intro"
    addTrial(text, anyKey, "intro");
    % ---



    [text, anyKey] = getTemplate("keyMessage");

    text.text = "Okay! Remember the rule will change from time to time and you need to figure out the new rule when that happens. Press any key to start...";

    %Add trial definition with name "pause"
    addTrial(text, anyKey, "pause");
    % ---
% ==========



% Set trial list:
%
% - intro
% - 10 training trial definitions
% - pause
% - 60 task trial definitions
%
% We implemented order in the definitions above just because it seemed easier.
% No repetitions needed.
nn = {"intro" 101:110 "pause" 1:60};
setTrialList(nn)



% You can call "viewExperiment" and "viewExperiment -d" to visualize trials



[results, resultsMatrix] = runExperiment;