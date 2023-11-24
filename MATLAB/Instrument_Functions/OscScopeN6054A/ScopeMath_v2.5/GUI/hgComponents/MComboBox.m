function h=MComboBox(parent,tag, selectionList)
%MCOMBOBOX Wrap a UICONTROL POPUPMENU
%
% Usage:
%       h=MComboBox(fig,tag, strtext)
%
%       fig is the parent figure you whish to put the combo box
%       selectionList (array) is the list of selections
%
%       h is the handle to the combo box
%
%

%   Copyright 1996-2012 The MathWorks, Inc.

% Create the ComboBox
h = MUIControl( parent,... 
                'popupmenu',... 
                tag, ...
                'String',selectionList);

% Return a structure that gives people access to controling what we want on
% the object.
h.actionSelectionChanged = @actionSelectionChanged;
h.setSelectionList = @setSelectionList;

    function actionSelectionChanged(fname)
        h.setUIProperties('Callback',fname)
    end

    function setSelectionList(selectionList)
       h. setUIProperties('String', selectionList);
    end
end
