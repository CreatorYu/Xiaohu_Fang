function cOut = cellmap(cIn, hFunc)
%% 
% CELLMAP Apply a function to every element of a cell array.
% 
% cOut = cellmap(cIn, hFunc) applies the single argument function hFunc to 
% every element of the cell array cIn returning the result in a new cell 
% array cOut
% 
% See also CELLAPPLY, CELLMAPFILT, CELLFILT

%   Copyright 1996-2012 The MathWorks, Inc.

cOut = cell(size(cIn));

for n = 1:length(cIn)
    cOut{n} = hFunc(cIn{n});
end
