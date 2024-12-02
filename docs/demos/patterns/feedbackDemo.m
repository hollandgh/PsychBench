% FEEDBACK DEMO
% Coding method
% See www.psychbench.org/docs#demos for visual method
% --------------------------------------------------


% Each trial shows a prompt "<" or ">" and the subject responds by left/right
% arrow key press with the direction. There is a time limit of 5 sec for
% response. We score response correct/incorrect (true/false), including
% incorrect if no response. Then green "YES" or red "NO" feedback shows for 1
% sec. We run 4 repetitions of each left/right trial for a total of 8 trials,
% all in random order.



% Mark start of experiment script
newExperiment


% 2 trial definitions: 2 directions
for n_direction = [1 2]
    % PROMPT TEXT
    % ---
    prompt = textObject;
    
    % Text to show = "<" or ">" depending on direction for trial
    if n_direction == 1
        prompt.text = "<";
    else
        prompt.text = ">";
    end
    
    % Start at trial start.
    % End when response recorded or at 5 sec duration.
    prompt.start.t = 0;
    prompt.end(1).response = true;
    prompt.end(2).duration = 5;
    % ---

    
    % RESPONSE HANDLER
    % ---
    recorder = keyPressObject;

    % Properties below are properties all response handler elements have unless
    % otherwose noted.

    % Names of keys to listen to.
    % You can get these key names using showKey() at the MATLAB command line.
    % Response value recorded in record property .response will be number of the name in this list, i.e. 1 = left, 2 = right.
    % This property is specific to element type "keyPress".
    recorder.listenKeyNames = ["left" "right"];

    % Turn on response scoring.
    % By default response score = true/false: isequaln(response, correct response).
    % Response values 1 = left, 2 = right conveniently match our loop variable "n_direction", so we can just set correct response = that.
    recorder.scoreResponse = true;
    recorder.correctResponse = n_direction;
    
    % Record "no response" as a response = NaN.
    % Do this so it will be scored = false, so incorrect feedback will run on no response.
    recorder.recordDefaultResponse = true;    

    % Set options for if we run the experiment in auto response mode:
    % Response values generated randomly will be 1/2 (corresponding to left/right in the key names list above).
    % Response latency will be random between 0.5-6 sec.
    recorder.autoResponse = [1 2];
    recorder.autoResponseLatency = [0.5 6];
    
    % Start at trial start.
    % By default will end when records a response.
    % Also end at 5 sec duration for time limit.
    recorder.start.t = 0;
    recorder.end.duration = 5;

    % Report all response information.
    % Properties all response handler elements have.
    recorder.report = ["response" "correctResponse" "responseScore" "responseTime" "responseLatency" "d_responseTime"];
    % ---

    
    % FEEDBACK TEXTS
    % ---
    feedbacks = textObject(2);

    % Green "YES" starts at response.
    % Add field .and and set to string: start only if responseScore = true.
    feedbacks(1).text = "YES";
    feedbacks(1).color = [0 1 0];
    feedbacks(1).start.response = true;
    feedbacks(1).start.and = "responseScore == true";   % (just "responseScore" would be equivalent to this expression)

    % Red "NO" starts at response.
    % Add field .and and set to string: start only if responseScore = false.
    feedbacks(2).text = "NO";
    feedbacks(2).color = [1 0 0];
    feedbacks(2).start.response = true;
    feedbacks(2).start.and = "responseScore == false";  % (just "~responseScore" would be equivalent to this expression)

    % Show for 1 sec
    for n = 1:2
        feedbacks(n).end.duration = 1;
    end
    % ---


    % Add trial definition with default numbering (1, 2, 3, ...)
    addTrial(prompt, recorder, feedbacks);
end


% Trial list: run 4 of each trial definition in random order
nn = randomOrder(rep([1 2], 4));
setTrialList(nn)


% Simulate a subject run
% [results, resultsMatrix] = runExperiment("-a");

% Run
[results, resultsMatrix] = runExperiment;