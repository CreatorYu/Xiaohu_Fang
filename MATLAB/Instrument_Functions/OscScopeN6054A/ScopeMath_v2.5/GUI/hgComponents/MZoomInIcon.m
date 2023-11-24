function h=MZoomInIcon(parent)
%MZOOMINICON is a zoom in icon 
%
% Usage:
%       h=MZoomInIcon(parent)
%
%       parent is the toolbar you wish to put the icon
%
%       h is a structure that's fields act like methods on an object.
%

%   Copyright 1996-2012 The MathWorks, Inc.

% Create the UIPANEL

    if isstruct(parent)
        parentHandle = parent.handle;
    else
        parentHandle = parent; 
    end;

    h = MToolBarItem(parentHandle, 'Exploration.ZoomIn');

end