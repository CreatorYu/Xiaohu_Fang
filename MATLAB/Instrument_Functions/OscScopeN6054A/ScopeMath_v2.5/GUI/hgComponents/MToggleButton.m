function h=MToggleButton(parent,tag, strtext)
%MTOGGLEBUTTON Wrap a UICONTROL TOGGLEBUTTON
%
% Usage:
%       h=MToggleButton(fig,buttonText)
%
%       fig is the parent figure you whish to put the button
%       buttonText is the text you want on the button
%
%       h is the handle to the button
%
%

%   Copyright 1996-2012 The MathWorks, Inc.

% Not to self.  I need to understand what a handle is better.  When I think
% of a handle it could be either a HG handle or a pointer to an object.
% Using the same word for both will cause people to expect the same behavior
% from both. They do not behave the same so this is not good.

% Create the Button
h = MUIControl( parent,... 
                'togglebutton',... 
                tag, ...
                'String',strtext);

% Return a structure that gives people access to controling what we want on
% the object.

h.actionButtonPressed = @actionButtonPressed;
h.setTextString       = @setTextString;

    function actionButtonPressed( buttonDownFilename)
        h.setUIProperties('Callback',buttonDownFilename);
    end

    function setTextString(textString)
        h.setUIProperties('String', textString);
    end

end
