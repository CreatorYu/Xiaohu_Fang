function h=MProgressBar(parent,tag)
%MPROGRESSBAR shows what percentage of a calculation is complete,
%as the calculation proceeds.
%
% Usage:
%       h=MProgressBar(fig,tag)
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

screenSize = get(0,'ScreenSize');

axFontSize=get(0,'FactoryAxesFontSize');

pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');

width = 360 * pointsPerPixel;
height = 75 * pointsPerPixel;
pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];

vertMargin = 40;

axNorm=[.05 .3 .9 .2];
axPos=axNorm.*[pos(3:4),pos(3:4)] + [0 vertMargin 0 0];

handle = axes(...
            'Parent',parentHandle, ...
            'Tag', tag, ...
            'XLim',[0 100],...
            'YLim',[0 1],...
            'Box','on', ...
            'Units','Characters',...
            'FontSize', axFontSize,...
            'Position',axPos,...
            'XTickMode','manual',...
            'YTickMode','manual',...
            'XTick',[],...
            'YTick',[],...
            'XTickLabelMode','manual',...
            'XTickLabel',[],...
            'YTickLabelMode','manual',...
            'YTickLabel',[]);

% Return a structure that gives people access to controling what we want on
% the object.
h.handle            = handle;
h.setUIProperties   = @setUIProperties;
h.getUIProperties   = @getUIProperties;
h.setPosition       = @setPosition;
h.update            = @update;
h.updateText        = @updateText;

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

    % update progress - x must between 0-1
    function update(x)
        x = max(0,min(100*x,100));
        xpatch = [0 x x 0];
        ypatch = [0 0 1 1];
%         xline = [100 0 0 100 100];
%         yline = [0 0 1 1 0];
        
        p = patch(xpatch,ypatch,'b','EdgeColor','b','EraseMode','none');
%         l = line(xline,yline,'EraseMode','none');
%         set(l,'Color',get(gca,'XColor'));    
    end
end
