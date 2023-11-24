function h=MDataCursorIcon(parent)
%MDATACURSORICON is a Data cursor icon 
%
% Usage:
%       h=MDataCursorIcon(parent)
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

    h = MToolBarItem(parentHandle, 'Exploration.DataCursor');

end