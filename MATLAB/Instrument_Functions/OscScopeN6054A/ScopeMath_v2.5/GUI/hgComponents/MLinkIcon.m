function h=MLinkIcon(parent)
%MLINKICON is a pan icon
%
% Usage:
%       h=MLinkIcon(parent)
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

previous_state = [];
menu_item      = [];

[cdataOn,mapOn] = imread([getbasedir, '/GUI/icons/','chain_linked.gif']); %a relative path!!!
ind = find(mapOn(:,1)+mapOn(:,2)+mapOn(:,3)==3);
mapOn(ind) = nan;
CDataOn = ind2rgb(cdataOn,mapOn);

[cdataOff,mapOff] = imread([getbasedir, '/GUI/icons/','chain_unlinked.gif']); %a relative path!!!
ind = find(mapOff(:,1)+mapOff(:,2)+mapOff(:,3)==3);
mapOff(ind) = nan;
CDataOff = ind2rgb(cdataOff,mapOff);
% Set all white (1,1,1) colors to be transparent (nan)

stProps.CData = CDataOff;
stProps.ToolTipString = 'Link/Unlink Axes';

handle = uitoggletool(parentHandle, stProps);


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
        set(handle, 'OnCallback', @onCallback);
        function onCallback(obj, event)
            menuItem.setUIProperties('Checked', 'on')
            set(handle, 'CData', CDataOn)
        end
        
        set(handle, 'OffCallback', @offCallback);
        function offCallback(obj, event)
            menuItem.setUIProperties('Checked', 'off')
            set(handle, 'CData', CDataOff)
        end
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