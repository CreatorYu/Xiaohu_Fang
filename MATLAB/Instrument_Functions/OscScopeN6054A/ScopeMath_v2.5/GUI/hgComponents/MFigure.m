function h=MFigure(docked)
%MFIGURE Wrap a Figure with default behavior for GUIs
%
% Usage:
%       h=MFigure(docked)
%
%       docked is a boolean that puts the figure window docked or not on
%       creation.
%
%       h is a structure that's fields act like methods on an object.
%

%   Copyright 1996-2012 The MathWorks, Inc.

if docked
    dockControlString = 'on';
    windowStyleString = 'docked';
else
    dockControlString = 'off';
    windowStyleString = 'normal';
end;

handle = figure(...
            'Units','characters',...
            'Color',[0.831372549019608 0.815686274509804 0.784313725490196],...
            'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
            'IntegerHandle','off',...
            'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
            'MenuBar','none',...
            'Toolbar','none',...
            'NumberTitle','off',...
            'PaperPosition',get(0,'defaultfigurePaperPosition'),...
            'Resize','on',...
            'Tag','figure1',...
            'UserData',[],...
            'Behavior',get(0,'defaultfigureBehavior'),...
            'DockControls', dockControlString,...
            'WindowStyle', windowStyleString);

h.delete            = @mydelete;
h.setUIProperties   = @setUIProperties;
h.getUIProperties   = @getUIProperties;
h.handle            = handle;
h.setTitle          = @setTitle;
h.setPosition       = @setPosition;
h.setColor          = @setColor;
h.setStatusHandler  = @setStatusHandler;
h.setErrorHandler   = @setErrorHandler;
h.setETimeHandler   = @setETimeHandler;
h.setStatus         = @setStatus;
h.setError          = @setError;
h.updateTime        = @updateTime; %noop for the default time update;
h.isRunning         = @isFigRunning;


ErrorHandler  = [];
StatusHandler = [];
ETimeHandler  = [];

    %% set UI properties. All HG properties can be set thought this method
    function setUIProperties(varargin)
        set(handle,varargin{:});
    end
    
    %% get UI properties. All HG properties can be get thought this method
    function varargout = getUIProperties(varargin)
        varargout{1:nargout} = get(handle,varargin{:});
    end

    %% set position
    function varargout = setPosition(pos)
        if exist('pos','var')
            set(h.handle,'Position',pos);
            varargout = [];
        else
            varargout{1:nargout}=get(h.handle,'Position');
        end;
    end

    %% delete figure 
    function mydelete()
        delete(h.handle);
    end

    %% set color
    function setColor(color)
        set(h.handle,'Color',color);
    end

    %% set figure's title
    function setTitle(title)
        set(h.handle,'Name',title);
    end

    %% set status handler
    function setStatusHandler(statusHandler)
        StatusHandler = statusHandler;
    end

    %% set errror handler
    function setErrorHandler(errorHandler)
        ErrorHandler = errorHandler;
    end

    %% set elaspse time handler TODO: this is not a generic method
    function setETimeHandler(etimeHandler)
        ETimeHandler = etimeHandler;
    end

    % if there is a handler, use it, otherwise use Warn and Error
    function setStatus(sStatus)
        if (isempty(StatusHandler))
            warning(sStatus);
        else
            StatusHandler.setStatus(sStatus);
        end
    end

    % When error happens, pass it to error handler
    function setError(sError)
        if (isempty(ErrorHandler))
            error(sError);
        else
            ErrorHandler.setError(sError);
        end
    end

    %% update elasper time
    function updateTime(eTime)
        if (isempty(ETimeHandler))
            return
        else
            ETimeHandler.updateTime(eTime);
        end
    end

    %% get the main GUI running state
    function bState = isFigRunning
        bState = false;
    end

end
