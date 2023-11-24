function h=MLabel(parent,tag, strtext)
%MLabel Wrap a UICONTROL TEXT
%
% Usage:
%       h=MLabel(fig, tag, labelText)
%
%       fig is the parent figure you whish to put the button
%       buttonText is the text you want on the button
%
%       h is the handle to the label
%
%

%   Copyright 1996-2012 The MathWorks, Inc.

% Create the Button
h = MUIControl( parent,... 
                'text',... 
                tag, ...
                'String', ...
                strtext, ...
                'HorizontalAlignment', ...
                'left');
            
h.setTextString       = @setTextString;
            
    function setTextString(textString)
        h.setUIProperties('String', textString);
    end


end
