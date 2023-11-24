function cOut = cellfilt(cIn, hPred)
% 
% CELLFILT Filter the elements of a cell array.
% 
% cOut = cellfilt(cIn, hPred) returns a new cell array cOut containing only 
%  the elements of cIn for which hPred is true.  hPred is a function handle
%  of one argument which returns a boolean.
% 
% See also CELLAPPLY, CELLMAP, CELLMAPFILT

%   Copyright 1996-2012 The MathWorks, Inc.

cOut = cell(0);

for el = cIn
    if (hPred(el{1}))
        cOut = [cOut el];
    end
end
