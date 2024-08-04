% 
% GENERAL
%
%
% Little tools mostly useful for error checking input property values in _open
% element type scripts.
% 
% 
% <a href="matlab:disp([10 10 10 '------------']), help isOneNum">isOneNum</a>      - true if numeric scalar
% <a href="matlab:disp([10 10 10 '------------']), help isRowNum">isRowNum</a>      - true if numeric row vector
% <a href="matlab:disp([10 10 10 '------------']), help isOneString">isOneString</a>   - true if string scalar, e.g. "hello"
% <a href="matlab:disp([10 10 10 '------------']), help isRowChar">isRowChar</a>     - true if char row array, e.g. 'hello'
% <a href="matlab:disp([10 10 10 '------------']), help is01">is01</a>          - true if true/false or 1/0 scalar
% <a href="matlab:disp([10 10 10 '------------']), help is01s">is01s</a>         - true if true/false or 1/0 array
% <a href="matlab:disp([10 10 10 '------------']), help isRgb1">isRgb1</a>        - true if 1x3 vector of numbers between 0-1
% <a href="matlab:disp([10 10 10 '------------']), help isRgba1">isRgba1</a>       - true if 1x3 or 1x4 vector of numbers between 0-1
% 
% <a href="matlab:disp([10 10 10 '------------']), help isIntegerVal">isIntegerVal</a>  - true where values are integer (not necessarily integer data type)
% <a href="matlab:disp([10 10 10 '------------']), help isUpper">isUpper</a>       - true where characters are upper case
% <a href="matlab:disp([10 10 10 '------------']), help isLower">isLower</a>       - true where characters are lower case
% <a href="matlab:disp([10 10 10 '------------']), help isUnique">isUnique</a>      - true where values are unique in numeric / char '' / string array [""]
% <a href="matlab:disp([10 10 10 '------------']), help isUnique_str">isUnique_str</a>  - true where strings are unique in string array [""] / cell array of strings {''}
% <a href="matlab:disp([10 10 10 '------------']), help isUnique_stri">isUnique_stri</a> - true where strings are unique in string array [""] / cell array of strings {''}, case-insensitive
% <a href="matlab:disp([10 10 10 '------------']), help isemptycell">isemptycell</a>   - true where cells in cell array are empty
% 
% <a href="matlab:disp([10 10 10 '------------']), help any2">any2</a>          - true if any single value in an array of any size = true or ~= 0
% <a href="matlab:disp([10 10 10 '------------']), help all2">all2</a>          - true if all single value in an array of any size = true or ~= 0
% 
% <a href="matlab:disp([10 10 10 '------------']), help row">row</a>           - reshape an array to row
% <a href="matlab:disp([10 10 10 '------------']), help column">column</a>        - reshape an array to column
% 
% <a href="matlab:disp([10 10 10 '------------']), help roundUp">roundUp</a>       - round numbers up
% <a href="matlab:disp([10 10 10 '------------']), help roundDown">roundDown</a>     - round numbers down
% 
% <a href="matlab:disp([10 10 10 '------------']), help joinLines">joinLines</a>     - join array of strings into one string with <new line> separating them
% <a href="matlab:disp([10 10 10 '------------']), help joinList">joinList</a>      - join array of strings into one string with ', ' separating them
% 
% <a href="matlab:disp([10 10 10 '------------']), help val2char">val2char</a>      - convert any value to string '' for display
% 
% <a href="matlab:disp([10 10 10 '------------']), help var2char">var2char</a>      - if string "x" then convert to char 'x' else leave unchanged
% <a href="matlab:disp([10 10 10 '------------']), help var2string">var2string</a>    - if char 'x' then convert to string "x" else leave unchanged
% 
% <a href="matlab:disp([10 10 10 '------------']), help structish">structish</a>     - make a struct array with specified size and fields, all fields empty
% 
% <a href="matlab:disp([10 10 10 '------------']), help whichFile">whichFile</a>     - like MATLAB which() except general for files on search path, not specific to workspace
% <a href="matlab:disp([10 10 10 '------------']), help whereFile">whereFile</a>     - get full path of file or folder
%
% <a href="matlab:disp([10 10 10 '------------']), help warningOnce">warningOnce</a>   - display warning only once