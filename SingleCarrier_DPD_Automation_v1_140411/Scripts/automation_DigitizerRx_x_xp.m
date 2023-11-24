%% First Do iteration with Volterra
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Turn on Connection with Instrument
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type,'Digitizer')
    %     [Digitizer.M9703A_Obj]  =  M9703A_Configuration(Digitizer.M9703A_VisaAddress, Digitizer.ReferenceSource, Digitizer.TriggerSource, Digitizer.TriggerLevel);
    [M9703A_Obj] = M9703A_Configuration(M9703A_VisaAddress, ReferenceSource, TriggerSource, TriggerLevel);
    [M9352A_Obj] = M9352A_Configuration(M9352A_VisaAddress);
    if (DownconversionMode == 1) || (DownconversionMode == 2)
        if strcmp(LO_type,'E4433B')
            E4433B_RF_Configuration (LO_Frequency1, LO_Amplitude, E4433B_Add);
        end
        if ( strcmp(LO_type,'E4438C') || strcmp(LO2_type,'E4438C') )
            if (Automate_LO == 1)
                [E4438C_Obj] = E4438C_Configuration(E4438C_VisaAddress);
            end
        end
    end
end
%% Get the data
% [x_I, x_Q, xp_I, xp_Q] = UnifyLength(In_I_beforeDPD_EVM(mem_truncate+1:end), In_Q_beforeDPD_EVM(mem_truncate+1:end), In_I_withDPD, In_Q_withDPD);
% [x_I, x_Q, xp_I, xp_Q] = UnifyLength(In_I_beforeDPD_EVM(mem_truncate+1:end), In_Q_beforeDPD_EVM(mem_truncate+1:end), Pr_I_up, Pr_Q_up);
[xp_I, xp_Q, x_I, x_Q, timedelay1] = AdjustDelay(In_I_withDPD, In_Q_withDPD, Out_I_withDPD, Out_Q_withDPD, Fs, 2000);
[xp_I, xp_Q, x_I, x_Q]             = AdjustPowerAndPhase(xp_I, xp_Q, x_I, x_Q, 0) ;
dir_name_parent = dir_name;
%% Do Parallel FIR Tests
DPD_type = 'APD';
APD_modelParam.N = 8;
APD_modelParam.M = 4;
APD_modelParam.FIR_M = 4;
APD_modelParam.architecture = 'multiply';
APD_modelParam.polyorder = 'odd_aug';
APD_modelParam.two_step = 1;

% APD_modelParam.engine = 'Static';
% DoDPDTestRunDigitizerRx;
APD_modelParam.engine = 'H_EMP';
DoDPDTestRunDigitizerRx;
APD_modelParam.engine = 'MP';
DoDPDTestRunDigitizerRx;
% APD_modelParam.engine = 'Mod_H_EMP';
% DoDPDTestRunDigitizerRx;
% APD_modelParam.engine = 'Mod_ECRV';
% DoDPDTestRunDigitizerRx;
% APD_modelParam.engine = 'Mod_ECRV_Pruned';
% DoDPDTestRunDigitizerRx;

close all
% Do Series FIR Tests
DPD_type = 'FIR_APD';
FIR_APD_modelParam.APD_N = 8;
FIR_APD_modelParam.APD_M = 4;
FIR_APD_modelParam.FIR_M = 4;
FIR_APD_modelParam.architecture = 'multiply';
FIR_APD_modelParam.polyorder = 'odd_aug';
FIR_APD_modelParam.two_step = 1;
FIR_APD_modelParam.use_parallel_FIR = 1;
FIR_APD_modelParam.use_NL = 1;

FIR_APD_modelParam.engine = 'H_EMP';
DoDPDTestRunDigitizerRx;
% FIR_APD_modelParam.engine = 'ECRV';
% DoDPDTestRunDigitizerRx;
% FIR_APD_modelParam.engine = 'ECRV_Pruned';
% DoDPDTestRunDigitizerRx;

% close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Close Connection with Instrument
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Receiver_type,'Digitizer')
    M9703A_Obj.Close;
    M9352A_Obj.Close;
    if strcmp(LO_type,'E4438C') && Automate_LO == 1
        E4438C_Obj.Close;
    end
    % Turn LO OFF
    %Prompt user to turn LO OFF
    if Automate_LO == 0
        [Continue_Flag] = Confirmation_Dialogue('Is the LO Source turned OFF?','Turn OFF Prompt');
        if Continue_Flag == -1
            if strcmp(Receiver_type,'Digitizer')
                M9703A_Obj.Close;
                M9352A_Obj.Close;
            end
            error('User Abort');
        end
    end
end