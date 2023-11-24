function cellapply(cIn, hFunc)
%% 
% CELLMAP Apply a function to every element of a cell array
% returning nothing. 
%
% 
% cellapply(cIn, hFunc) applies the single argument function hFunc to every
%  element of cell array cIn.
% 
% See also CELLMAP, CELLMAPFILT, CELLFILT

%cOut = cell(size(cIn));

%   Copyright 1996-2012 The MathWorks, Inc.

for n = 1:length(cIn)
    hFunc(cIn{n});
end
