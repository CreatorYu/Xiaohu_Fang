function h=MTriggerButton(parent,tag, strtext)
%MTRIGGERBUTTON extends from MButton. When MTriggerButton is pressed,
%a timer will start to perform the action that user defines.
%
% Usage:
%       h=MTriggerButton(fig,tag,buttonText)
%
%       fig is the parent figure you whish to put the button
%       buttonText is the text you want on the button
%
%       h is the handle to the button
%

%   Copyright 1996-2012 The MathWorks, Inc.

% Create the Button
    h = MToggleButton( parent,... 
                   tag, ...
                   strtext);
    h.actionButtonPressed(@startButtonAction);
    parentDelete = h.delete; %store the superclass delete
   
    
    preTriggerAction = [];
    postTriggerAction = [];
    errorAction = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Define button action
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               
    h.triggerStartAction = @triggerStartAction;
    h.preTriggerStartAction = @preTriggerStartAction;
    h.postTriggerStartAction = @postTriggerStartAction;
    h.errorTriggerAction = @errorTriggerAction;
    h.getPreTriggerAction = @getPreTriggerAction;
    h.getPostTriggerAction = @getPostTriggerAction;
    h.stop  = @stopTimer;
    h.start = @startTimer;
    h.delete = @mydelete;
    
    h.setMaxTriggerRunTime = @setMaxTriggerRunTime;
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Define timer
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bTimer = timer(  'Name','TriggerButtonTimer',...               % Give it a name that coresponds to the file name
                      'ExecutionMode', 'fixedSpacing',...    % Make the plot update starting the clock after the TimerFcn has finished
                      'Period', 0.1,...                      % Update the plot every 0.1 seconds
                      'BusyMode', 'drop');                 % Run for only a limited time.
    bTimer.StartFcn = {@timer_startAction};
%   bTimer.TimerFcn = {@actionTriggerPressed};
    bTimer.ErrorFcn = {@timer_errorAction};
    bTimer.StopFcn = {@timer_stopAction};
    
    h.isRunning = @() (isvalid(bTimer) && strcmp('on', get(bTimer,'Running')));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% help method                           %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function stopTimer
        if isvalid(bTimer)
            stop(bTimer);
        end
    end

    function startTimer
        if (isvalid(bTimer) && ~isempty(preTriggerAction))
            preTriggerAction();
            start(bTimer);
        end
    end

    function setMaxTriggerRunTime(duration)
        set(bTimer, 'TasksToExecute', duration);
    end
    
    %% STARTME function called at start of Timer
    function timer_startAction(hObject,varargin)
    % Update the StatusText
        h.setTextString('Stop');

        %if ~isempty(preTriggerAction)
        %    preTriggerAction();
        %end
    end


    %% STOPME function called at the stop of the Timer
    function timer_stopAction(hObject,varargin)
        if (exist('h'))
            h.setTextString('Start');
            h.setUIProperties('Value',0);
        end
        
        if ~isempty(postTriggerAction)
            postTriggerAction();
        end
    end

    %% clean up by stopping the timer and propagating the delete
    function mydelete(varargin)
        stop(bTimer);
        delete(bTimer);
        parentDelete();
    end

    %% TIMERERROR function which updates the status bar with lasterr
    function timer_errorAction(hObject,varargin)
        
        if ~isempty(errorAction)
            errorAction();
        end
    end

    %% define action when start button is pushed.
    function startButtonAction(hObject, eventdata)
        isStart = h.getUIProperties('Value');
        
        if isStart
            try
                h.start();
            catch
                if(isvalid(bTimer))
                    delete(bTimer);
                end
            end;
        else
            try
                h.stop();
            catch
                if(isvalid(bTimer))
                    delete(bTimer);
                end
            end;
        end
    end


    function triggerStartAction( runningFileName)
        if isvalid(bTimer)
            set(bTimer, 'TimerFcn', runningFileName);
        end
    end

    function hFunc = getPreTriggerAction
        hFunc = preTriggerAction;
    end

    function hFunc = getPostTriggerAction
        hFunc = postTriggerAction;
    end

    function preTriggerStartAction(preActionHandle)
        if isempty(preActionHandle)
            return;
        end
        preTriggerAction = preActionHandle;
    end

    function postTriggerStartAction(postActionHandle)
        if isempty(postActionHandle)
            return;
        end
        postTriggerAction = postActionHandle;
    end

    function errorTriggerAction(errorHandle)
        if isempty(errorHandle)
            return;
        end
        errorAction = errorHandle;
    end
end
