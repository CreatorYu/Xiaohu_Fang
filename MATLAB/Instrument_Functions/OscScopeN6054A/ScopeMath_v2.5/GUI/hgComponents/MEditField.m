function h=MEditField(parent,tag, strtext)
%MEDITFIELD Wrap a UICONTROL EDIT
%
% Usage:
%       h=MEditField(fig, tag, labelText)
%
%       fig is the parent figure you whish to put the button
%       buttonText is the text you want on the button
%
%       h is the handle to the editable text
%
%

%   Copyright 1996-2012 The MathWorks, Inc.

% Create the Button
h = MUIControl( parent,... 
                'edit',... 
                tag, ...
                'String',strtext);
            
h.setHorizontalAlignment = @setHorizontalAlignment;
h.setTextString       = @setTextString;

    function setHorizontalAlignment(align)
        h.setUIProperties('HorizontalAlignment', align);
    end

    function setTextString(textString)
        h.setUIProperties('String', [textString]);
    end

end
