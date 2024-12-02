%   HEADING
%   Heading in the pb menu (string).
%   For a visual stimulus element type leave at default [] = automatic based on core options below.
heading = [];


%   DESCRIPTION
%   Description in the pb menu (string).
desc = 'Point light or stick figure biological motion or mask';


%   CORE OPTIONS
%   (array of strings)
%   For a visual stimulus element type leave at default 'screen'.
with = {'screen'};


%   INPUT PROPERTIES (DURABLE TYPE ONLY)
%   What input properties will objects of the type have?
%   Input properties can be set by users when building experiments.
%   Only define properties specific to the type, not core properties.
%   (2-column cell array)
%
%   Name (string, first letter lower case)
%
%                                       Default value
%   --------------------------------------------
inputPropertyDefs = {
    'fileName'                          []
	'dataExpr'                          []
    'fps'                               []
    'nn_markers'                        []
    'nn_showMarkers'                    []
	'height'                            10
	'sizeMult'                          []
	'azimuth'                           0
	'elevation'                         0
	'azimuthVelocity'                   0
    'dotSize'                         	0.2
	'color'                             [1 1 1]
    'times'                             [0 inf]
	'showTimes'                         [0 inf]
    'maxNumLoops'                       inf
    'breakInterval'                     0
    'phase'                             0
	'speed'                             1
    'translate'                         false
    'translationVelocity'               0
	'stickWidth'                       	0
    'nn_stickMarkers'                  	[1 2; 2 3; 3 4; 4 5; 2 6; 6 7; 7 8; 2 9; 9 10; 10 11; 11 12; 9 13; 13 14; 14 15]
    'showMarkerNums'                    false
	'invert'                            false
	'scramble'                          false
    'scrambleHorz'                      false
    'scrambleVert'                      false
    'scrambleAreaSize'                  "f"
    'numScrambleDots'                   []
	'scramblePeriods'                   false
	'scramblePeriodDelta'               2
	'scramblePhases'                    false
    'scrambleSeed'                      []
    };


%   ADJUSTABLE PROPERTIES
%   What input properties can users allow subjects to adjust during experiments?
%   (2-column cell array)
%
%   Input property name (string)
%
%                                      	Dependent record property names (array of strings)
%   --------------------------------------------
adjustable = {
    'nn_eyes'                           []
    'rotation'                          []
    'colorMask'                         []
    'alpha'                             []
    'intensity'                         []
    'contrastMult'                      []
    };


%   DEPRECATED PROPERTIES (DURABLE TYPE ONLY)
%   Names of input properties that are no longer used but the type code can
%   still handle if users set them, e.g. renamed properties.
%   (array of strings)
inputPropertyDeprecatedNames = {
    'azimuthVel'
    'transVel'
    'translationVel'
    'repeat'
    'invertLocal'
    'invertGlobal'
    };


%   SLEEPABLE
%   (true/false)
%   Would object stimulus/functionality always stop and restart smoothly if
%   PsychBench stops and restarts calling the _runFrame script?
%   For a visual stimulus element type typically leave at default true.
isSleepable = true;