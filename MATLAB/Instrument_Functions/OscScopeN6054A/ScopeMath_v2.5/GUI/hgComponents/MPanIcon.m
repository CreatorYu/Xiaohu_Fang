function h=MPanIcon(parent)
%MPANICON is a pan icon 
%
% Usage:
%       h=MPanIcon(parent)
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

    h = MToolBarItem(parentHandle, 'Exploration.Pan');

end