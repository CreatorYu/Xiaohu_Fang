function h=MPlot(iParent, iPlotData)
%MPLOT creates a plot plot
%
% Usage:
%       h=MPlot(fig)
%
%       fig is the parent figure you whish to put the Waterfall plot
%
%       h is a structure that's fields act like methods on an object.
%

%   Copyright 1996-2012 The MathWorks, Inc.

if ishandle(iParent)
    parenthandle = iParent;
else
    parenthandle = iParent.handle;
end

% Define the interface to the waterfall plot
h.update    = @update;
h.visible   = @myvisible;
h.clear     = @myclear;
h.setXLabel = @setXLabel;
h.setYLabel = @setYLabel;
h.delete    = @mydelete;
h.view      = @myview;

% Define the Axis for the plot (We could change this so that we don't use
% subplot if the subplot method of position does not work for us.  This was
% just a quick and dirty way to give some positions.
% hAxis = subplot(position(1),position(2),position(3),'parent',parent);

% Define variabls so they stays around. (Basically this is a way to have
% internal properties that the inner methods can access and will stay in
% memory.  (just like an objects private properties)
x = [];
y = [];

% The following is just a guess at what an interesting angle would be.
% viewData = [10,80];
viewData = [0,90]; % equal as view(2);
grid(parenthandle, 'off');
view(parenthandle, viewData);
%rotate3d(parenthandle, 'off');

% Keep the handle to the plot so we can update the data in the background
hPlot = [];

hXLabel = get(parenthandle, 'XLabel');
hYLabel = get(parenthandle, 'YLabel');


update(iPlotData);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% define methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function update(plotData)
        x = plotData.XData.data;
        y = plotData.YData.data;

        if isempty(hPlot)
            hPlot = line(x,y, 'parent',parenthandle);
        else
            set(hPlot,'XData',x,'YData',y);
        end

        setXLabel(plotData.XData.label);
        setYLabel(plotData.YData.label);
%         if (length(x))
%             set(parenthandle, 'xlim', [min(x(:)), max(x(:)) ]);
%         end
%         if (length(y))
%             set(parenthandle, 'ylim', [min(y(:)), max(y(:)) ]);        
%         end
    
    end

    function setXLabel(label)
        set(hXLabel, 'String', label);
    end

    function setYLabel(label)
        set(hYLabel, 'String', label);
    end

    function myvisible(flag)
        if flag
            set(parenthandle,'Visible','on');
            set(hPlot,'Visible','on');
        else
            set(parenthandle,'Visible','off');
            set(hPlot,'Visible','off');
        end
    end

    function myclear()
        x = [];
        y = [];
        delete(parenthandle);
    end

    function myview(newview)
        viewData = newview;
    end

    function mydelete()
        delete(hPlot);
    end
end
