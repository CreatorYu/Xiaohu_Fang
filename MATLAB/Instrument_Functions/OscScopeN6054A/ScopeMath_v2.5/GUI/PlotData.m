function h = PlotData(iXData, iYData, iZData)
% PLOTDATA creates XYZ plot data.
%
%      H = PlotData returns a structure contains plot data
%      where X1, Y1, Z1 are MLabelledData, plots one or more lines in
%      three-dimensional space through the points whose coordinates are 
%      the elements of X1, Y1, and Z1. 
%
%  See also
%       MLabelledData

%   Copyright 1996-2012 The MathWorks, Inc.

     h = struct('XData', iXData,...
                'YData', iYData,...
                'ZData', iZData);
end