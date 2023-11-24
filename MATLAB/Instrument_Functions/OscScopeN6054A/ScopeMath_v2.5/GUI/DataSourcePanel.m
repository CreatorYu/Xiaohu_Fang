function h = DataSourcePanel(parent, title)
% DATASOURCEPANEL creates a data source panel, which contains an axes,
% data source information and data channel combo box.
%
%      H = DATASOURCEPANEL returns a structure to a new source data panel.
%
%      parent is the parent figure you whish to put the panel
%      title is the panel title.
% 

%   Copyright 1996-2012 The MathWorks, Inc.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Define GUI Components
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h = MPanel(parent, 'rawDataPanel');
    h.setTitle(title);

    defaultLabelFontSize = 8;
    dataAxes = MPlottableAxes(h, 'rawDataAxes', 'MPlot',[]);
    dataAxes.setUIProperties('FontSize', defaultLabelFontSize);
%     xLb = dataAxes.getUIProperties('XLabel');
%     set(xLb, 'FontSize', defaultLabelFontSize);
%     yLb = dataAxes.getUIProperties('YLabel');
%     set(yLb, 'FontSize', defaultLabelFontSize);
%     zLb = dataAxes.getUIProperties('ZLabel');
%     set(zLb, 'FontSize', defaultLabelFontSize);
    
    hSourcePanel = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%register method names
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.axesHandle               = dataAxes.axesHandle;
    h.setPanelPosition         = @setPanelPosition;
    h.setDataAxesPosition = @setDataAxesPosition;
    h.setDataSource = @setDataSource;
    h.setSourcePanel = @setSourcePanel;
    h.unloadFromFile  = @unloadFromFile;
    h.setUIProperties('ResizeFcn', @resizeFcn);
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% define mehtods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % resize the panel
    function resizeFcn(hObj, event)
        position = h.getUIProperties('Position');
        vBuffer = .5;
        hBuffer = 1;
        if (~isempty(hSourcePanel))
            positionSourcePanel = hSourcePanel.getUIProperties('Position');
            positionSourcePanel(1:2) = [position(3)-positionSourcePanel(3)-hBuffer, ...
                position(4)-(positionSourcePanel(4)+2*vBuffer)];
            positionSourcePanel(positionSourcePanel<=0) = 1;
            hSourcePanel.setUIProperties('Position', positionSourcePanel);
        else
            positionSourcePanel = [10, 10, 10, 10]; %ugly hack
        end
        offset = [hBuffer*1.5, vBuffer];
        positiondataAxes = -offset;
        %subtract an additional bit from the height to account for the
        %title in the panel.
        positiondataAxes(3:4) = [position(3)-positionSourcePanel(3), position(4)-.75]; 
        positiondataAxes(3:4) = positiondataAxes(3:4)+2*offset;
        positiondataAxes(positiondataAxes(3:4)<=0) = 1;
        dataAxes.setUIProperties('OuterPosition', positiondataAxes);
        
    end

    %% set panel poisition
    function setPanelPosition(pos)
        h.setPosition(pos);
    end

    %% set data axes position
    function setDataAxesPosition(pos)
        dataAxes.setPosition(pos);
    end
    
    %set the datasource panel so I can access it for resize.
    function setSourcePanel(iSourcePanel)
        hSourcePanel = iSourcePanel;
    end

    %% This is the method that user should called to update the plot
    function setDataSource(iPlotData)
        if ~isstruct(iPlotData)
            return;
        end
        dataAxes.updateAxes(iPlotData);
    end

    %% load data from instrument
    function unloadFromFile(varargin)
        if (isempty(hSourcePanel))
            parent.Error('No source configured');
        else
            hSourcePanel.unloadFromFile();
        end
    end
end