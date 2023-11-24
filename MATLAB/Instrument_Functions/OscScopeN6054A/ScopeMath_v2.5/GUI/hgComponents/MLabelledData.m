function h = MLabelledData(iData, iDataLabel )
% MLABELLEDDATA creates a data with label associates with it.
%
%      H = MLabelledData returns a structure contains data and its label
%      iData is a vector or matrix
%      iDataLabel is the label for iData

%   Copyright 1996-2012 The MathWorks, Inc.

    h = struct('data', iData,...
              'label', iDataLabel);
end