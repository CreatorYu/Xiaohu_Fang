function scopeObj = scopeObject(driverName, visaRsc)

%   Copyright 1996-2012 The MathWorks, Inc.

scopeObj = struct;

initScopeObj;

if(~isempty(scopeObj.stDev))
    nInitDeviceObj; 
end


    %% Init empty object
    function initScopeObj

        % properties

        scopeObj.driverName = driverName;
        if ischar(visaRsc)
            
            scopeObj.stDev = getStDev();
            
        elseif (isstruct(visaRsc)...
            && isfield(visaRsc, 'constructor')...
            && isfield(visaRsc, 'ioresourcedescriptor'))
            
            scopeObj.stDev = visaRsc;
            
        end
        
        scopeObj.devSource = [];
        scopeObj.devIface  = getIOObj();

        % functions

        scopeObj.initDeviceObj = @nInitDeviceObj;
        scopeObj.connect = @nConnect;
        scopeObj.disconnect = @nDisconnect;        
        scopeObj.setActiveChannel = @nSetActiveChannel;
        scopeObj.getData = @nGetData;
        scopeObj.getModel = @nGetModel;
        scopeObj.delete = @nDelete;
        scopeObj.getChannelNames = @nGetChannelNames;
        scopeObj.channelEnabled  = @nChannelEnabled;
        scopeObj.devOpened = @nDevOpened;
        
    end


    function nInitDeviceObj
        scopeObj.devSource = icdevice(scopeObj.driverName , scopeObj.devIface);     % ,'OPTIONSTRING','Simulate=true');
        scopeObj.driverType = get(scopeObj.devSource, 'DriverType');
        %init with the first channel
        scopeObj.actChannel = 1; 
        
        if strfind(scopeObj.driverType, 'interface')
            scopeObj.dev.Waveform = get(scopeObj.devSource, 'Waveform');
            scopeObj.dev.Channels = get(scopeObj.devSource, 'Channel');
            scopeObj.getDataFromScope = @nGetDataML;
        elseif strfind(scopeObj.driverType, 'IVI-COM')
            scopeObj.dev.Measurements = get(scopeObj.devSource, 'Measurement');
            scopeObj.dev.Channels = get(scopeObj.devSource, 'Channel');
            scopeObj.getDataFromScope = @nGetDataIVICOM;
        elseif strfind(scopeObj.driverType, 'IVI-C')
            scopeObj.getDataFromScope = @nGetDataIVIC;
        end
            
    end

    function nConnect
        connect(scopeObj.devSource);
    end

    function nDisconnect
       disconnect(scopeObj.devSource);
    end

    function nSetActiveChannel(chan)
        scopeObj.actChannel = chan;
    end

    function [dataVals, timeVals] = nGetDataML
        hChanObj = scopeObj.dev.Channels(scopeObj.actChannel);
        [dataVals, timeVals, dataUnit, timeUnit] = ...
            invoke(scopeObj.dev.Waveform, 'readwaveform', hChanObj.name);
    end

    function [dataVals, timeVals] = nGetDataIVICOM
        maxTimeMilliSeconds = 1000;
        hChanObj = scopeObj.devSource.Channel(scopeObj.actChannel);
        [dataVals, x0, dx] = invoke(scopeObj.devSource.Measurement(hChanObj.HwIndex), 'ReadWaveform', maxTimeMilliSeconds);
        timeVals = x0:dx:x0+(length(dataVals)-1)*dx;
    end

    function [dataVals, timeVals] = nGetDataIVIC
        maxTimeMilliSeconds = 1000;
        numPoints = invoke(scopeObj.devSource.Configurationconfigurationinformation,'actualrecordlength');
        channelName = invoke(scopeObj.devSource.Configurationchannel,'getchannelname',scopeObj.actChannel,512);
        waveformArray = libpointer('doublePtr', zeros(1,numPoints));
        [AAA,x0,dx] = invoke(scopeObj.devSource.Waveformacquisition, 'readwaveform', channelName,numPoints,maxTimeMilliSeconds,waveformArray);
        dataVals = waveformArray.Value;
        timeVals = x0:dx:x0+((numPoints-1)*dx);
        dataVals = dataVals(1:numPoints);
    end

    function [dataVals, timeVals] = nGetData
        if(~isfield(scopeObj, 'getDataFromScope'))
            [dataVals, timeVals] = nDefaultGetData();
        else
            [dataVals, timeVals] = scopeObj.getDataFromScope();
        end
   end

    function [data, time] = nDefaultGetData
        error('Device object not initialised')
    end

    function stDev = getStDev
        stDev = createStDevFromRscName(visaRsc);
    end

    function iface = getIOObj
        iface = eval(scopeObj.stDev.constructor);
        % check if MATLAB Driver
        try
            driverWithPath = localFindMATLABInstrumentDriverPath(scopeObj.driverName);
            obj = handle(com.mathworks.toolbox.instrument.device.icdevice.ICDeviceObject.getInstance(driverWithPath, iface, java(igetfield(iface, 'jobject'))));
        catch someException
            % not MATLAB driver error - error
            if ~strcmp(someException.message, 'The driver must be a MATLAB interface instrument driver.')
                error(someException.message);
            % not MATLAB driver - try other drivers later
            else
                delete(iface);
                iface = scopeObj.stDev.ioresourcedescriptor;
            end
        end     
    end

    function [model, manufacturer] = nGetModel
        manufacturer = 'Unknown';
        model = 'Unknown';
        sIDN = get(scopeObj.devSource, 'InstrumentModel');
        if strfind(scopeObj.driverType, 'interface')
            match = regexp(sIDN, '[^,]*','match'); %split at the comma
            try
                manufacturer = match{1};
                model = match{2};
            catch
                % Do nothing - the default is set to unknown
            end
        else
            match = regexp(sIDN, '[^, ]*','match'); %split at the comma
            try
                manufacturer = [match{1}];
                model = match{end};
            catch
                % Do nothing - the default is set to unknown
            end
        end
    end
        

    function [driver, errflag] = localFindMATLABInstrumentDriverPath(driver)
        % Initialize variables.
        errflag = false;
        % Find the driver.
        [pathstr, name, ext] = fileparts(driver);
        if isempty(ext)
            driver = [driver '.mdd'];
        end
        if isempty(pathstr)
            driverWithPath = which(driver);
            % If found driver, use it.
            if ~isempty(driverWithPath)
                driver = driverWithPath;
            end
        end
        % If not on MATLAB path, check the drivers directory.
        pathstr = fileparts(driver);
        if isempty(pathstr)
            driver = fullfile(matlabroot,'toolbox','instrument','instrument','drivers', driver);
        end
        % Verify that the driver exists.
        if ~exist(driver, 'file')
            errflag = true;
            errorID = 'instrument:icdevice:driverNotFound';
            lasterr(instrgate('privateMessageLookup', errorID), errorID);
            return;
        end
    end

    function nDelete
        if (~isempty(scopeObj))
            if (isfield(scopeObj, 'devSource'))
                delete(scopeObj.devSource);
            end
            if isequal(class(scopeObj.devIface),'visa')
                delete(scopeObj.devIface);
            end
        end
    end

    function names  = nGetChannelNames
        if strfind(scopeObj.driverType, 'interface')
            names = scopeObj.dev.Channels.name;
        elseif strfind(scopeObj.driverType, 'IVI-COM')
            names = scopeObj.devSource.Channel.Name;
        elseif strfind(scopeObj.driverType, 'IVI-C')
            for iLoop = 1:scopeObj.devSource.Channel.Channel_Count
                names{iLoop} = invoke(scopeObj.devSource.Configurationchannel,'getchannelname',iLoop,512);
            end
        end
    end


    function res  = nChannelEnabled(n)
        if strfind(scopeObj.driverType, 'interface')
            hChanObj = scopeObj.dev.Channels(n);
            res = strcmp(get(hChanObj, 'State'), 'on');
        elseif strfind(scopeObj.driverType, 'IVI-COM')
            isEnabled = get(eval(['scopeObj.devSource.Channel' num2str(n)]),'Enabled');
            res = strcmp(isEnabled, 'on');
        elseif strfind(scopeObj.driverType, 'IVI-C')
            scopeObj.devSource.RepCapIdentifier = invoke(scopeObj.devSource.Configurationchannel,'getchannelname',n,512);
            res = scopeObj.devSource.Channel.Channel_Enabled;
        end
    end

    function res = nDevOpened
       res = strcmp(get(scopeObj.devSource, 'Status'), 'open');
    end


        
end