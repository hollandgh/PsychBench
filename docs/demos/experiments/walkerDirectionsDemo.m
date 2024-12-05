% WALKER DIRECTIONS EXPERIMENT DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Each trial shows a 15-dot point light human walking display at a height of 10
% deg, rotated to face either left or right. The walker is in a mask of dots
% taken from the same motion data. Number of mask dots is randomized between
% 15-155. Mask dot mean positions are randomized within a cylinder with width 12
% deg, and dot phases (time offsets in the walking cycle) are randomized. Each
% mask dot is rotated left or right such that total numbers of dots in the mask
% + walker display in each direction are equal (e.g. 20 mask dots left + 15
% walker dots left + 35 mask dots right). Within each direction, mask dots are
% taken evenly from the motion data with the remainders taken randomly.
% 
% The subject responds by left/right arrow key press with whether the walker is
% facing left or right.
% 
% Two factors: walker direction (1/2 = left/right), number of mask dots. We run
% 40 left trials + 40 right trials = 80 trials total, all in random order. The
% experiment begins with 6 training trials showing just the walker, and another 
% 6 training trials showing the walker with a minimal mask of 15 dots.



newExperiment



% TASK TRIALS
% 80 trial definitions numbered 1-80: 2 directions x 40 random numbers of dots each.
% * Note difference from visual method: In coding method need a different trial
% definition for each random number of mask dots because the objects input to
% addTrial() have set values. The randomNum() expression is already evaluated,
% so cannot be re-evaluated by repeat running a trial definition.
% ==========
for d = [1 2]
    for n_rep = 1:40
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
            
            % Random number of dots across both masks between 15-155.
            % Mask 1 (same direction)     = random number between 0-70
            % Mask 2 (opposite direction) = same number + 15
            masks(1).numScrambleDots = randomNum(0, 70, [], "-i");
            masks(2).numScrambleDots = masks(1).numScrambleDots+15;
                        
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
        
        % See response, score, latency in results
        response.report = ["response" "responseScore" "responseLatency"];
        % ---


        % Add trial definition with default numbering (1, 2, 3, ...)
        addTrial(walker, masks, response);
    end
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
% - task trial definitions in random order
%
% Random order just to randomize left/right
nn = {randomOrder(rep(101:102, 3)) "pause" randomOrder(rep(201:202, 3)) "pause" randomOrder(1:80)};
setTrialList(nn)



% You can call "viewExperiment" and "viewExperiment -d" to visualize trials



[results, resultsMatrix] = runExperiment;