function h=MUIControl(parent,style,tag,varargin)
%MUICONTROL Wrap a UICONTROL 
%
% Usage:
%       h=muicontrol(fig,controlType)
%
%       fig is the parent figure you whish to put the button
%       controlType is the type of control to create
%           [ {pushbutton} | togglebutton | radiobutton | checkbox | edit |
%           text | slider | frame | listbox | popupmenu ]
%
%       h is a structure that's fields act like methods on an object.
%
%   This is an example of how we can use nested functions to create
%   something that acts like an object.  The greate thing about this is
%   that the method calls are fast and all defined on creation.  Using this
%   method to create an object also enforces good object oriantated design 
%   by not allowing access to public properties.  If you want a user to get 
%   access to data inside, you need to write get/set methods. There is no 
%   way to just give people access to the data that is inside.  

%   Copyright 1996-2012 The MathWorks, Inc.

% Create the UICONTROL
if isstruct(parent)
    parentHandle = parent.handle;
else
    parentHandle = parent; 
end;

handle=uicontrol('Style',style,...
                'parent',parentHandle,...
                'tag', tag,...
                'Units','characters',...
                varargin{:});

% Return a structure that gives people access to controling what we want on
% the object.

h.setUIProperties   = @setUIProperties;
h.getUIProperties   = @getUIProperties;
h.setPosition       = @setPosition;
h.setBackgroundColor     = @setBackgroundColor;
h.setForegroundColor = @setForegroundColor;
h.setEnable          = @setEnable;
h.delete             = @mydelete;

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

    function setEnable(isEnable)
        set(handle,'Enable',isEnable);
    end

   
end
