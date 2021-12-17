%   FRAMEWORKS
%   Which frameworks does the class work in? (string or array of strings)
%   One or both of 'ptb', 'mgl'.
frameworks = {'ptb' 'mgl'};


%   CORE FUNCTIONALITY OPTIONS
%   (array of strings)
%   e.g. 'screen', 'audio', 'responseRecorder', etc. See Programming Manual.
with = [];


%   INPUT PROPERTY DEFINITIONS (DURABLE CLASS ONLY)
%   What input properties will objects of the class have?
%   Input properties can be set by users when building experiments.
%   Only define properties specific to the class, not core properties.
%   (2-column cell array)
%
%   Name (string, first letter lower case)
%
%                                       Default value
%   --------------------------------------------
inputPropertyDefs = {
    'n_device'                      	[]
    'nn_listenKeys'                 	[]
    'numInputs'                         1
    };


%   ADJUSTABLE PROPERTIES
%   What input properties can users let subjects adjust during experiments?
%   (2-column cell array)
%
%   Input property name (string)
%
%                                      	Dependent record property names (array of strings)
%   --------------------------------------------
adjustable = {
    };


%   SLEEPABLE
%   (true/false)
%   Can the stimulus/functionality be stopped and restarted just by stopping and
%   restarting calling the runFrame class script?
isSleepable = true;


%   DESCRIPTION
%   Description in the PsychBench menu (string).
desc = 'Waits for one or more key press signals, then registers a trigger. Typically use to sync with an external device like a scanner.';


%   HEADING
%   Heading in the PsychBench menu (string). [] = automatic.
heading = [];