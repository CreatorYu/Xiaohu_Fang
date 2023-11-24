function hSource = MICTSource(hParent, bSimulation)
% MICTSOURCE connects to an instrument object and returns an MPanel with
% controls to select the channel of the instrument.  It will try to query
% the system for available instruments and allows the user to enter a
% custom instrument.
%
%     hSource = MICTSOURCE(hParent, bSimulation) returns the structure to a
%     new instrument source object.
%
%     hParent is the handle to the parent container object.
%
%     bSimulation is a boolean which, if true, directs MICTSOURCE to
%     connect to an instrument and if false it instead generates synthetic
%     data.  By passing bSimulation == true, you may call MICTSOURCE
%     without requiring the Instrument Control Toolbox.
%
global AYMAN
%% 'global' variables
hSource = [];
hSourceDlg = [];
hProgressBar = [];
hFuncToggleSourceDlgEnable = [];

bFromFile = false;
fileData  = [];

% if running in simulation mode, don't query the hardware or prompt for a
% custom device.
if (bSimulation)
    MakeSourcePanel([], []);
else
    ChooseSource;
end %if/else

    function ChooseSource
        % CHOOSESOURCE creates a figure with controls to choose an
        % instrument source and driver.  The user may also select Custom or
        % Simulation instead of the populated sources.
        try
            cDevs = DeviceInfo(FindVISAResources);
        catch
            h = errordlg({lasterr; ...
                'Because of this error, ScopeMath will now start in Simulation mode.'});
            waitfor(h);
            MakeSourcePanel([], []);
            return;
        end
        
        
        
        hMFig = MFigure(false);
        hSourceDlg = hMFig;
        hMFig.setUIProperties('WindowStyle', 'normal');
        hMFig.setTitle('ScopeMath Source Selection');
        
        hFuncToggleSourceDlgEnable = @toggleSourceDlgEnable; %so that other dialogs can control it.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%Define GUI Components
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hOffset = 4;
        scale = 1.35;
        hRsrcSelectorLabel = MLabel(hMFig, 'selectorlabel',...
            'Select an instrument resource and a MATLAB instrument driver for your device.');
        widthMax = scale*0.75*length(hRsrcSelectorLabel.getUIProperties('String'));
        position = hRsrcSelectorLabel.getUIProperties('Position');
        hRsrcSelectorLabel.setPosition([hOffset, 9, widthMax/1.4, position(end)*2]);
        
        hMFig.setColor(hRsrcSelectorLabel.getUIProperties('BackgroundColor'));
        
        hRsrcSelector = MComboBox(hMFig, 'RsrcSelector', {});
        stRsrcSelectorOpts.String = cellmap(cDevs, ...
            @(dev) dev.ioresourcedescriptor);
        stRsrcSelectorOpts.String = stRsrcSelectorOpts.String;
        stRsrcSelectorOpts.String{end+1} = 'Custom';
        stRsrcSelectorOpts.String{end+1} ='Simulation';
        
        stRsrcSelectorOpts.TooltipString = 'Select the data source, choose Custom..., or Simulation.';
        widthMax = scale*max(cell2mat(... %width should match the longest name
            cellmap(stRsrcSelectorOpts.String, @length)));
        widthMax = max(widthMax, 20);
        positionRsrc = hRsrcSelector.getUIProperties('Position');
        stRsrcSelectorOpts.Position = [hOffset+11, 7, widthMax, positionRsrc(end)];
        
        hRsrcLabel = MLabel(hMFig, 'rsrclabel', 'Resource:');
        hRsrcLabel.setPosition([hOffset, 7, 10, positionRsrc(end)]);
        
        hDrvrSelector = MComboBox(hMFig, 'DrvrSelector', 'foo');
        cDriverFiles = dir([getbasedir, '/drivers/*.mdd']);
        cDriverFiles = {cDriverFiles.name};
        if isempty(cDriverFiles)
            hMFig.delete();
            h = errordlg(['There are no valid MATLAB instrument drivers in the ''drivers/'' directory.  '...
                'ScopeMath will start in Simulation mode.']);
            waitfor(h);
            MakeSourcePanel([], []);
            return;
        end
        stDrvrSelectorOpts.String = cDriverFiles;
        stDrvrSelectorOpts.TooltipString = 'Select the MATLAB instrument driver file.';
        positionDrvr = hDrvrSelector.getUIProperties('Position');
        widthMax = scale*max(cell2mat(... %width should match the longest name
            cellmap(stDrvrSelectorOpts.String, @length)));
        stDrvrSelectorOpts.Position = [hOffset+11, 5, widthMax, positionDrvr(end)];
        
        
        hDrvrLabel = MLabel(hMFig, 'drvrlabel', 'Driver:');
        hDrvrLabel.setPosition([hOffset, 5, 10, positionDrvr(end)]);
        
        stRsrcSelectorOpts.Callback = @RsrcSelectorCB;
        
        function RsrcSelectorCB(obj, evt)
            if (hRsrcSelector.getUIProperties('Value')) == length(stRsrcSelectorOpts.String) %choose Simulation
                hDrvrSelector.setUIProperties('Enable', 'off');
            else
                hDrvrSelector.setUIProperties('Enable', 'on');
            end
        end %RsrcSelectorCB
        
        hRsrcSelector.setUIProperties(stRsrcSelectorOpts);
        hDrvrSelector.setUIProperties(stDrvrSelectorOpts);
        
        %%
        % now some buttons
        height = 2;
        [hBtnOK, hBtnCancel] = genButtons(hMFig, 'OK', @okFunc, 'Cancel', @cancelFunc, height);
        shrink(hMFig);
        centerButtons(hBtnOK, hBtnCancel);
        hMFig.setUIProperties('Resize', 'off');
        hMFig.setUIProperties('DeleteFcn', @cancelFunc);
        
        %%
        % and a progress bar
        hProgressBar = MTextedProgressBar(hMFig);
        posFig = hMFig.getUIProperties('Position');
        hProgressBar.setUIProperties('Position', [0, 0, posFig(3), 1.1]);
        uiwait(hMFig.handle); %wait until one of the callbacks is hit.
        
        function okFunc(obj, event)
            % If the user selects OK, either instantiate the source or
            % allow the user to enter a custom source.
            %
            nRsrc = hRsrcSelector.getUIProperties('Value');
            nDrvr = hDrvrSelector.getUIProperties('Value');
            fDrvr = cDriverFiles{nDrvr};
            nDevs = length(cDevs);
            save('cDevs')
            %hMFig.delete(); %hRsrcSelector no longer exists now
            hFuncToggleSourceDlgEnable('off');
            if (nRsrc > length(cDevs))
                if (nRsrc == nDevs+1) % chose Custom...
                    ChooseCustomSource(fDrvr);
                elseif (nRsrc == nDevs+2) % chose Simulation
                    MakeSourcePanel([], []);
                else
                    errordlg('There has been an error with the device selection.');
                    hSource = [];
                    return;
                end
            else
                MakeSourcePanel(cDevs{nRsrc}, fDrvr);
            end %if/else
            
        end
        % OKFUNC
        
        function cancelFunc(obj, event)
            % if the user selected Cancel, quit.
            hMFig.delete();
        end
        %CANCELFUNC
        
        function toggleSourceDlgEnable(val)
            hRsrcSelector.setUIProperties('Enable', val);
            hDrvrSelector.setUIProperties('Enable', val);
            hBtnOK.setUIProperties('Enable', val);
            hBtnCancel.setUIProperties('Enable', val);
        end
    end
%ChooseSource

    function ChooseCustomSource(fDrvr)
        % CHOSECUSTOMSOURCE creates a figure in which the user can enter a
        % customer hardware resource descriptor for a VISA device.
        %
        
        %%
        % create the figure
        
        hMFig = MFigure(false);
        hMFig.setUIProperties('WindowStyle', 'modal');
        hMFig.setTitle('ScopeMath Custom Source');
        
        hTFRsrc = MEditField(hMFig, 'tfres', '');
        hTFRsrc.getUIProperties('String')
        hTFRsrc.setBackgroundColor('white');
        position = hTFRsrc.getUIProperties('Position');
        numChars = 30;
        scale = 1.35;
        sTFRsrcOpts.Position = [4, 5, numChars*scale, position(end)];
        sTFRsrcOpts.HorizontalAlignment = 'left';
        sTFRsrcOpts.TooltipString = 'Enter a VISA hardware resource descriptor for your device.';
        hTFRsrc.setUIProperties(sTFRsrcOpts);
        
        sLabel = 'Enter a VISA hardware resource in the field below';
        hMLabel = MLabel(hMFig, 'lblres', sLabel);
        position = hTFRsrc.getUIProperties('Position');
        position(2) = position(2)+2; %place the label just above the editfield
        position(4) = position(4)*1.8;
        stLBLRsrcOpts.Position = position;
        hMLabel.setUIProperties(stLBLRsrcOpts);
        
        hMFig.setColor(hMLabel.getUIProperties('BackgroundColor'));
        
        [hBtnOK, hBtnCancel] = genButtons(hMFig, 'OK', @okFunc, 'Cancel', @cancelFunc, 1);
        
        shrink(hMFig);
        centerButtons(hBtnOK, hBtnCancel);
        hMFig.setUIProperties('Resize', 'off');
        hMFig.setUIProperties('DeleteFcn', @cancelFunc);
        uiwait(hMFig.handle);
        
        function okFunc(obj, event)
            % After the user enters a resource descriptor, attempt to
            % instantiate it and proceed.  If the resource did not work,
            % allow the user to try again.
            %
            visadrivers = instrhwinfo('visa');
            visadrivers = visadrivers.InstalledAdaptors;
            if (length(visadrivers) < 1)
                h = errordlg('No VISA drivers are installed');
                waitfor(h);
                hMFig.delete();
                return;
            end
            visadriver = visadrivers{1};
            
            stDev = createStDevFromRscName(hTFRsrc.getUIProperties('String'));
            if(isempty(stDev))
                hMFig.delete();
                ChooseCustomSource(fDrvr);
            else
                hMFig.delete();
                MakeSourcePanel(stDev, fDrvr);
            end
            
            
        end
        % OKFUNC
        
        function cancelFunc(obj, event)
            % If the user clicks cancel, quit.
            %
            
            hMFig.delete();
            hFuncToggleSourceDlgEnable('on');
        end
        %CANCELFUNC
        
    end %ChooseCustomSource

    function MakeSourcePanel(stDev, fDriver)
        if ~isempty(hSourceDlg)
            hSourceDlg.setUIProperties('Pointer','watch')
            updateProgress(.1);
            hProgressBar.setProgressMessage('Connecting, please wait...');
        end
        bRestartSourceSelection = false; %setting this to true will cause the
        %source selection process to
        %restart
        try
            % if there is no valid device, create a simulation device.
            if (isempty(stDev))
                hChannels(1).name = 'simChan1';
                hChannels(2).name = 'simChan2';
                hChannels(3).name = 'simChan3';
                sSourceName = 'Simulation';
                if ~isempty(hSourceDlg)
                    updateProgress(.75);
                end
            else
                scopeObj = scopeObject(fDriver, stDev);
                updateProgress(.4);
                scopeObj.connect();
                updateProgress(.7);
                [model, manufacturer] = scopeObj.getModel();
                sSourceName = sprintf('%s\n%s', manufacturer, model);
                nChan     = 1; %use the first channel
                hChanObj  = [];
            end %if/else
            if (~bRestartSourceSelection) %don't move progress on retry
                updateProgress(.97);
            end
        catch
            % hSourceDlg.setUIProperties('Pointer','arrow')
            bRestartSourceSelection = true;
            h = errordlg(lasterr);
            waitfor(h);
        end %try/catch
        
        %% delete the source dialog
        if ~isempty(hSourceDlg)
            hSourceDlg.setUIProperties('Pointer','arrow')
            hSourceDlg.delete(); %side-effect is uiresume
        end
        
        
        if (bRestartSourceSelection)
            DeleteFcn([],[]); %clean up.
            hSource = MICTSource(hParent, bSimulation);
            %loop until someone hits cancel or succeeds.
            return;
        end
        
        width = 20;
        
        %% generate the panel for the final control
        % return obj (expose the MPanel container)
        hPanel = MPanel(hParent, 'DataSource3');
        hPanel.setUIProperties('DeleteFcn', @DeleteFcn);
        hPanel.delete = @DeleteFcn;
        
        
        voffset = 0; %offset from the bottom edge of the panel
        hoffset = 0; %offset from the left of the panel
        
        hSourceLabel = MLabel(hPanel, 'dataSourceLabel', 'Data source:');
        posTemp = hSourceLabel.getUIProperties('Position');
        stSourceLabelOpts.Position = [hoffset, voffset+4.5, width, posTemp(4)];
        stSourceLabelOpts.HorizontalAlignment = 'left';
        hSourceLabel.setUIProperties(stSourceLabelOpts);
        
        hSourceName = MLabel(hPanel, 'datasourcename', sSourceName);
        stSourceNameOpts.Position = [hoffset, voffset+2.5, width, posTemp(4)+1];
        hSourceName.setUIProperties(stSourceNameOpts);
        
        hChannelLabel = MLabel(hPanel, 'dataChannelLabel','Data channel:');
        posTemp = hChannelLabel.getUIProperties('Position');
        stChannelLabelOpts.Position = [hoffset, voffset+1, width, posTemp(4)];
        stChannelLabelOpts.HorizontalAlignment = 'left';
        hChannelLabel.setUIProperties(stChannelLabelOpts);
        
        hChannelSelector = MComboBox(hPanel, 'dataChannelComboBox', 'foo');
        if (isempty(stDev))
            stChannelSelectorOpts.String = {hChannels.name};
        else
            stChannelSelectorOpts.String = scopeObj.getChannelNames();
        end %if/else
        
        posTemp = hChannelSelector.getUIProperties('Position');
        %stChannelSelectorOpts.Position = [hoffset, voffset, scale*widthMax+3, posTemp(4)];
        stChannelSelectorOpts.Position = [hoffset, voffset, width, posTemp(4)];
        stChannelSelectorOpts.TooltipString = 'Select the channel.';
        stChannelSelectorOpts.Callback = @updateChannel;
        hChannelSelector.setUIProperties(stChannelSelectorOpts);
        
        shrink(hPanel);
        
        
        updateChannel; %make sure it is initialized.
        
        hSource = hPanel;
        hSource.getData = @getData;
        hSource.updateChannel = @updateChannel;
        hSouree.connect = @sourceConnect;
        hSource.disconnect = @sourceDisconnect;
        %hSource.dev = devSource;
        hSource.loadFromFile = @loadFromFile;
        hSource.unloadFromFile = @loadFromSource;
        
        %%internal status fields
        sLabelX = 'Time [sec]';
        sLabelY = 'Amplitude [V]';
        
        function plotData = getData
            % pull the data from the scope and package it accordingly.
            % Check that the scope is initialized and the channel is
            % enabled first.
            
            
            if (bFromFile)
                plotData = fileData;
            else
                if (isempty(stDev)) %%account for the simulation state
                    hChanObj = hChannels(nChan);
                    switch hChanObj.name
                        case 'simChan1'
                            % load ('simChan1', 'dataVals', 'timeVals');
                            dataVals = (rand(1,500)-.5)*.1+sin(linspace(0,10*pi,500));
                            timeVals = 1:500;
                        case 'simChan2'
                            s = load ('simChan2', 'dataVals', 'timeVals');
                            dataVals = real(s.dataVals);
                            timeVals = s.timeVals;
                            dataVals = dataVals + rand(size(dataVals))*0.2;
                        case 'simChan3'
                            s = load ('simChan3', 'dataVals', 'timeVals');
                            dataVals = s.dataVals;
                            timeVals = s.timeVals;
                            dataVals = dataVals+(rand(size(dataVals))-.5)*.1;
                        otherwise
                            hParent.setError('The channel is not initialized.');
                    end
                    
                    hParent.setStatus('Running...');
                else
                    dataVals = [];
                    timeVals = [];
                    %                     if (~strcmp(get(devSource, 'Status'), 'open'))
                    %                         hParent.setError('The device is not initialized.');
                    if(~ scopeObj.devOpened())
                        hParent.setError('The device is not initialized.');
                        % todo: check if general
                        %                     elseif (~strcmp(get(hChanObj, 'State'), 'on'))
                        %                         hParent.setError('The selected channel is not enabled.');
                        %                     elseif (~strcmp(get(hChanObj, 'Enabled'), 'on'))
                    elseif(~scopeObj.channelEnabled(nChan))
                        hParent.setError('The selected channel is not enabled.');
                        
                        % todo: check if general
                        %                     elseif (~strcmp(get(hAcquisition, 'FastAcquisition'), 'off'))
                        %                         hParent.setError('ScopeMath does not support FastAcq state.');
                        
                    else %all tests passed
                        % todo: check if general
                        %                         [dataVals, timeVals, dataUnit, timeUnit] = ...
                        %                             invoke(hWaveform, 'readwaveform', hChanObj.name);
                        %      marta                   [dataVals, x0, dx] = invoke(hMeasurements(hChanObj.HwIndex), 'FetchWaveform', 1000);
                        %                         [dataVals, x0, dx] = invoke(hMeasurements(hChanObj.HwIndex), 'FetchWaveform', 1000);
                        %                         timeVals=0:dx:(length(dataVals)-1)*dx;
                        scopeObj.setActiveChannel(nChan);
                        [dataVals, timeVals] = scopeObj.getData();
                        %                         dataVals = zeros(1000,1);
                        %                         timeVals = 1:1000;
                        hParent.setStatus('Running...');
                    end
                end %if/else
                XData = MLabelledData(timeVals, sLabelX);
                YData = MLabelledData(dataVals, sLabelY);
                plotData = PlotData(XData, YData, []);
            end %if/else
            
            
        end
        %getData
        
        function updateChannel(varargin)
            nChan = hChannelSelector.getUIProperties('Value');
            %             hChanObj = hChannels(nChan);
            
        end
        %updateChannel
        
        %clean up the instruments
        function DeleteFcn(obj, event)
            try
                %if (ishandle(hWaitbar)) %clean up the waitbar if it's around
                %    close(hWaitbar);
                %end
                if (exist('scopeObj', 'var'))
                    scopeObj.disconnect();
                    scopeObj.delete();
                end
                
            catch
                h = errordlg('There has been an error closing the device.');
                waitfor(h);
            end %try/catch
        end
        %deletefcn
        
        function bool = loadFromFile
            
            hParent.setStatus('Loading data from file.');
            strpath = [getbasedir,'/importfileformats/*.dat'];
            
            [filename, pathname] = uigetfile(strpath,'Load data file.');
            if filename==0
                % User hit cancel
                bool = bFromFile;
                return;
            end;
            
            sLabelX = 'Time [sec]';
            sLabelY = 'Amplitude [V]';
            % Dummy File used to call your custom load function.
            str = ScopeMathLoad(fullfile(pathname,filename));
            
            fileData = PlotData(MLabelledData(str.Time, sLabelX),...
                MLabelledData(str.Waveform, sLabelY),...
                []);
            hSourceName.setUIProperties('String', 'File');
            bFromFile = true;
            bool = bFromFile;
        end %load from file
        
        function loadFromSource
            bFromFile = false;
            hParent.setStatus('Ready.');
            hSourceName.setUIProperties('String', sSourceName);
        end
        
    end %MAKESOURCEPANEL

    function updateProgress(newProg)
        if ~isempty(hSourceDlg)
            hProgressBar.updateProgress(newProg)
        end
    end

end %MICTSOURCE


function constructorList = FindVISAResources
%
%  FINDVISARESOURCES Construct a list of VISA constructors from INSTRHWINFO
%
%
% See also INSTRHWINFO

%   Copyright 2005 The MathWorks, Inc.
%   $Author: Tatkins $Revision: 1 $  $Date: 5/09/05 11:19a $

hwInfo = instrhwinfo('visa');
constructorList = QueryAdaptors(@(x) instrhwinfo('visa',x), ...
    hwInfo.InstalledAdaptors);

    function constructorList = QueryDevices(hfHWinfo)
        %%
        % QUERYDEVICES
        % Given an *HWINFO method, create the list of ObjectConstructors for
        % all installed input devices.
        % For DAQ, just query installed adaptors.
        % For ICT, query interfaces then adaptors.
        hwInfo = hfHWinfo();
        if (isfield(hwInfo, 'InstalledAdaptors')) %DAQ
            constructorList = QueryAdaptors(hfHWinfo, hwInfo.InstalledAdaptors);
        elseif (isfield(hwInfo, 'SupportedInterfaces')) %ICT
            constructorList = QueryInterfaces(hfHWinfo, hwInfo.SupportedInterfaces);
        else
            error('No supported devices found');
        end
    end %QUERYDEVICES

%%
    function constructorList = QueryAdaptors(hfHWinfo, cAdaptors)
        %%
        % QUERYADAPTORS
        % Given a cell array of adaptors and an *HWINFO method,
        % query for installed devices
        constructorList = cellmapcat(cAdaptors, ...
            @(adaptor) getfield(hfHWinfo(adaptor), 'ObjectConstructorName'));
    end % QUERYADAPTORS

%%
    function constructorList = QueryInterfaces(hfHWinfo,cIfaces)
        %%
        % Name: QUERYINTERFACES
        % Given a cell array of interfaces and an *HWINFO method,
        % query for existing adaptors on that interface.
        constructorList = cellmapcat(cIfaces, @Func);
        
        function out = Func(iface)
            out = [];
            if (isfield(hfHWinfo(iface), 'InstalledAdaptors'))
                out = QueryAdaptors(@(adaptorName) hfHWinfo(iface, adaptorName), ...
                    getfield(hfHWinfo(iface), 'InstalledAdaptors'));
            end
        end %FHANDLE
        
    end %QUERYINTERFACES

end %FINDVISARESOURCES

function stDev = createStDevFromRscName(visaRscName)
visadrivers = instrhwinfo('visa');
visadrivers = visadrivers.InstalledAdaptors;
if (length(visadrivers) < 1)
    disp('no VISA')
    return;
end
visaDriver = visadrivers{1};
sConstructor = sprintf('visa(''%s'', ''%s'');', visaDriver, visaRscName);
cstDev = DeviceInfo({sConstructor});
if (isempty(cstDev))
    stDev = [];
else
    stDev = cstDev{1};
end
end



function cstructDev = DeviceInfo(constructorList)
%
%  DEVICEINFO generate a structure of useful fields from the device
%  constructor.
%         structDev.constructor
%         structDev.ioresourcedescriptor
%
%
% See also FINDCONSTRUCTORS

%   Copyright 2005 The MathWorks, Inc.
%   $Author: Tatkins $Revision: 1 $  $Date: 5/09/05 11:19a $

cstructDev = cellmap(constructorList, @IDDevice);

%%
    function structDev = IDDevice(constructor)
        %%
        % IDDEVICE
        % Find the resource by breaking the constructor at '.
        % Finally parse the ID into the structDev structure.
        %
        %         structDev.constructor
        %         structDev.ioresourcedescriptor
        
        
        %%
        %Currently, the assumption is that every valid constructor is
        %for visa.  However, there may be non-visa objects as well
        
        try
            structDev.constructor = constructor;
            ioresourcedescriptor = ...
                regexp(constructor, '[\w|\.|:-]*''', 'match'); %split at the '
            structDev.ioresourcedescriptor = ioresourcedescriptor{4}(1:end-1);
        catch
            errordlg(sprintf('A device resource was invalid.\nResource: %s',...
                structDev.ioresourcedescriptor));
            structDev = [];
            return;
        end %try/catch
    end %IDDevice

end % DEVICEINFO



