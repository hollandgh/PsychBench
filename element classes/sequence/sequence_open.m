%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
%-c: cell array of strings even for one.
this.elementExprs = var2Char(this.elementExprs, '-c');
%---


elementExprs = this.elementExprs;
intervals = this.intervals;
repeat = this.repeat;


if numel(intervals) == 1
    intervals = repmat(intervals, 1, numel(elementExprs));
end
    %When each child element should end relative to sequence start, not counting repeat.
    %Prepend one dummy time for the algo in runFrame.
    tt = [0 cumsum(intervals)];

ii_elements = element_getElementIndex(elementExprs);

if ii_elements(1) > 0
    %Cue first child element to start when sequence starts
    this = element_cueStartElement(this, ii_elements(1));
end

n_element_prev = 1;


this.ii_elements = ii_elements;
this.tt = tt;
this.n_element_prev = n_element_prev;