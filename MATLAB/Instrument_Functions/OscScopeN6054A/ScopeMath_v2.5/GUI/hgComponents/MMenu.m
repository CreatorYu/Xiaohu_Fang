function h=MMenu(iParent,iTag,iLabel)
%MMENU Wrap a UIMENU 
%
% Usage:
%       h=MMenu(iParent, iTag, iLabel)
%
%       iParent is the parent figure of menu bar
%       iTag is the tag of menu bar
%       iLabel is the display string of menu item
%
%       h is a structure that's fields act like methods on an object.
%

%   Copyright 1996-2012 The MathWorks, Inc.

% Create the MAXES
if isstruct(iParent)
    parentHandle = iParent.handle;
else
    parentHandle = iParent; 
end;

handle = uimenu(...
                'Parent',parentHandle,...
                'Label',iLabel,...
                'Tag',iTag,...
                'Behavior',get(0,'defaultuimenuBehavior'));


% Return a structure that gives people access to controling what we want on
% the object.
h.handle            = handle;
h.setUIProperties   = @setUIProperties;
h.getUIProperties   = @getUIProperties;
h.setBackgroundColor= @setBackgroundColor;
h.setForegroundColor = @setForegroundColor;
h.setEnable          = @setEnable;
h.actionItemSelected = @actionItemSelected;

    % Define variabls so they stays around. (Basically this is a way to have
    % internal properties that the inner methods can access and will stay in
    % memory.  (just like an objects private properties)

    function setUIProperties(varargin)
        set(handle,varargin{:});
    end

    function varargout = getUIProperties(varargin)
        varargout{1:nargout} = get(handle,varargin{:});
    end

    % delete object
    function mydelete()
        delete(handle);
    end

    % convienient method. set backgroundcolor.
    function setBackgroundColor(color)
        set(handle,'BackgroundColor',color);
    end

    function setForegroundColor(color)
        set(handle,'ForegroundColor',color);
    end

    function setEnable(isEnable)
        set(handle,'Enable',isEnable);
    end

    function actionItemSelected( itemSelectedFileName)
        h.setUIProperties('Callback',itemSelectedFileName);
    end

end
