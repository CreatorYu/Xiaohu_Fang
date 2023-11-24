function h = PlotButton(parent, tag, cSinks, Source)
%% PLOTBUTTON
% extends MTriggerButton specifically for the purpose of plotting from a
% source to an array of sinks.
% NOTE: this function is specific for ScopeMath.

%   Copyright 1996-2012 The MathWorks, Inc.

h = MTriggerButton(parent, tag, 'start');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %register action
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %define button's action
    %h.triggerStartAction(@startAnalysis);
    h.preTriggerStartAction(@preAnalysisAction);
    h.postTriggerStartAction(@postAnalysisAction);
    h.errorTriggerAction(@errorAnalysisAction);
    h.setMaxTriggerRunTime(6000); % Change this to change the max run time of ScopeMath
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %help methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Actions when error happens
    function errorAnalysisAction(hObject, varargin)
        % Get a handle to the figure and close it.
        %this line is erroring because varargin is empty.
        %msg = regexp(varargin{1}.Data.message,'[\w /\.'']*$','match');
        %parent.setError(msg{1});]
        parent.setError(lasterr);
    end
    
    %% Actions after analysis
    function postAnalysisAction(hObject, varargin)
        parent.setStatus('Ready'); 
    end
    
    %% Actions before analysis
    function preAnalysisAction(hObject, varargin)
        parent.setStatus('Running...');
        tic;
        parent.updateTime(0); %start at zero time
    end
    
end %PLOTBUTTON