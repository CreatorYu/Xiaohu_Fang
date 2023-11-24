function [M1_read,M2_read, M3_read, M4_read] = fun_MarkerCapture_UXA (Address)
% clc
% clear
% path(pathdef); % Res ets the paths to remove paths outside this folder
% addpath(genpath('C:\Program Files (x86)\IVI Foundation\IVI\Components\MATLAB')) ;
% path('C:\Documents\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Signals',path)
% path('C:\Documents\Xiaohu_Fang\EmRG_Code\TX_Calibration\Instrument_Functions\SignalCapture_UXA',path)
% addpath(genpath('C:\Documents\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411')) ;
% addpath(genpath(pwd))%Automatically Adds all paths in directory and subfolders
% UXAAdd=18;
% Address =  'GPIB0::18::INSTR';  
%     Attenuation = num2str(Atten);
%     digital_IF_BW = num2str(Fsample);

    obj.handle = {};
    obj.Address = Address;

    saCfg.connected = 1 ;
    saCfg.connectionType = 'visa';
    saCfg.visaAddr = [num2str(Address)] ;
    saCfg.useListSweep = 0 ;
    saCfg.useMarker = 0 ;
    saCfg.InputBufferSize = 10e9;
    % Test connection
    obj1 = iqopen(saCfg);
    fclose(obj1);
    obj1 = obj1(1);

    obj.handle = obj1;

    obj.handle.Timeout = 5;

    obj.OnOff = false;
    obj.scale_type = '';
    obj.Initialized = true;
    try 
        fopen(obj.handle);
        fprintf(obj.handle,'INITiate:SANalyzer')  % intialiate the spectrum analyzer mode
        % read y values of markers
        M1_read=query(obj.handle,':CALCulate:MARKer1:Y?'); 
        M2_read=query(obj.handle,':CALCulate:MARKer2:Y?'); 
        M3_read=query(obj.handle,':CALCulate:MARKer3:Y?'); 
        M4_read=query(obj.handle,':CALCulate:MARKer4:Y?'); 
        M1_read=str2num(M1_read);
        M2_read=str2num(M2_read);
        M3_read=str2num(M3_read);
        M4_read=str2num(M4_read);
        %
  %      fscanf(obj.handle); %removes the terminator character
        
        % Close the connection to the UXA
        fclose(obj.handle);
    catch
        warning('Problem during capture IQ, please check memory.')
        fclose(obj.handle);
    end
end
                        
