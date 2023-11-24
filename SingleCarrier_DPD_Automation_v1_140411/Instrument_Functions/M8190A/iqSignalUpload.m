function varargout = iqSignalUpload(varargin)
% IQSIGNALUPLOAD MATLAB code for iqSignalUpload.fig
%      IQSIGNALUPLOAD, by itself, creates a new IQSIGNALUPLOAD or raises the existing
%      singleton*.
%
%      H = IQSIGNALUPLOAD returns the handle to a new IQSIGNALUPLOAD or the handle to
%      the existing singleton*.
%
%      IQSIGNALUPLOAD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IQSIGNALUPLOAD.M with the given input arguments.
%
%      IQSIGNALUPLOAD('Property','Value',...) creates a new IQSIGNALUPLOAD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iqSignalUpload_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iqSignalUpload_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help iqSignalUpload

% Last Modified by GUIDE v2.5 11-Mar-2014 15:52:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @iqSignalUpload_OpeningFcn, ...
                   'gui_OutputFcn',  @iqSignalUpload_OutputFcn, ...
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


% --- Executes just before iqSignalUpload is made visible.
function iqSignalUpload_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to iqSignalUpload (see VARARGIN)

% Choose default command line output for iqSignalUpload
handles.output = hObject;
hTable=handles.uitableSig;
set(hTable,'Data',[]);

% Update handles structure
guidata(hObject, handles);
checkfields([], 0, handles);

% UIWAIT makes iqSignalUpload wait for user response (see UIRESUME)
% uiwait(handles.iqtool);


% --- Outputs from this function are returned to the command line.
function varargout = iqSignalUpload_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Add_Signal_button.
function Add_Signal_button_Callback(hObject, eventdata, handles)
% hObject    handle to Add_Signal_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hTable=handles.uitableSig;
oldData=get(hTable,'Data');
newRow={'',[],false,[],'',[],false,[]};
newData=[oldData;newRow];
set(hTable,'Data',newData);



% --- Executes on button press in Delete_Signal_button.
function Delete_Signal_button_Callback(hObject, eventdata, handles)
% hObject    handle to Delete_Signal_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hTable=handles.uitableSig;
oldData=get(hTable,'Data');
newData=oldData(1:end-1,:);
set(hTable,'Data',newData);


% --- Executes on button press in Delete_All_Signals_button.
function Delete_All_Signals_button_Callback(hObject, eventdata, handles)
% hObject    handle to Delete_All_Signals_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hTable=handles.uitableSig;
newData=[];
set(hTable,'Data',newData);


% --- Executes on button press in Correction_checkbox.
function Correction_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Correction_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Correction_checkbox


% --- Executes on button press in Show_Correction_button.
function Show_Correction_button_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Correction_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqshowcorr();

function [iqtotaldata fs marker] = readFile(handles)

hTable=handles.uitableSig;
Data=get(hTable,'Data');

for j = 1 : size(Data,1)
    
        iqdata = [];
        fs = 0;
        marker = [];

        filename = Data{j,1};
        correction = get(handles.Correction_checkbox, 'Value');

        err = ['Error opening file: ' filename];
        try

                    data = load(filename);
                    fields = fieldnames(data);
                    err = 'Expected variables not found in mat file';

                    samplesName = fields{1};

                    iqdata = double(eval(['data.' samplesName]));

        %             markerName = strtrim(get(handles.editMarkerName, 'String'));
        %             if (~strcmp(markerName, ''))
        %                 err = sprintf('Variable name for Markers (%s) not found in mat file', markerName);
        %                 marker = eval(['data.' markerName]);
        %             end

        catch e
            errordlg(err, e.message);
            iqdata = [];
            break;
        end
        iqdata = reshape(iqdata, length(iqdata), 1);
        fs=Data{j,2};
        % resample the data if desired
        if Data{j,3}
            methodList = Data{j,5};
        %     method = methodList{get(handles.popupmenuResampleMethod,'Value')};
            method = methodList;
            factor = Data{j,4};
            switch (method)
                case 'Interpolation'; ipfct = @(data,r) interp(double(data), r);
                case 'FFT'; ipfct = @(data,r) interpft(data, r * length(data));
                otherwise error('unknown method');
            end
            try
                iqdata = ipfct(iqdata, factor);
                fs = fs * factor;
            catch ex
                errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
            end
        end
        % shift frequency
        if (Data{j,7})
            fc = Data{j,8};
            n = length(iqdata);
            iqdata = iqdata .* exp(1i*2*pi*(n*fc/fs)/n*(1:n)');
        end
      if j == 1
      iqtotaldata=iqdata;
      else
      iqtotaldata=iqtotaldata+iqdata;
      end
        
end
if (correction)
    iqtotaldata = iqcorrection(iqtotaldata, fs);
end
   marker = [ones(floor(factor*5*2),1); zeros(length(iqtotaldata)-floor(factor*5*2),1)] ;

assignin('base', 'iqtotaldata', iqtotaldata);
assignin('base', 'fs', fs);


% --- Executes on button press in Visualize_in_MATLAB_button.
function Visualize_in_MATLAB_button_Callback(hObject, eventdata, handles)
% hObject    handle to Visualize_in_MATLAB_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[iqtotaldata fs marker] = readFile(handles);
if (~isempty(iqtotaldata))
    iqplot(iqtotaldata, fs, 'marker', marker);
end


% --- Executes on button press in Download_button.
function Download_button_Callback(hObject, eventdata, handles)
% hObject    handle to Download_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMsgBox = msgbox('Downloading Waveform. Please wait...', 'Please wait...');
[iqdata fs marker] = readFile(handles);
if (~isempty(iqdata))
    len = numel(iqdata);
    iqdata = reshape(iqdata, len, 1);
    marker = reshape(marker, numel(marker), 1);
    arbConfig = loadArbConfig();
    rept = lcm(len, arbConfig.segmentGranularity) / len;
    if (rept * len < arbConfig.minimumSegmentSize)
        rept = rept+1;
    end
    segmentNum = 1;
    channelMapping = get(handles.Target_button, 'UserData');
    iqdownload(repmat(iqdata, rept, 1), fs, 'channelMapping', channelMapping, ...
        'segmentNumber', segmentNum, 'marker', repmat(marker, rept, 1));
    assignin('base', 'iqdata', repmat(iqdata, rept, 1));
end
try close(hMsgBox); catch ex; end;


% --- Executes on button press in Target_button.
function Target_button_Callback(hObject, eventdata, handles)
% hObject    handle to Target_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
arbConfig = loadArbConfig();
[val, str] = iqchanneldlg(get(hObject, 'UserData'), arbConfig, handles.iqtool);
if (~isempty(val))
    set(hObject, 'UserData', val);
    set(hObject, 'String', str);
end


% --- Executes during object creation, after setting all properties.
function uitableSig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitableSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes when entered data in editable cell(s) in uitableSig.
function uitableSig_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitableSig (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
if eventdata.Indices(2)==4
   value=eventdata.NewData;
   if (isscalar(value) && value > 0 && value <= 10000)
    calcNewSampleRate(hObject, eventdata, handles);
   else
    errordlg('Factor Should be a scalar between 0 and 10000','Not Valid Entry');
   end

end



function calcNewSampleRate(hObject, eventdata, handles)

hTable=handles.uitableSig;
Data=get(hTable,'Data');
rs = Data{eventdata.Indices(1),3};
if rs
factor=Data{eventdata.Indices(1),4};
else
  factor=1;
end
sampleRate = Data{eventdata.Indices(1),2};
newRate = sampleRate * factor;
Data{eventdata.Indices(1),6}=newRate;
set(hTable,'Data',Data);

arbConfig = loadArbConfig();
if (~rs || ...
    newRate >= arbConfig.minimumSampleRate && ...
    newRate <= arbConfig.maximumSampleRate)

else
    errordlg(['Sampling Rate Should be between ' num2str(arbConfig.minimumSampleRate) ' and ' num2str(arbConfig.maximumSampleRate)],'Sampling Rate out of Range');
end


function result = checkfields(hObject, eventdata, handles)
% This function verifies that all the fields have valid and consistent
% values. It is called from inside this script as well as from the
% iqconfig script when arbConfig changes (i.e. a different model or mode is
% selected). Returns 1 if all fields are OK, otherwise 0
result = 1;
[arbConfig saConfig] = loadArbConfig();
% --- channel mapping
iqchannelsetup('setup', handles.Target_button, arbConfig);
% --- editSampleRate
% value = -1;
% try
%     value = evalin('base', get(handles.editSampleRate, 'String'));
% catch ex
%     msgbox(ex.message);
%     result = 0;
% end
% if (isscalar(value) && value >= arbConfig.minimumSampleRate && value <= arbConfig.maximumSampleRate)
%     set(handles.editSampleRate, 'BackgroundColor', 'white');
% else
%     set(handles.editSampleRate, 'BackgroundColor', 'red');
%     result = 0;
% end
