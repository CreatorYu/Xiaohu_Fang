function h=MPlottableAxes(iParent,iTag, iPlotTypeName, iData)
%MPLOTTABLEAXES Wrap an AXES and plot
%
% Usage:
%       h=MPlottableAxes(fig,tag)
%
%       fig is the parent figure you whish to put the button
%       tag is the tag of axes
%       plotTypeName is the name of plot type such as 'MPlot', 'MWaterfall'
%           TODO: how can we have a plot type object, which always provide a
%           valid plot type rather than let user to creat a name.
%       data is the data that want to be plotted. It can be 2D or 3D data
%           axisType will define if the axis will auto fit the data or will
%           always 'grow' based on the input data.
%           TODO: how to define 'TYPE'.
%
%       h is a structure that's fields act like methods on an object.
%

% Create the MAXES
    if isstruct(iParent)
        parentHandle = iParent.handle;
    else
        parentHandle = iParent; 
    end;
    
    h = MAxes(parentHandle, iTag);
    
    %% set axis label model
%     h.setUIProperties('XLimMode', 'Auto');
%     h.setUIProperties('YLimMode', 'Auto');
%     h.setUIProperties('ZLimMode', 'Auto');
    
    plotHandle = [];
    plotTypeName = iPlotTypeName;
    oldPlotType = [];
    
    if ~isempty(iData)
        updateAxes(iData);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Declare methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.axesHandle = h.handle;
    h.updateAxes = @updateAxes;
    h.updatePlotType = @updatePlotType;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Implement method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% update Axes with array of labelled data.
    function updateAxes(iPlotData)
        if ~strcmp(oldPlotType, plotTypeName)
            if (~isempty(plotHandle))
                %plotHandle.delete();
                delete(get(h.handle, 'Children'));
            end
            plotHandle = [];
        end
        
        if isempty(plotHandle)
            plotHandle = feval(plotTypeName, h, iPlotData);
        else %if strcmp(oldPlotType, plotTypeName)
            plotHandle.update(iPlotData);
        end
        oldPlotType = plotTypeName;
        %axis(h.handle,'auto');
    end

    %% update plot type when plot type switch from 2D to 3D.
    function updatePlotType(iPlotTypeName)
       if isempty(iPlotTypeName)
            return;
       end      
       plotTypeName = iPlotTypeName;
    end
end
