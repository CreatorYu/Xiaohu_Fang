function h = MTextedProgressBar(hParent)

%   Copyright 1996-2012 The MathWorks, Inc.

hPanel = MPanel(hParent, 'progressbar');
%hPanel.setUIProperties('BorderType', 'none');

messageField = MEditField(hParent, 'messageField', '');
messageField.setHorizontalAlignment('left');
messageField.setEnable('inactive');

progressBar = MProgressBar(hParent, 'progressbar');

h            = hPanel;
h.setProgressMessage = @setProgressMessage;
h.updateProgress   = @updateProgress;

hPanel.setUIProperties('ResizeFcn', @Resize);

%% set default size
position = hParent.getUIProperties('Position');
hPanel.setUIProperties('Position', [0,0, position(3), 1.1]);

%% resize the messagebar such that the progress bar have fixed size and
%% the messagefield has the remaining space.
    function Resize(hObj, Event)
        position = hPanel.getUIProperties('Position');
        width = position(3);
        height = position(4);
        factor = .75; %percentage of messageBar to progressBar
        split = width*factor;
        remainder = width*(1-factor);
        messageFieldPosition = [0, 0, split, height];
        progressBarPosition = [split, 0, remainder, height];
        messageField.setUIProperties('Position', messageFieldPosition);
        progressBar.setUIProperties('Position', progressBarPosition);
    end

    function setProgressMessage(smessage)
        messageField.setTextString([' ', smessage]);
        messageField.setUIProperties('ForeGroundColor', 'black');
        drawnow;
    end

    %% update progress bar according to finishing percentage x. x is
    %% between 0,1
    function updateProgress(x)
        progressBar.update(x);
    end

end %MTextedProgressBar

