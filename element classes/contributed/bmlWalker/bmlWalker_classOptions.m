%   FRAMEWORKS
%   Which frameworks does the class work in? (string or array of strings)
%   One or both of 'ptb', 'mgl'.
frameworks = {'ptb' 'mgl'};


%   CORE FUNCTIONALITY OPTIONS
%   (array of strings)
%   e.g. 'screen', 'audio', 'responseRecorder', etc. See Programming Manual.
with = 'screen';


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
	'dataExpr'                          []
    'fps'                               120
	'height'                            8
	'sizeMult'                          []
	'azimuth'                           0
	'elevation'                         0
	'azimuthVel'                        0
	'speed'                             1
    'transVelMult'                    	0
    'transVelOffset'                  	0
    'dotSize'                         	0.19
    'nn_showMarkers'                    []
	'stickWidth'                       	0
    'nn_stickMarkers'                  	[1 2; 2 3; 3 4; 4 5; 2 6; 6 7; 7 8; 2 9; 9 10; 10 11; 11 12; 9 13; 13 14; 14 15]
	'color'                             [1 1 1]
	'repeat'                            true
    'phase'                             0
	'invert'                            false
    'invertLocal'                       false
    'invertGlobal'                      false
	'scramble'                          false
    'scrambleHorz'                      false
    'scrambleVert'                      false
    'scrambleAreaSize'                  "f"
    'numScrambleDots'                   []
	'scramblePeriods'                   false
	'scramblePeriodDelta'               2
	'scramblePhases'                    false
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
desc = 'Point light or stick figure biological motion or mask.';


%   HEADING
%   Heading in the PsychBench menu (string). [] = automatic.
heading = [];