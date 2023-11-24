function h=MToolBarItem(parent, itemName)
%MTOOLBARITEM is abstract function for toolbar item such as 'zoom in, zoom out'ect. 
%
% Usage:
%       h=MToolBarItem(parent)
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

handle=MIconFactory(parent, itemName);

previous_state = [];
menu_item      = [];


% Return a structure that gives people access to controling what we want on
% the object.
h.handle            = handle;
h.setUIProperties   = @setUIProperties;
h.getUIProperties   = @getUIProperties;
h.addSeparator      = @addSeparator;
h.actionItemSelected     = @actionItemSelected;
h.linkMenu          = @linkMenu;
h.Enable            = @Enable;
h.Disable           = @Disable;
h.TurnOff           = @TurnOff;

% Define variables so they stay around. (Basically this is a way to have
% internal properties that the inner methods can access and will stay in
% memory.  (just like an objects private properties)

    function setUIProperties(varargin)
        set(handle,varargin{:});
    end

    function varargout = getUIProperties(varargin)
        varargout{1:nargout} = get(handle,varargin{:});
    end

    function addSeparator
        set(handle, 'Separator', 'on');
    end

    function actionItemSelected(actionFileName)
        set(handle, 'ClickedCallback', actionFileName);
    end

    function linkMenu(menuItem)
        menu_item = menuItem; %store the item
        set(handle, 'OnCallback', ...
            @(varargin) menuItem.setUIProperties('Checked', 'on'));
        set(handle, 'OffCallback', ...
            @(varargin) menuItem.setUIProperties('Checked', 'off'));
    end

    function TurnOff
        previous_state = h.getUIProperties('State');
        if (~strcmp('off', previous_state))
            h.setUIProperties('State', 'off');
            hFun = h.getUIProperties('ClickedCallback');
            hFun(handle);
        end
    end

    function Enable
        if isempty(previous_state)
            previous_state = 'off';
        end
        if strcmp('on', previous_state)
            h.setUIProperties('State', previous_state);
            hFun = h.getUIProperties('ClickedCallback');
            hFun(handle);
        end
        h.setUIProperties('Enable', 'on');
        menu_item.setUIProperties('Enable', 'on');
    end

    function Disable
        h.setUIProperties('Enable', 'off');
        menu_item.setUIProperties('Enable', 'off');
    end

end
