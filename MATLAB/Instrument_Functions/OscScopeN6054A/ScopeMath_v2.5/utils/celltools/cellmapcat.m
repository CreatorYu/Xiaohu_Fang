function cOut = cellmapcat(cIn, hFunc)
%% 
% Name: CELLMAPCAT
% Author: Todd Atkins (tatkins@mathworks.com)
% Date: 1-3-2005
% 
% CELLMAPCAT applies the single argument function fHandle to every element
% of cell array cIn returning the result in cOut by concatenating the 
% outputs along the way thus fHandle may return a cell array of outputs.
% 
% See also CELLMAP

%   Copyright 1996-2012 The MathWorks, Inc.

cOut = cell(0);

for n = 1:length(cIn)
    hFuncOut = hFunc(cIn{n});
    for o = 1:length(hFuncOut)
        cOut{end+1} = hFuncOut{o};
    end
end
