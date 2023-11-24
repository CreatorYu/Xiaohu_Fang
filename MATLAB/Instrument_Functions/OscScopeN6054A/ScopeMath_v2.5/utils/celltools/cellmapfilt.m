function cOut = cellmapfilt(cIn, hFunc, hFilter)
%% 
% CELLMAPFILT Apply a function and filter to every element of a cell array.
% 
% cOut = cellmapfilt(cIn, hFunc, hFilter) applies the single argument
% function hFunc to every element of cell array cIn and returns every
% result for which the single argument function hFilter returns true in the
% new cell array cOut.  
% 
% See also CELLAPPLY, CELLMAP, CELLFILT

%   Copyright 1996-2012 The MathWorks, Inc.

cOut = cell(0);

for n = 1:length(cIn)
    val = hFunc(cIn{n});
    if (hFilter(val))
        cOut{end+1} = val;
    end %if
end
