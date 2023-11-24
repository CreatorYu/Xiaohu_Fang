function h = AnalyzedDataPanel(parent, title)
% ANALYZEDDATAPANEL creates a data analysis panel, which contains an axes,
% plot type combo box, analysis model combo box. Currently only '2D plot'
% and '3D waterfall plot' are supported. 
%
%      H = ANALYZEDDATAPANEL returns a structure to a new analyzed data panel.
%
%      parent is the parent figure you whish to put the panel
%      title is the panel title.
% 

%   Copyright 1996-2012 The MathWorks, Inc.

    mPlotData = [];
    mPlotType = '2D Plot';
    is3D = false;
    defaultLabelFontSize = 8;
    
    functionName = [];
    strXlabel = [];
    strYlabel = [];
    strTitle  = [];
    
    EnableTools  = [];
    DisableTools = [];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Define GUI Components
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h = MPanel(parent, 'analyzedDataPanel');
    h.setTitle(title);
    hFunctionPanel = MPanel(h, 'FunctionPanel');
    hFunctionPanel.setPosition([0, 0, 20, 30]);
    hFunctionPanel.setUIProperties('BorderType', 'none');

    dataAxes = MPlottableAxes(h, 'analyzedDataAxes', 'MPlot',[]);
    dataAxes.setUIProperties('FontSize', defaultLabelFontSize);
%     xLb = dataAxes.getUIProperties('XLabel');
%     set(xLb, 'FontSize', defaultLabelFontSize);
%     yLb = dataAxes.getUIProperties('YLabel');
%     set(yLb, 'FontSize', defaultLabelFontSize);
%     zLb = dataAxes.getUIProperties('ZLabel');
%     set(zLb, 'FontSize', defaultLabelFontSize);

    plotTypeLabel = MLabel(hFunctionPanel, 'plotTypeLabel', 'Plot type:');
    plotTypeComboBox = MComboBox(hFunctionPanel, 'plotTypeComboBox' , {'2D Plot'; 'Waterfall Plot'; 'Bar Plot'});
    plotTypeComboBox.actionSelectionChanged(@updatePlotType);
    
    analysisModelLabel = MLabel(hFunctionPanel, 'analysisModel','Analysis model:');
    analysisModelComboBox = MComboBox(hFunctionPanel, 'analysisModelComboBox' , {'bandpassfilter'});
    analysisModelComboBox.actionSelectionChanged(@updateAnalysisModel);
    
    analysisModelDespLabel = MLabel(hFunctionPanel, 'analysisModelDespLabel', 'Please select analysis model');
    analysisModelDespLabel.setUIProperties('HorizontalAlignment', 'left');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%register method names
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.axesHandle                    = dataAxes.axesHandle;
    h.setPanelPosition              = @setPanelPosition;
    h.setDataAxesPosition           = @setDataAxesPosition;
    h.setPlotTypeLabelPosition      = @setPlotTypeLabelPosition;
    h.setPlotTypeComboBoxPosition   = @setPlotTypeComboBoxPosition;
    h.setAnalysisModelLabelPosition = @setAnalysisModelLabelPosition;
    h.setAnalysisModelComboBoxPosition  = @setAnalysisModelComboBoxPosition;
    h.setAnalysisModelDespLabelPosition = @setAnalysisModelDespLabelPosition;
    h.setEnableTools  = @setEnableTools;
    h.setDisableTools = @setDisableTools;
    h.is3D            = @getis3D;
    
    function bool = getis3D;
        bool = is3D;
    end
        
    h.setAnalysisModel = @setAnalysisModel;
    h.setDataSource = @setDataSource;
    
    h.setDataAxesPosition([9.4 1.76923076923077 72.6 12.3076923076923]);
    
    width = 20;
    hOffset = 0;
    h.setPlotTypeLabelPosition(         [0 hOffset+9 width 1.5]);%1.15384615384615]);
    h.setPlotTypeComboBoxPosition(      [0 hOffset+8 width 1.5]);%1.69230769230769]);
    h.setAnalysisModelLabelPosition(    [0 hOffset+6 width 1.5]);%1.30769230769231]);
    h.setAnalysisModelComboBoxPosition( [0 hOffset+5 width 1.5]);%1.92307692307692]);
    h.setAnalysisModelDespLabelPosition([0 hOffset+0 width 4]);
    shrink(hFunctionPanel);

    h.setUIProperties('ResizeFcn', @resizeFcn);
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% setup analysis methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    demopathstr = [getbasedir,'/demofunctions'];
    fnames = what(demopathstr);
    MFunctionList = sort(strrep(fnames.m,'.m',''));
    PFunctionList = sort(strrep(fnames.p,'.p',''));
    FunctionList = unique({MFunctionList{:},PFunctionList{:}});
    
    % set analysis model
    if isempty(FunctionList)
        FunctionList = 'No Functions Found';
    end;
    h.setAnalysisModel(FunctionList);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% define mehtods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% set main panel's position
    function setPanelPosition(pos)
        h.setPosition(pos);
    end

    %% set data axes position
    function setDataAxesPosition(pos)
        dataAxes.setPosition(pos);
    end

    %% set plot type label's poisition
    function setPlotTypeLabelPosition(pos)
        plotTypeLabel.setPosition(pos);
    end

    %% set plot type combo box position
    function setPlotTypeComboBoxPosition(pos)
        plotTypeComboBox.setPosition(pos);
    end

    %% set analysis model label position
    function setAnalysisModelLabelPosition(pos)
        analysisModelLabel.setPosition(pos);
    end

    %% set analysis model combo box position
    function setAnalysisModelComboBoxPosition(pos)
        analysisModelComboBox.setPosition(pos);
    end

    %% set analysis model desp label position
    function setAnalysisModelDespLabelPosition(pos)
        analysisModelDespLabel.setPosition(pos);
    end

    %% set analysis model
    function setAnalysisModel(selectionList)
        analysisModelComboBox.setSelectionList(selectionList);
        updateAnalysisModel;
    end

    function setEnableTools(hFun)
        EnableTools = hFun;
    end

    function setDisableTools(hFun)
        DisableTools = hFun;
    end

    %% set data source. This is main the method that
    %% called to update axes
    function setDataSource(iPlotData)
        if ~isstruct(iPlotData)
            return;
        end
        
        mPlotData = iPlotData;

        updateAxes;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% private method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resizeFcn(hObj, event)
        position = h.getUIProperties('Position');
        vBuffer = .5;
        hBuffer = 1;
        if (~isempty(hFunctionPanel))
            positionFunctionPanel = hFunctionPanel.getUIProperties('Position');
            positionFunctionPanel(1:2) = [position(3)-positionFunctionPanel(3)-hBuffer, ...
                position(4)-(positionFunctionPanel(4)+2*vBuffer)];
            %positionFunctionPanel(4) = position(4)-4*vBuffer;
            positionFunctionPanel(positionFunctionPanel<=0) = 1;
            hFunctionPanel.setUIProperties('Position', positionFunctionPanel);
        else
            positionFunctionPanel = [10, 10, 10, 10]; %ugly hack
        end
        offset = [hBuffer*1.5, vBuffer];
        positiondataAxes = -offset;
        %subtract an additional bit from the height to account for the
        %title in the panel.
        positiondataAxes(3:4) = [position(3)-positionFunctionPanel(3), position(4)-.75]; 
        positiondataAxes(3:4) = positiondataAxes(3:4)+2*offset;
        positiondataAxes(positiondataAxes(3:4)<=0) = 1;
        dataAxes.setUIProperties('OuterPosition', positiondataAxes);
      
    end %RESIZEFCN

    %% update analysis model. The method is called when analysis model
    %% selection is chanaged
    function updateAnalysisModel(hObject, eventData)
        %get selected string
        functionName = getSelectedAnalysisModelName;
        [strXlabel,strYlabel,strTitle]=feval(functionName);
                
        %update analysis model description string        
        analysisModelDespLabel.setTextString(strTitle);
        
        if (~parent.isRunning())
            updateAxes;
        end
    end

    %% update plot type. The method is called when plot type
    %% selection is chanaged
    function updatePlotType(hObject, eventData)
        list = plotTypeComboBox.getUIProperties('String');
        selectedIndex = plotTypeComboBox.getUIProperties('Value');
        mPlotType = list(selectedIndex);
        
        if strcmp(mPlotType,'2D Plot')    
            is3D = false;
            dataAxes.updatePlotType('MPlot');
            if (~isempty(EnableTools) && ~parent.isRunning())
                EnableTools();
            end
        elseif strcmp(mPlotType,'Bar Plot')    
            is3D = false;
            dataAxes.updatePlotType('MBar');
            if (~isempty(EnableTools) && ~parent.isRunning())
                EnableTools();
            end
        elseif strcmp(mPlotType,'Waterfall Plot')
            is3D = true;
            dataAxes.updatePlotType('MWaterfall');
            if (~isempty(DisableTools))
                DisableTools();
            end
        else
            errordlg(['Plot type: ' mPlotType ' is not supported']);
        end;
        datacursormode(parent.handle,'off')
        if (~parent.isRunning())
            updateAxes;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% help methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function n = NL
        n = 10; % ascii newline character
    end

    %%find next occurence of a given char from current pos in the given
    %%contents
    function ind = findNextOccurenceOfCharacter(contents, pos, character)
        occurrences = find(contents == character);
        % only care about the first one
        ind = occurrences(min(find(occurrences>pos(1))));
    end

    %% get selected analysis model name
    function funcName = getSelectedAnalysisModelName
        FunctionList = analysisModelComboBox.getUIProperties('String');
        funcName = FunctionList{analysisModelComboBox.getUIProperties('Value')};
    end

    %% update axes.
    function updateAxes
                
        if isempty(mPlotData)
            mPlotData = PlotData(MLabelledData([], []), MLabelledData([], []), MLabelledData([], []));
        end      
       
        try %hide errors from the function invocation
            x = [];
            y = [];
            if ~isempty(mPlotData.YData.data) %make sure the input data is valid
                warning off; %hide all of the warnings from the analysis functions
                [x,y]=feval(functionName,mPlotData.YData.data,mPlotData.XData.data);
                warning on;
            else %otherwise, return no data;
                x = [];
                y = [];
            end
        catch
            %error in the analysis function
        end

        if strcmp(mPlotType,'2D Plot') 
            plotData = PlotData(MLabelledData(x, strXlabel),...
                                MLabelledData(y, strYlabel),...
                                []);
        elseif strcmp(mPlotType,'Bar Plot') 
            plotData = PlotData(MLabelledData(x, strXlabel),...
                                MLabelledData(y, strYlabel),...
                                []);
        elseif strcmp(mPlotType,'Waterfall Plot')  
            plotData = PlotData(MLabelledData(x, strXlabel),...
                                MLabelledData([1:10], 'Iteration'),...
                                MLabelledData(y, strYlabel));
        else
            errordlg('Invalid plot type','Plot Type Error');
            return;
        end;

        dataAxes.updateAxes(plotData);
    end
end