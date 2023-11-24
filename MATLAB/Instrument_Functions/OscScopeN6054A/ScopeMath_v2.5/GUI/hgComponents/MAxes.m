function h=MAxes(parent,tag)
%MAXES Wrap a AXES 
%
% Usage:
%       h=MAxes(fig,tag)
%
%       fig is the parent figure you whish to put the button
%       tag is the tag of axes
%
%       h is a structure that's fields act like methods on an object.
%

%   Copyright 1996-2012 The MathWorks, Inc.

% Create the MAXES
if isstruct(parent)
    parentHandle = parent.handle;
else
    parentHandle = parent; 
end;

defaultLabelFontSize = 8;
handle = axes(...
            'Parent',parentHandle, ...
            'Units', 'characters', ...
            'NextPlot', 'replacechildren', ...
            'FontSize', defaultLabelFontSize, ...
            'Tag', tag);
        
% set(get(handle, 'XLabel'), 'FontSize', defaultLabelFontSize);
% set(get(handle, 'YLabel'), 'FontSize', defaultLabelFontSize);
% set(get(handle, 'ZLabel'), 'FontSize', defaultLabelFontSize);

% Return a structure that gives people access to controling what we want on
% the object.
h.handle            = handle;
h.setUIProperties   = @setUIProperties;
h.getUIProperties   = @getUIProperties;
h.setPosition       = @setPosition;
h.setBackgroundColor = @setBackgroundColor;
h.setForegroundColor = @setForegroundColor;
h.setEnable          = @setEnable;

   %% set UI properties. 
    function setUIProperties(varargin)
        set(handle,varargin{:});
    end

    function varargout = getUIProperties(varargin)
        varargout{1:nargout} = get(handle,varargin{:});
    end

    % Enable the user to change the position through the command line.
    function varargout = setPosition(pos)
        if exist('pos','var')
            set(handle,'Position',pos);
            varargout = [];
        else
            varargout{1:nargout}=get(handle,'Position');
        end;
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
end
