function toolmenu = MakeToolbarMenubar(fig, rawDataPanel, dataSourcePanel, analyzedDataPanel)
% MAKETOOLBARMENUBAR creates a Toolbar and Menu bar. This function is
% specfic for ScopeMath.
%
%      H = MakeToolbarMenubar returns a structure to a new tool bar menu
%      bar
%
%      fig is the parent figure you whish to put the tool bar
%      rawDataPanel is ScopeMath's raw data panel
%      dataSourcePanel is ScopeMath's data source panel
%      analyzedDataPanel is ScopeMath's analyzed data panel
% 

%   Copyright 1996-2012 The MathWorks, Inc.

ax(1) = rawDataPanel.axesHandle;
ax(2) = analyzedDataPanel.axesHandle;

toolsEnabled          = true;
toolmenu.DisableTools = @DisableTools;
toolmenu.EnableTools  = @EnableTools;

RawAxesState = [];
AnaAxesState = [];
% add menu and its items
fileMenu = MMenu(fig, 'fileMenu','File');
closeMenu = MMenu(fileMenu, 'closeMenu', 'Close ScopeMath');
closeMenu.setUIProperties('Separator', 'on');
toolsMenu = MMenu(fig, 'toolsMenu', 'Tools');
zoomInMenu = MMenu(toolsMenu, 'zoomin', 'Zoom In');
zoomOutMenu = MMenu(toolsMenu, 'zoomout', 'Zoom Out');
panMenu = MMenu(toolsMenu, 'pan', 'Pan');
linkMenu = MMenu(toolsMenu, 'link', 'Link Axes');
dataCursorMenu = MMenu(toolsMenu, 'cursor', 'Data Cursor');

helpMenu = MMenu(fig, 'helpMenu', 'Help');
scopeMathHelpMenu = MMenu(helpMenu, 'scopeMathHelpMenu', 'ScopeMath Help');
analysisFuncHelpMenu = MMenu(helpMenu, 'analysisFuncHelpMenu', 'Analysis Functions Help');
aboutMenu = MMenu(helpMenu, 'aboutMenu', 'About ScopeMath');
aboutMenu.setUIProperties('Separator', 'on');

% add toolbar and its items
toolbar     = MToolBar(fig);
zoomInIcon  = MZoomInIcon(toolbar);
zoomOutIcon = MZoomOutIcon(toolbar);
panIcon     = MPanIcon(toolbar);
linkIcon    = MLinkIcon(toolbar);
linkIcon.addSeparator();
dataCursorIcon  = MDataCursorIcon(toolbar);
dataCursorIcon.addSeparator();

%define menu bar's behaviors
closeMenu.actionItemSelected(@closeFigure);
zoomInMenu.actionItemSelected(@zoomIn); %these should behave the same as the buttons
zoomOutMenu.actionItemSelected(@zoomOut);
panMenu.actionItemSelected(@panIconAction);
linkMenu.actionItemSelected(@linkIconAction);
dataCursorMenu.actionItemSelected(@dataCursorIconAction);


scopeMathHelpMenu.actionItemSelected(@displayHelpScopeMath);
aboutMenu.actionItemSelected(@displayAboutScopeMath);
analysisFuncHelpMenu.actionItemSelected(@displayAnalysisFuncInfo);

%define toolbar icon behaviors
zoomInIcon.actionItemSelected(@zoomIn);
zoomInIcon.linkMenu(zoomInMenu);
zoomOutIcon.actionItemSelected(@zoomOut);
zoomOutIcon.linkMenu(zoomOutMenu);
panIcon.actionItemSelected(@panIconAction);
panIcon.linkMenu(panMenu);
linkIcon.actionItemSelected(@linkIconAction);
linkIcon.linkMenu(linkMenu);
dataCursorIcon.actionItemSelected(@dataCursorIconAction);
dataCursorIcon.linkMenu(dataCursorMenu);

    % disable tools
    function DisableTools
        if (~fig.isRunning() && toolsEnabled)
            zoomInIcon.TurnOff();
            zoomOutIcon.TurnOff();
            panIcon.TurnOff();
            linkIcon.TurnOff();
            dataCursorIcon.TurnOff();
            zoomInIcon.Disable();
            zoomOutIcon.Disable();
            panIcon.Disable();
            linkIcon.Disable();
            dataCursorIcon.Disable();
            h = datacursormode(fig.handle); %get the data cursors
            removeAllDataCursors(h); % undocumented method to remove data cursors
            zoom(fig.handle, 'out');
            toolsEnabled = false;
        end
    end %DisableTools
    
    %enable tools
    function EnableTools
        if (~fig.isRunning() && ~toolsEnabled)
            zoomInIcon.Enable();
            zoomOutIcon.Enable();
            panIcon.Enable();
            linkIcon.Enable();
            dataCursorIcon.Enable();
            toolsEnabled = true;
        end
    end %EnableTools


    %%CALLBACKS
    function opposite = tilde(sState)
        if (strcmp(sState, 'off'))
            opposite = 'on';
        else
            opposite = 'off';
        end
    end

    %% zoom in function
    function zoomIn(hObject, eventdata)
        if (strcmp(get(hObject, 'Type'), 'uitoggletool'))
            onoff = get(hObject, 'State');
        else
            onoff = tilde(get(hObject, 'Checked'));
        end
        zoomInIcon.setUIProperties('State', onoff);
        zoomInMenu.setUIProperties('Checked', onoff); %propagate the value
        if strcmp(onoff,'on')
            zoom(fig.handle,'inmode');
        else
            zoom(fig.handle,'off')
        end
    end

    %% ZoomOut function. 
    function zoomOut(hObject, eventdata)
        if (strcmp(get(hObject, 'Type'), 'uitoggletool'))
            onoff = get(hObject, 'State'); %%This breaks an abstraction potentially
        else
            onoff = tilde(get(hObject, 'Checked'));
        end
        zoomOutIcon.setUIProperties('State', onoff);
        zoomOutMenu.setUIProperties('Checked', onoff); %propagate the value
        if strcmp(onoff,'on')
            zoom(fig.handle,'outmode');
        else
            zoom(fig.handle,'off')
        end
    end

    %% DataCursor function.
    function dataCursorIconAction(hObject, eventdata)
        if (strcmp(get(hObject, 'Type'), 'uitoggletool'))
            onoff = get(hObject, 'State'); %%This breaks an abstraction potentially
        else
            onoff = tilde(get(hObject, 'Checked'));
        end
        dataCursorIcon.setUIProperties('State', onoff);
        dataCursorMenu.setUIProperties('Checked', onoff); %propagate the value
        if strcmp(onoff,'on')
            datacursormode(fig.handle, 'on');
        else
            datacursormode(fig.handle, 'off');
        end
    end


    %% overloading default function of pan, stop the pulling first.
    function panIconAction(hObject, eventdata)
        if (strcmp(get(hObject, 'Type'), 'uitoggletool'))
            onoff = get(hObject, 'State'); %%This breaks an abstraction potentially
        else
            onoff = tilde(get(hObject, 'Checked'));
        end
        panIcon.setUIProperties('State', onoff);
        panMenu.setUIProperties('Checked', onoff);
        pan(fig.handle,onoff);
    end

    %% link icon action
    function linkIconAction(hObject, eventdata)
        if (strcmp(get(hObject, 'Type'), 'uitoggletool'))
            onoff = get(hObject, 'State'); %%This breaks an abstraction potentially
        else
            onoff = tilde(get(hObject, 'Checked'));
        end
        linkIcon.setUIProperties('State', onoff);
        linkMenu.setUIProperties('Checked', onoff);
        
        warning off all;
        if (strcmp(onoff, 'off'))
            linkaxes(ax, 'off');
            set(ax(2), 'XLimMode', 'auto', 'YLimMode', 'auto', 'ZLimMode', 'auto');
            set(ax(1), 'XLimMode', 'auto', 'YLimMode', 'auto', 'ZLimMode', 'auto');
        else
            linkaxes(ax, 'x');
        end %if/else
        warning on;
                   
    end

    %% display about scopemath and license documents
    function displayAboutScopeMath(hObject, eventdata)
        msgbox(sprintf('This GUI application is developed in MATLAB to read data from an oscilloscope, apply signal processing algorithms to it, and visualize the raw and processed data. \n\nCopyright 1984-2012 The MathWorks, Inc.'),'ScopeMath version 2.5','help')
    end

    %% display scopemath help documents
    function displayHelpScopeMath(hObject, eventdata)
        base = [getbasedir,'/Help/'];
        web(['file:///',base,'ScopeMathHelpDoc.html'],'-browser');
    end

    %% display analysis function information
    function displayAnalysisFuncInfo(hObject, eventdata)
        base = [getbasedir,'/Help/demofunctions/'];
        web(['file:///',base,'intro.html'],'-browser');
    end

    % close the figure
    function closeFigure(hObject, eventData)
        if ~isempty(fig)
            fig.delete();
        end
    end

end %MAKETOOLBARMENUBAR