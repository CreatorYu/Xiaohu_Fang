function varargout = dphy_gui(varargin)
% DPHY_GUI MATLAB code for dphy_gui.fig
%      DPHY_GUI, by itself, creates a new DPHY_GUI or raises the existing
%      singleton*.
%
%      H = DPHY_GUI returns the handle to a new DPHY_GUI or the handle to
%      the existing singleton*.
%
%      DPHY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPHY_GUI.M with the given input arguments.
%
%      DPHY_GUI('Property','Value',...) creates a new DPHY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dphy_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dphy_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dphy_gui

% Last Modified by GUIDE v2.5 16-Dec-2013 18:06:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dphy_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @dphy_gui_OutputFcn, ...
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


% --- Executes just before dphy_gui is made visible.
function dphy_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dphy_gui (see VARARGIN)

% Choose default command line output for dphy_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dphy_gui wait for user response (see UIRESUME)
% uiwait(handles.iqtool);


% --- Outputs from this function are returned to the command line.
function varargout = dphy_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editHSdataRate_Callback(hObject, eventdata, handles)
% hObject    handle to editHSdataRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHSdataRate as text
%        str2double(get(hObject,'String')) returns contents of editHSdataRate as a double


% --- Executes during object creation, after setting all properties.
function editHSdataRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHSdataRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLPdataRate_Callback(hObject, eventdata, handles)
% hObject    handle to editLPdataRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLPdataRate as text
%        str2double(get(hObject,'String')) returns contents of editLPdataRate as a double


% --- Executes during object creation, after setting all properties.
function editLPdataRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLPdataRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editHShigh_Callback(hObject, eventdata, handles)
% hObject    handle to editHShigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHShigh as text
%        str2double(get(hObject,'String')) returns contents of editHShigh as a double


% --- Executes during object creation, after setting all properties.
function editHShigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHShigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editHSlow_Callback(hObject, eventdata, handles)
% hObject    handle to editHSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHSlow as text
%        str2double(get(hObject,'String')) returns contents of editHSlow as a double


% --- Executes during object creation, after setting all properties.
function editHSlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLPhigh_Callback(hObject, eventdata, handles)
% hObject    handle to editLPhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLPhigh as text
%        str2double(get(hObject,'String')) returns contents of editLPhigh as a double


% --- Executes during object creation, after setting all properties.
function editLPhigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLPhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLPlow_Callback(hObject, eventdata, handles)
% hObject    handle to editLPlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLPlow as text
%        str2double(get(hObject,'String')) returns contents of editLPlow as a double


% --- Executes during object creation, after setting all properties.
function editLPlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLPlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLPpattern_Callback(hObject, eventdata, handles)
% hObject    handle to editLPpattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLPpattern as text
%        str2double(get(hObject,'String')) returns contents of editLPpattern as a double


% --- Executes during object creation, after setting all properties.
function editLPpattern_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLPpattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editHSpattern_Callback(hObject, eventdata, handles)
% hObject    handle to editHSpattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHSpattern as text
%        str2double(get(hObject,'String')) returns contents of editHSpattern as a double


% --- Executes during object creation, after setting all properties.
function editHSpattern_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHSpattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonDisplay.
function pushbuttonDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
doDownload(handles, 'display');


% --- Executes on button press in pushbuttonInit.
function pushbuttonInit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMsgBox = msgbox('Deskewing AWGs. Please wait...', 'Please wait...', 'replace');
result = doDownload(handles, 'init');
if (isempty(result))
    set(handles.pushbuttonDownload, 'Enable', 'on');
end
try
    close(hMsgBox);
catch
end


% --- Executes on button press in pushbuttonDownload.
function pushbuttonDownload_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDownload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMsgBox = msgbox('Downloading Waveforms. Please wait...', 'Please wait...', 'replace');
doDownload(handles, 'run');
try
    close(hMsgBox);
catch
end


function result = doDownload(handles, cmd)
clear dParam;
sampleRate = evalin('base', get(handles.editSampleRate, 'String'));
dParam.lpDataRate = evalin('base', get(handles.editLPdataRate, 'String'));
dParam.hsDataRate = evalin('base', get(handles.editHSdataRate, 'String'));
dParam.lpLow = evalin('base', get(handles.editLPlow, 'String'));
dParam.hsLow = evalin('base', get(handles.editHSlow, 'String'));
dParam.lpHigh = evalin('base', get(handles.editLPhigh, 'String'));
dParam.hsHigh = evalin('base', get(handles.editHShigh, 'String'));
if (get(handles.checkboxLPenable, 'Value'))
    dParam.lpPattern = evalin('base', ['[' get(handles.editLPpattern, 'String') ']']);
else
    dParam.lpPattern = [];
end
dParam.hsPattern = evalin('base', ['[' get(handles.editHSpattern, 'String') ']']);
dParam.lpTT = evalin('base', ['[' get(handles.editLPtt, 'String') ']']);
dParam.hsTT = evalin('base', ['[' get(handles.editHStt, 'String') ']']);
dParam.lpIsi = evalin('base', ['[' get(handles.editLPisi, 'String') ']']);
dParam.hsIsi = evalin('base', ['[' get(handles.editHSisi, 'String') ']']);
dParam.lpJitter = evalin('base', ['[' get(handles.editLPjitter, 'String') ']']);
dParam.hsJitter = evalin('base', ['[' get(handles.editHSjitter, 'String') ']']);
dParam.lpJitterFreq = evalin('base', ['[' get(handles.editLPjitterFreq, 'String') ']']);
dParam.hsJitterFreq = evalin('base', ['[' get(handles.editHSjitterFreq, 'String') ']']);
dParam.DelayA = evalin('base', ['[' get(handles.editDelayA, 'String') ']']) * 1e-12;
dParam.DelayB = evalin('base', ['[' get(handles.editDelayB, 'String') ']']) * 1e-12;
dParam.DelayC = evalin('base', ['[' get(handles.editDelayC, 'String') ']']) * 1e-12;
dParam.scopeMode = get(handles.popupmenuScopeMode, 'Value');
if (~isempty(dParam.lpPattern) && dParam.scopeMode == 3)
    errordlg({'For Eye Diagram display, please turn off the "Transmit LP pattern"' ...
        'checkbox and re-download'});
    result = 0;
    return;
end
result = dphy('sampleRate', sampleRate, 'cmd', cmd, 'dParam', dParam);


function editSampleRate_Callback(hObject, eventdata, handles)
% hObject    handle to editSampleRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSampleRate as text
%        str2double(get(hObject,'String')) returns contents of editSampleRate as a double


% --- Executes during object creation, after setting all properties.
function editSampleRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSampleRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editHStt_Callback(hObject, eventdata, handles)
% hObject    handle to editHStt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHStt as text
%        str2double(get(hObject,'String')) returns contents of editHStt as a double


% --- Executes during object creation, after setting all properties.
function editHStt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHStt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLPtt_Callback(hObject, eventdata, handles)
% hObject    handle to editLPtt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLPtt as text
%        str2double(get(hObject,'String')) returns contents of editLPtt as a double


% --- Executes during object creation, after setting all properties.
function editLPtt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLPtt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editHSisi_Callback(hObject, eventdata, handles)
% hObject    handle to editHSisi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHSisi as text
%        str2double(get(hObject,'String')) returns contents of editHSisi as a double


% --- Executes during object creation, after setting all properties.
function editHSisi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHSisi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLPisi_Callback(hObject, eventdata, handles)
% hObject    handle to editLPisi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLPisi as text
%        str2double(get(hObject,'String')) returns contents of editLPisi as a double


% --- Executes during object creation, after setting all properties.
function editLPisi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLPisi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuScopeMode.
function popupmenuScopeMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuScopeMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuScopeMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuScopeMode
if (get(handles.pushbuttonDownload, 'Enable'))
    doDownload(handles, 'scope');
end


% --- Executes during object creation, after setting all properties.
function popupmenuScopeMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuScopeMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxLPenable.
function checkboxLPenable_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxLPenable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxLPenable
val = get(handles.checkboxLPenable, 'Value');
onoff = {'off', 'on'};
oo = onoff{val+1};
set(handles.editLPdataRate, 'Enable', oo);
set(handles.editLPhigh, 'Enable', oo);
set(handles.editLPlow, 'Enable', oo);
set(handles.editLPtt, 'Enable', oo);
set(handles.editLPisi, 'Enable', oo);
set(handles.editLPjitter, 'Enable', oo);
set(handles.editLPjitterFreq, 'Enable', oo);
set(handles.editLPpattern, 'Enable', oo);



function editHSjitter_Callback(hObject, eventdata, handles)
% hObject    handle to editHSjitter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHSjitter as text
%        str2double(get(hObject,'String')) returns contents of editHSjitter as a double


% --- Executes during object creation, after setting all properties.
function editHSjitter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHSjitter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLPjitter_Callback(hObject, eventdata, handles)
% hObject    handle to editLPjitter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLPjitter as text
%        str2double(get(hObject,'String')) returns contents of editLPjitter as a double


% --- Executes during object creation, after setting all properties.
function editLPjitter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLPjitter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuLoadSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqloadsettings(handles);

% --------------------------------------------------------------------
function menuSaveSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqsavesettings(handles);



function editHSjitterFreq_Callback(hObject, eventdata, handles)
% hObject    handle to editHSjitterFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHSjitterFreq as text
%        str2double(get(hObject,'String')) returns contents of editHSjitterFreq as a double


% --- Executes during object creation, after setting all properties.
function editHSjitterFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHSjitterFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLPjitterFreq_Callback(hObject, eventdata, handles)
% hObject    handle to editLPjitterFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLPjitterFreq as text
%        str2double(get(hObject,'String')) returns contents of editLPjitterFreq as a double


% --- Executes during object creation, after setting all properties.
function editLPjitterFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLPjitterFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDelayA_Callback(hObject, eventdata, handles)
% hObject    handle to editDelayA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDelayA as text
%        str2double(get(hObject,'String')) returns contents of editDelayA as a double
delay = [];
try
    delay = evalin('base', get(handles.editDelayA, 'String'));
catch
end
if (~isempty(delay) && isscalar(delay) && delay >= 0 && delay <= 10000)
    set(handles.editDelayA, 'BackgroundColor', 'white');
else
    set(handles.editDelayA, 'BackgroundColor', 'red');
end

% --- Executes during object creation, after setting all properties.
function editDelayA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDelayA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function editDelayB_Callback(hObject, eventdata, handles)
% hObject    handle to editDelayB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDelayB as text
%        str2double(get(hObject,'String')) returns contents of editDelayB as a double


% --- Executes during object creation, after setting all properties.
function editDelayB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDelayB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDelayC_Callback(hObject, eventdata, handles)
% hObject    handle to editDelayC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDelayC as text
%        str2double(get(hObject,'String')) returns contents of editDelayC as a double


% --- Executes during object creation, after setting all properties.
function editDelayC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDelayC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
