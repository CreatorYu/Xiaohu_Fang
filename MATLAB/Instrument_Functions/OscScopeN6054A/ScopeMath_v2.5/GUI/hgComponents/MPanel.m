function h=MPanel(parent,tag)
%MPANEL Wrap a UIPANEL 
%
% Usage:
%       h=MPanel(fig,tag)
%
%       fig is the parent figure you wish to put the panel
%       tag is the name of the panel
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

handle=uipanel( 'Parent',parentHandle,...
                'Tag',tag,...
                'Units','characters',...                
                'Behavior',get(0,'defaultuipanelBehavior'));

% Return a structure that gives people access to controling what we want on
% the object.
h.handle            = handle;
h.setUIProperties   = @setUIProperties;
h.getUIProperties   = @getUIProperties;
h.setPosition       = @setPosition;
h.setBackgroundColor= @setBackgroundColor;
h.setForegroundColor = @setForegroundColor;
h.setTitle          = @setTitle;
h.setStatus         = @setStatus;
h.setError          = @setError;
h.updateTime        = @updateTime;
h.isRunning         = parent.isRunning;

% Define variabls so they stays around. (Basically this is a way to have
% internal properties that the inner methods can access and will stay in
% memory.  (just like an objects private properties)

    function setUIProperties(varargin)
        set(handle,varargin{:});
    end

    function varargout = getUIProperties(varargin)
        varargout{1:nargout} = get(handle,varargin{:});
    end

    % Enable the user to change the position throuht the command line.
    function varargout = setPosition(pos)
        if exist('pos','var')
            set(handle,'Position',pos);
            varargout = [];
        else
            varargout{1:nargout}=get(handle,'Position');
        end;
    end
    function mydelete()
        delete(handle);
    end

    function setBackgroundColor(color)
        set(handle,'BackgroundColor',color);
    end

    function setForegroundColor(color)
        set(handle,'ForegroundColor',color);
    end

    function setTitle(title)
        set(handle,'Title',title);
    end

% if there is a handler, use it, otherwise use Warn and Error
    function setStatus(sStatus)
        if (isstruct(parent))
            parent.setStatus(sStatus);
        else
            warning(sStatus);
        end
    end

    function setError(sError)
        if (isstruct(parent))
            parent.setError(sError);
        else
            error(sError);
        end
    end

    function updateTime(etime)
        if (isstruct(parent))
            parent.updateTime(etime);
        else
            return; %noop in the default state for updateTime
        end
    end

    
end
