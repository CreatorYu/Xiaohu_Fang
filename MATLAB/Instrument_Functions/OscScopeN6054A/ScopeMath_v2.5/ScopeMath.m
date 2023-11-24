function  ScopeMath()
%% SCOPEMATH creates a new SCOPEMATH GUI
%
%      H = ScopeMath returns the figure structure to a new SCOPEMATH
%
%NOTE: This application can only be run after MATLAB version R14 SP2.

%   Copyright 1996-2012 The MathWorks, Inc.
% global AYMAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Define GUI Components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig = MFigure(false);
fig.setTitle('ScopeMath');
fig.setUIProperties('Visible', 'off');
positionfig = [21 26 124 31]; %31
fig.setPosition(positionfig);
fig.setUIProperties('Renderer', 'opengl'); %resolves the figure flicker bit.
fig.setUIProperties('DeleteFcn', @figDeleteFcn); drawnow;
fig.setUIProperties('ResizeFcn', @figResizeFcn);
fig.setUIProperties('CloseRequestFcn', @figCloseFcn);

%create source panel
rawDataPanel = DataSourcePanel(fig, 'Raw Data');
fig.setColor(rawDataPanel.getUIProperties('BackgroundColor')); %reset background color.

bSimulation = false;
dataSourcePanel = MICTSource(rawDataPanel,bSimulation);
if isempty(dataSourcePanel)
    delete(fig.handle);
    return;
end
dataSourcePanel.setUIProperties('BorderType', 'none');
rawDataPanel.setSourcePanel(dataSourcePanel);

%create analyzed data panel
analyzedDataPanel = AnalyzedDataPanel(fig, 'Analyzed Data');

%create control button
startButton = PlotButton(fig, 'startButton', {analyzedDataPanel, rawDataPanel}, dataSourcePanel);
startButton.setPosition([98.8 1.84615384615385 21.2 1.84615384615385]);
startButton.triggerStartAction(@updateDisplay);
fig.isRunning = startButton.isRunning;

%create status bar
statusBar = MStatusBar(fig);
statusBar.setPosition([0, 0, positionfig(3), 1.5]);
fig.setStatusHandler(statusBar);
fig.setErrorHandler(statusBar);
fig.setETimeHandler(statusBar);

% create toolbar and menu bar
toolmenu = MakeToolbarMenubar(fig, rawDataPanel, dataSourcePanel, analyzedDataPanel);
analyzedDataPanel.setEnableTools(toolmenu.EnableTools);
analyzedDataPanel.setDisableTools(toolmenu.DisableTools);

% allow the startbutton to enable and disable the tools
hpreFunc  = startButton.getPreTriggerAction();
hpostFunc = startButton.getPostTriggerAction();

startButton.preTriggerStartAction(@smPreTriggerAction);
startButton.postTriggerStartAction(@smPostTriggerAction);
%
    function smPreTriggerAction
        toolmenu.DisableTools();
        hpreFunc();
    end

    function smPostTriggerAction
        hpostFunc();
        if (~analyzedDataPanel.is3D())
            toolmenu.EnableTools();
        end
    end

% show main GUI window
fig.setUIProperties('Visible', 'on');
fig.setUIProperties('HandleVisibility', 'off');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %help funcitions          %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateDisplay(hObj, event)
        try
            iPlotData = dataSourcePanel.getData();
            %Update the Raw data plot
            rawDataPanel.setDataSource(iPlotData);
            
            %Get the analysis function name
            analyzedDataPanel.setDataSource(iPlotData);
            
            etime = toc;
            fig.updateTime(etime);
        catch someException
            fig.setError('Error in the timer callback.');
        end
    end

    % Delete the UI objects in the figure in an appropriate order (timer first)
    function figDeleteFcn(hObject, eventData)
        if (exist('startButton', 'var'))
            startButton.delete();
        end
    end

    function figCloseFcn(hObject, eventData)
        fig.setUIProperties('Pointer','watch');
        
        if(startButton.isRunning())
            startButton.stop();
        end;
        
        statusBar.setStatus('System is cleaning up, please wait...');
        drawnow;
        closereq;
    end

    %resize all of the children appropriately
    function figResizeFcn(hObj, event)

        vbuffer = .5;
        hbuffer = 1;
        position = fig.getUIProperties('Position');
        position = get(hObj, 'Position');
        width  = position(3);
        height = position(4);
       
         posStatus = statusBar.getUIProperties('Position');
         posStatus(3) = max(width, 1);
         posStatus(1:2) = [0, 0];
         statusBar.setUIProperties('Position', posStatus);

        posStartBtn = startButton.getUIProperties('Position');
        posStartBtn(1:2) = [width - posStartBtn(3) - hbuffer, ...
            posStatus(4)+posStatus(2)+vbuffer];
        startButton.setUIProperties('Position', posStartBtn);

        edgeBottomPlot = posStartBtn(2)+posStartBtn(4);
        heightPlot = (height-edgeBottomPlot)/2;
        edgeTopPlot = edgeBottomPlot+heightPlot;

        posADP = [hbuffer, edgeBottomPlot+vbuffer, width-2*hbuffer, heightPlot-vbuffer];
        posADP(posADP<=0) = .01;
        analyzedDataPanel.setPosition(posADP);
        
        posRDP = [hbuffer, edgeTopPlot+vbuffer, width-2*hbuffer, heightPlot-vbuffer];
        posRDP(posRDP<=0) = .01;
        rawDataPanel.setPosition(posRDP);
       
    end
end