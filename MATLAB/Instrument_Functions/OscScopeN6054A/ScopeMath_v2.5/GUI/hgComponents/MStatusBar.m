function h = MStatusBar(hParent)

%   Copyright 1996-2012 The MathWorks, Inc.

hPanel = MPanel(hParent, 'statusbar');
%hPanel.setUIProperties('BorderType', 'none');

statusLabel = MEditField(hParent, 'statusLabel', 'Status');
statusLabelWidth = 14;
statusLabel.setEnable('inactive');

statusField = MEditField(hParent, 'statusField', ' Ready');
statusField.setHorizontalAlignment('left');
statusField.setEnable('inactive');

elapsedTimeField = MEditField(hParent, 'elaspsedTimeField', 'Elaspsed Time: 00:00:00');
elapsedTimeFieldWidth = 31.6;
elapsedTimeField.setEnable('inactive');

h            = hPanel;
h.setStatus  = @setStatus;
h.setError   = @setError;
h.updateTime = @updateTime;

hPanel.setUIProperties('ResizeFcn', @Resize);

%% resize the statusbar such that the Label and Time have fixed size and
%% the statusfield has the remaining space.
    function Resize(hObj, Event)
        position = hPanel.getUIProperties('Position');
        statusLabelPosition = [0, 0, statusLabelWidth, position(4)];
        statusLabel.setPosition(statusLabelPosition);
        etfPosition = [max(0, position(3)-elapsedTimeFieldWidth), 0, ...
            max(1,elapsedTimeFieldWidth), position(4)];
        elapsedTimeField.setPosition(etfPosition);
        sfPosition = [statusLabelPosition(3), 0, ...
            max(1,etfPosition(1)-statusLabelPosition(3)), position(4)];
        statusField.setPosition(sfPosition);
    end

    function setStatus(sStatus)
        statusField.setTextString([' ', sStatus]);
        statusField.setUIProperties('ForeGroundColor', 'black');
    end

    function setError(sError)
        statusField.setTextString([' ', sError]);
        statusField.setUIProperties('ForegroundColor', 'red');
    end

    function updateTime(etime)
        elapsedTimeField.setTextString(['Elapsed Time: ' ...
            datestr(datenum(0, 0, 0, 0, 0, etime), 'HH:MM:SS')]);
    end



end %MSTATUSBAR

