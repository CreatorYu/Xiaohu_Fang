function h=MButton(parent,tag, strtext)
%MTBUTTON Wrap a UICONTROL PUSHBUTTON
%
% Usage:
%       h=MButton(fig,buttonText)
%
%       fig is the parent figure you whish to put the button
%       buttonText is the text you want on the button
%
%       h is the handle to the button
%
%

%   Copyright 1996-2012 The MathWorks, Inc.

% Create the Button
h = MUIControl( parent,... 
                'pushbutton',... 
                tag, ...
                'String',strtext);
 
 buttonSize = h.getUIProperties('Position');
 h.setUIProperties('Position', [buttonSize(1:2), max(length(strtext)*1.5, buttonSize(3)), buttonSize(4)]);

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
