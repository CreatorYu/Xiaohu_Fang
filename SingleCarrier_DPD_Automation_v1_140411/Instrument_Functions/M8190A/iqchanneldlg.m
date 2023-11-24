function varargout = iqchanneldlg(varargin)
% IQCHANNELDLG MATLAB code for iqchanneldlg.fig
%      IQCHANNELDLG, by itself, creates a new IQCHANNELDLG or raises the existing
%      singleton*.
%
%      H = IQCHANNELDLG returns the handle to a new IQCHANNELDLG or the handle to
%      the existing singleton*.
%
%      IQCHANNELDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IQCHANNELDLG.M with the given input arguments.
%
%      IQCHANNELDLG('Property','Value',...) creates a new IQCHANNELDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iqchanneldlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iqchanneldlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help iqchanneldlg

% Last Modified by GUIDE v2.5 28-Nov-2013 20:51:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @iqchanneldlg_OpeningFcn, ...
                   'gui_OutputFcn',  @iqchanneldlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before iqchanneldlg is made visible.
function iqchanneldlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to iqchanneldlg (see VARARGIN)

% Choose default command line output for iqchanneldlg
tmp = varargin{1};
handles.output = tmp;
handles.DUC = 0;
if (length(varargin) >= 2)
    arbConfig = varargin{2};
    if (~isempty(strfind(arbConfig.model, 'DUC')))
        handles.DUC = 1;
    end
end
if (length(varargin) >= 3)
    pos = get(handles.figure1, 'Position');   % position of the channel dialog
    parentPos = get(varargin{3}, 'Position'); % position of the parent window
    parentCh = get(varargin{3}, 'Children');
    p2 = [0 0 0 0];                           % position of the download pushbutton
    for p = parentCh'
        if (strcmp(get(p, 'Tag'), 'pushbuttonDownload'))
            p2 = get(p, 'Position');
        end
    end
    % move the channel dialog on top of the pushbutton
    pos(1) = parentPos(1) + p2(1) - 5;
    pos(2) = parentPos(2) + p2(2) + 10;
    set(handles.figure1, 'Position', pos);
end
ch = get(handles.figure1, 'Children');
for i=1:length(ch)
    if (strcmp(get(ch(i), 'Style'), 'checkbox'))
        ud = get(ch(i), 'UserData');
        if (ud(1) <= size(tmp, 1) && ud(2) <= size(tmp, 2))
            set(ch(i), 'Value', tmp(ud(1), ud(2)));
            set(ch(i), 'Enable', 'On');
        else
            set(ch(i), 'Value', 0);
            set(ch(i), 'Enable', 'Off');
        end
    end
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes iqchanneldlg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = iqchanneldlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if (isfield(handles, 'output'))
    varargout{1} = handles.output;
    if (nargout >= 2)
        varargout{2} = iqchannelsetup('mkstring', handles.output);
    end
    close(handles.figure1);
else
    varargout{1} = [];
    if (nargout >= 2)
        varargout{2} = '';
    end
end


% --- Executes on button press in checkboxI1.
function checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxI1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxI1
ch = get(handles.figure1, 'Children');
udx = get(hObject, 'UserData');
for i=1:length(ch)
    if (strcmp(get(ch(i), 'Style'), 'checkbox'))
        ud = get(ch(i), 'UserData');
        val = get(hObject, 'Value');
        % find the other source for this channel
        if (ud(1) == udx(1) && ud(2) ~= udx(2))
            % in case of DUC, set the other one to the same value
            % in normal mode, don't allow both to be set to 1
            if (handles.DUC)
                set(ch(i), 'Value', val);
            elseif (val)
                set(ch(i), 'Value', 0);
            end
        end
    end
end

% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = handles.output;
ch = get(handles.figure1, 'Children');
for i=1:length(ch)
    if (strcmp(get(ch(i), 'Style'), 'checkbox'))
        ud = get(ch(i), 'UserData');
        if (ud(1) <= size(tmp, 1) && ud(2) <= size(tmp, 2))
            tmp(ud(1), ud(2)) = get(ch(i), 'Value');
        end
    end
end
handles.output = tmp;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
