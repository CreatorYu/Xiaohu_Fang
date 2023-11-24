function h=MToolBar(iParent)
%MTOOLBAR Wrap a UITOOLBAR 
%
% Usage:
%       h=MToolBar(iParent, iTag)
%
%       iParent is the parent figure of menu bar
%       iTag is the tag of menu bar
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

handle = uitoolbar(...
                'Parent',parentHandle,...
                'Behavior',get(0,'defaultuitoolbarBehavior'));


% Return a structure that gives people access to controling what we want on
% the object.
h.handle            = handle;
h.setUIProperties   = @setUIProperties;
h.getUIProperties   = @getUIProperties;

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

end
