clc
clear
close all

%% 添加路径
path(pathdef); % Resets the paths to remove paths outside this folder
path('D:\Matlab\Xiaohu_Fang\MATLAB\CW_Automation_08_15_2017',path);
path('D:\Matlab\Xiaohu_Fang\MATLAB\IQ_imbalance_cal_results',path);
path('D:\Matlab\Xiaohu_Fang\EmRG_Code\TX_Calibration\Instrument_Functions\SignalCapture_UXA',path)
path('D:\Matlab\Xiaohu_Fang\MATLAB',path)
path('D:\Matlab\DPD_2022_09\RsMatlabToolkit_24',path);
path('D:\Matlab\DPD_2022_09\RsMatlabToolkit_24\Examples',path);
path('D:\Matlab\DPD_2022_09',path);
path('D:\Matlab\DPD_2022_09\MATLAB_directSCPI_Examples_5.0',path);
path('D:\Matlab\Xiaohu_Fang\EmRG_Code\TX_Calibration\IQ_Imbalance_CalResults',path);
addpath(genpath(pwd))%Automatically Adds all paths in directory and subfolders
addpath(genpath('D:\Matlab\Xiaohu_Fang\MATLAB\Instrument_Functions'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('E:\matlab\bin\CODE\mycode\data');
addpath('E:\matlab\bin\CODE\mycode\fun_lab');


%% Set signal parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Num_points = 15361;
Center_F=2.5*1e6;
Channel_F=[-5.3 0 5.3]*1e6;
BW = 5e6;
%Samplerate = 30.72e6;                                                         %采样频率设置为30.72MHz

Fsample_desired  = 2.5*BW;     % The sampling rate of the DPD modeing. Fsample_desired < FsampleRx
FsampleTx        = 1000e6;         % The sampling rate of the I/Q input files - In 'ESG' mode the sampling clock of the ESG will be set to the same value       %to be linked to signal
FsampleRx        = 1000e6;         % The sampling rate of the receiver (max 160MHz)
Fs = Fsample_desired;               %
FramTime  = Num_points/(Fs);      % Total frame time for the modulated signal
NofIteration     = 20;            % Maximum # of DPD Iterations
WaveformName     = 'WCDMA3C';     % The waveform name - Only used when uploading signal to ESG

PowerBand = 0;           % Power in dBm for ESG (In case of high speed AWG, the power is controlled using VFS)

Expansion_Margin = 0;           % Used for high speed AWG only. It is used to maintain the average power of AWG when the PAPR of the pre-distorted signal increases.

j = sqrt(-1);
% I1 = importdata('LTE_5MHz_In_I_30_72r0_PAPR_9r0_0_5ms.txt');                %加载同相输入信号I1
% Q1 = importdata('LTE_5MHz_In_Q_30_72r0_PAPR_9r0_0_5ms.txt');                %加载正交输入信号Q1
% IQ_sample=I1+j*Q1;                                                          %得到正交调制信号IQ_Sample=I1+j*Q1
% N_sample=length(IQ_sample);                                                 %获取已调信号的长度
% IQ_start=IQ_sample(1:N_sample);                                             %将已调信号注入到变量IQ_start中
% 
% t1=load('DPD_Mea_Indirect_Learning_Phase_cal_20.mat','X1');                 %加载文件.mat 中的变量X1；并将其加载到结构体(struct)数组t1当中
% Xt1=t1.X1;                                                                  %调用结构体数组（单元）ti中的数据X1
% Pin_Xt= fun_Power_cal(Xt1);                                                 %Xt的功率是X1的平均功率！！！！！！！！
% 
% P_IQload= fun_Power_cal(IQ_start);                                          %计算已调信号IQ_start的功率（dBm）
% X1=fun_Power_scale(Pin_Xt,P_IQload,IQ_start);                               %将IQ_start放缩到abs(Xt1)/abs(IQ_start)倍
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load inputdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%In_I_beforeDPD = load(['Signals\' InI_beforeDPD_path]);
In_I_beforeDPD = importdata('LTE_5MHz_In_I_30_72r0_PAPR_9r0_0_5ms.txt'); In_I_beforeDPD = In_I_beforeDPD(:, 1);
%In_Q_beforeDPD = load(['Signals\' InQ_beforeDPD_path]); 
In_Q_beforeDPD = importdata('LTE_5MHz_In_Q_30_72r0_PAPR_9r0_0_5ms.txt'); In_Q_beforeDPD = In_Q_beforeDPD(:, 1);

min_size = min([ size(In_I_beforeDPD,1) size(In_I_beforeDPD,1)]);

if min_size > round(FramTime*Fs) + 0
    min_size = round(FramTime*Fs) + 0;
end
In_I_beforeDPD = In_I_beforeDPD(1:min_size);
In_Q_beforeDPD = In_Q_beforeDPD(1:min_size);

% %% PAPR reduction
% In_I=In_I_beforeDPD;
% In_Q=In_Q_beforeDPD;
% In_ori = complex(In_I,In_Q);
% %Lower the noise floor
% for i = 1:10
%     Y = LimitPAPR(In_ori, PAPR_limit);
% %     CheckPower(Y, 1);
% 
%     Y_filtered= digital_lpf(Y, FsampleTx, BW/2);
%     %CheckPower(Y_filtered, 1);
%     In_ori = Y_filtered;
% end
% ps(In_ori, FsampleTx)
% In_ori = digital_lpf(In_ori,FsampleTx, BW / 2);
% In_I = real(In_ori); In_Q = imag(In_ori); 
% In_I_beforeDPD=In_I;   In_Q_beforeDPD=In_Q;

[In_I_beforeDPD, In_Q_beforeDPD] = setMeanPower(In_I_beforeDPD, In_Q_beforeDPD, 0) ;
[meanPower, maxPower, PAPR_original] = checkPower(In_I_beforeDPD, In_Q_beforeDPD, 1) ;

Vdd_beforeDPD = abs(complex(In_I_beforeDPD, In_Q_beforeDPD));

% [UpsampleTx, DownsampleTx] = rat(FsampleTx/Fs);
% In_I_beforeDPD_EVM = resample(In_I_beforeDPD,UpsampleTx,DownsampleTx);
% In_Q_beforeDPD_EVM = resample(In_Q_beforeDPD,UpsampleTx,DownsampleTx);
In_I_beforeDPD_EVM=In_I_beforeDPD;
In_Q_beforeDPD_EVM=In_Q_beforeDPD;
data_length = length(In_I_beforeDPD);

disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([' The length of the signals   = ',num2str(data_length)]);
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

In_I = In_I_beforeDPD;
In_Q = In_Q_beforeDPD;

PAPR_in_record=zeros(NofIteration,1); PAPR_out_record=zeros(NofIteration,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Connection of everything
I_offset  = 0;
Q_offset = 0;

Amp_Corr = false;                  % amplitude correction for the AWG (set to true - recommended)
mem_truncate = 0;                   %truncate————截断、删节
keep_RF_ON = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set DPD Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 DPD_type = 'Volterra_DDR';
% DPD_type = 'RF_Volterra'; 
% DPD_type = 'MP';
% DPD_type = 'APD';
% DPD_type = 'FIR_APD';
% DPD_type = 'AUG_MP';
% DPD_type = 'RF_MP';
switch DPD_type
    case {'Volterra_DDR_ET', 'Volterra_DDR'}
        %%%%% Volterra DDR ET parameters
        VolterraParameters.ModifiedKernels = false;
        VolterraParameters.ModifiedFile    = 'kernelsML.txt' ;
        VolterraParameters.DDR             = true ;
        VolterraParameters.DDRorder        = 2 ;
        %   VolterraETParameters.Order         = [ h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 ] ;
        VolterraParameters.Order           = [ 9  0  7  0  5  0  3  0  1  0   0   ] ;%[ 7  0  5  0  3  0  0  0  0  0   0   ] ;
        VolterraParameters.Static          = 9 ;
        % @Anik: experimental code for wide BW signals
        VolterraParameters.Step            = 1 ;
        if strcmp(DPD_type,'Volterra_DDR')
            VolterraParameters.NSupply = 1 ;
        elseif strcmp(DPD_type,'Volterra_DDR_ET')
            VolterraParameters.NSupply = 1 ;
        end
    case {'RF_Volterra', 'RF_Volterra_ET'}
        RF_Volterra_Parameters.memory_lag=1;
        RF_Volterra_Parameters.embedding_dimension=3 ;
        RF_Volterra_Parameters.M1=3;
        RF_Volterra_Parameters.M3=2;
        RF_Volterra_Parameters.M5=1;
        RF_Volterra_Parameters.M7=0;
        RF_Volterra_Parameters.NL=9 ;
        RF_Volterra_Parameters.carrier_frequency=2*pi*Fcarrier;
        RF_Volterra_Parameters.NSupply=1 ;
    case {'MP', 'AUG_MP'}
        MP_modelParam.N = 7;
        MP_modelParam.M = 1;
        MP_modelParam.Gamma = 0;
        MP_modelParam.type = 'odd_even';  %type = 'odd' or 'odd_even'
    case 'APD'
        APD_modelParam.N = 9;
        APD_modelParam.M = 5;
        APD_modelParam.FIR_M = 5;
        APD_modelParam.architecture = 'multiply'; % 'add' or 'multiply';
        % Supported Mode MP, H_EMP, Mod_H_EMP, CRV, ECRV, ECRV_Pruned
		% Currently not supported UB_MP, NB_EMP, Mod_NB_EMP, Deriv_MP
        APD_modelParam.engine = 'Mod_H_EMP';
        APD_modelParam.polyorder = 'odd_aug'; % 'odd' or 'odd_even' or 'odd_aug'
        APD_modelParam.two_step = 1;
    case 'FIR_APD'
        FIR_APD_modelParam.APD_N = 13;
        FIR_APD_modelParam.APD_M = 9;
        FIR_APD_modelParam.FIR_M = 9;
        FIR_APD_modelParam.architecture = 'multiply'; % 'add' or 'multiply';
        % Supported Mode MP, H_EMP, Mod_H_EMP, CRV, ECRV, ECRV_Pruned
		% Currently not supported UB_MP, NB_EMP, Mod_NB_EMP, Deriv_MP
        FIR_APD_modelParam.engine = 'H_EMP';
        FIR_APD_modelParam.polyorder = 'odd_aug'; % 'odd' or 'odd_even' or 'odd_aug'
        FIR_APD_modelParam.two_step = 1;
        FIR_APD_modelParam.use_parallel_FIR = 1;
        FIR_APD_modelParam.use_NL = 0;
    case 'RF_MP'
        RFMP_Param.m_num = 3;
        RFMP_Param.m_den = 1;
        RFMP_Param.n_num = 9;
        RFMP_Param.n_den = 1;
        RFMP_Param.mod_num = 0;   % 0 = odd_even; 1 = even_only; 2 = odd_only
        RFMP_Param.mod_den = 0;   % 0 = odd_even; 1 = even_only; 2 = odd_only
        Param_array = [RFMP_Param.m_num, RFMP_Param.m_den, RFMP_Param.n_num ...
            RFMP_Param.n_den, RFMP_Param.mod_num, RFMP_Param.mod_den];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% DPD Iteration loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for IterationCount = 1:NofIteration
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Iteration nb ',num2str(IterationCount), ' out of ', num2str(NofIteration)]);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    [UpsampleTx, DownsampleTx] = rat(FsampleTx/Fs);
    In_I_cal = resample(In_I,UpsampleTx,DownsampleTx);
    In_Q_cal = resample(In_Q,UpsampleTx,DownsampleTx);
 %   In_I_cal = In_I; In_Q_cal = In_Q;
    NofSamples=length(In_I_cal);
    
    SignalName                        = [WaveformName, num2str(IterationCount)];
    [In_I_cal, In_Q_cal]              = setMeanPower(In_I_cal, In_Q_cal, PowerBand);      % Set the mean power of the I/Q signals to be uploaded
    [In_I, In_Q]                      = setMeanPower(In_I, In_Q, 0);                      % Set the mean power of the I/Q signals to be used for DPD
    [meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;  % Check the PAPR of the input file to be uploaded to the transmitter
  norm_fact = 10^(-Expansion_Margin/20)*10^((PAPR_input - PAPR_original)/20) ;  
  PAPR_in_record(IterationCount)= PAPR_input;
  %  input_power=p_sg+PAPR_original-PAPR_input;
  input_power = p_sg;
  %     
 %% Apply calibration
%         [I_corr, Q_corr ] = ApplyInverseIQImbalanceFilters(In_I_cal, In_Q_cal, FsampleTx, ...
%             Cal(iter).G.G11, Cal(iter).G.G12, Cal(iter).G.G21, Cal(iter).G.G22, Cal(iter).tones, Cal(iter).tones); 
%         I_corr = real(I_corr);
%         Q_corr = real(Q_corr);
%         [I_corr,Q_corr] = setMeanPower(I_corr,Q_corr,0);
%         [meanPower, maxPower, PAPR_input] = checkPower(I_corr, Q_corr, 1)
%     
    

 %   Fcarrier_array{1}                 = Fcarrier ;
    Fcarrier_array{1}                 = 0 ;
    FsampleTx_array{1}                = FsampleTx ;
   % In_I_cal=I_corr;  In_Q_cal=Q_corr;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Uploading the signal
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     fun_SMW200A_IQ_upload (In_I_cal, In_Q_cal, input_power,  Fcarrier, FsampleTx, ESGAdd);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Downloading the output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     elseif strcmp(Receiver_type, 'UXA')
%     [RecI_captured, RecQ_captured] = IQCapture_UXA (Fcarrier, FsampleRx/1.25, FramTime, UXAAdd, UXA_Atten, UXA_ClockReference);
% 
% In_I = In_I_cal;
%  In_Q = In_Q_cal;
% IQ = MATLAB_directSCPI_Specan_IQ_Display_example(IP,Freq,RefLev,FsampleRx,NofSamples);
% IQ=double(IQ);
IQ2=zeros(Nsample,floor(NofSamples));
IQ1 = MATLAB_directSCPI_Specan_IQ_Display_example(IP,Freq,RefLev,FsampleRx,Nsample*NofSamples);
MATLAB_directSCPI_Specan_ACLR_Display(IP_2,Freq);
%MATLAB_directSCPI_Specan_VSA_Display(IP);
for i=1:Nsample
    IQ2(i,:)=IQ1((i-1)*floor(NofSamples)+1:i*floor(NofSamples));
end
IQ3=mean(IQ2); 
%
IQ=double(IQ3);
%
ResampledRecI = real(IQ(200:end));
ResampledRecQ = imag(IQ(200:end));
ResampledRecI = ResampledRecI';
ResampledRecQ = ResampledRecQ';
[meanPower_FSW, maxPower_FSW, PAPR_FSW]=checkPower_50(ResampledRecI, ResampledRecQ,1);
%
PAPR_out_record(IterationCount)= PAPR_FSW;
[UpsampleRx, DownsampleRx] = rat(Fs/FsampleRx);
    ResampledRecI = resample(ResampledRecI,UpsampleRx,DownsampleRx,100);
    ResampledRecQ = resample(ResampledRecQ,UpsampleRx,DownsampleRx,100);
    Out_Resampled = complex(ResampledRecI,ResampledRecQ);


    ResampledRecI = ResampledRecI(200:end);
    ResampledRecQ = ResampledRecQ(200:end);

%
     if strcmp (Measure_Pout_Eff,'True')       
%         V_m_with_DPD = PS_m.voltage(PS_m_chan);
%         I_m_with_DPD = PS_m.current(PS_m_chan);
%         V_a_with_DPD = PS_a.voltage;
%         I_a_with_DPD = PS_a.current;
%         Pout_measured_with_DPD = PM.measure;
%         Pdc_measured_with_DPD  = V_m_with_DPD*I_m_with_DPD+V_a_with_DPD*I_a_with_DPD;
%         DE_measured_with_DPD = 100*10^((Pout_measured_with_DPD-30)/10) / Pdc_measured_with_DPD;
         Pout_NRPZ86 = MATLAB_directSCPI_NRPZxx_Avg_Power_my(Fcarrier);        
         %Mea_DC=PowerSupply_DP821A(DP821A_IP);
         V_a_with_DPD = 0;
         I_a_with_DPD = 0;
         V_m_with_DPD = 28;
         I_m_with_DPD = fun_PowerSupply_HMP2030(HMP2030_IP)-0.001;
         %Pout_measured_with_DPD = meanPower_FSW-Mea_Attenuator_SLCG(Fcarrier)+0.2;
         Pout_measured_with_DPD = Pout_NRPZ86-Mea_Attenuator_MMWave(Freq);
         Pdc_measured_with_DPD  = V_m_with_DPD*I_m_with_DPD+V_a_with_DPD*I_a_with_DPD;
         DE_measured_with_DPD = 100*10^((Pout_measured_with_DPD-30)/10) / Pdc_measured_with_DPD;
     end
%     if strcmp(Transmitter_type,'AWG')
% %         AWG_M8190A_Output_OFF(1);
% %         AWG_M8190A_Output_OFF(2);
%         SG.rf(0);
%         SG.modulation_off% measurement end
%     elseif strcmp(Transmitter_type,'ESG')
%         ESG_RF_OFF_SingleCarrier(ESGAdd)
%     elseif strcmp(Transmitter_type,'AWG_N8241A')
%             SG.rf(0);
%             SG.modulation_off% measurement end
%     end
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Delay Adjustment and analyzing the signal
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    In_I = resample(In_I,UpsampleTx,DownsampleTx);
%    In_Q = resample(In_Q,UpsampleTx,DownsampleTx);
    
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Input Signal']);
    checkPower(In_I, In_Q,1);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Output Signal']);
    checkPower(ResampledRecI, ResampledRecQ,1);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    
    [In_I, In_Q, ResampledRecI, ResampledRecQ]  = AdjustPowerAndPhase(In_I, In_Q, ResampledRecI, ResampledRecQ, 0);
%     [In_I, In_Q, out_I1, out_Q1]                = UnifyLength(In_I, In_Q, ResampledRecI, ResampledRecQ);
    [In_I, In_Q, out_I1, out_Q1]                = UnifyLength(In_I, In_Q, ResampledRecI, ResampledRecQ);
    
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay(In_I, In_Q, out_I1, out_Q1,Fs,2000) ;
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;

%    PlotGain(Pr_I, Pr_Q, Pr_I_up, Pr_Q_up)
%  PlotAMPM(Pr_I, Pr_Q, Pr_I_up, Pr_Q_up) ;

    [EVM_dB EVM_perc] = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);
    
    % Downsample the recieved data to 5*BW to get the correct ACLR and ACPR 
    [UpsampleACP, DownsampleACP] = rat(Fs/Fs);
     OUT_I_ACP = resample(DelayAdjusted_Out_I, UpsampleACP, DownsampleACP, 500);
     OUT_Q_ACP = resample(DelayAdjusted_Out_Q, UpsampleACP, DownsampleACP, 500);
         % Remove the spurious
     sig  = complex(OUT_I_ACP(1:9000), OUT_Q_ACP(1:9000));
 %  ps(sig, FsampleRx);
    sig_nospurs = remove_spurious_specific(sig, 2.5*BW, [0 0]);
 %  ps(sig_nospurs, FsampleRx)
    OUT_I_ACP=real(sig_nospurs);
    OUT_Q_ACP=imag(sig_nospurs);
%     PlotSpectrum(In_I, In_Q,ResampledRecI, ResampledRecQ,1,FsampleTx);
     
     [OUT_I_ACP, OUT_Q_ACP] = setMeanPower(OUT_I_ACP,OUT_Q_ACP,0);
     PlotSpectrum(In_I_beforeDPD, In_Q_beforeDPD,OUT_I_ACP, OUT_Q_ACP);
    
    [freq, spectrum] = Calculated_Spectrum(OUT_I_ACP, OUT_Q_ACP, 2.5*BW);
    [ACLR_L, ACLR_U] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
    [ACPR_L, ACPR_U] = Calculate_ACPR (freq, spectrum, 0, BW, fG);
    
    [DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM, timedelay_EVM]   = AdjustDelay(In_I_beforeDPD_EVM(mem_truncate+1:end), In_Q_beforeDPD_EVM((mem_truncate+1:end)), out_I1, out_Q1,Fs,2000) ;
    [DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM]                     = AdjustPowerAndPhase(DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM, 0) ;
    [DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM]             = AdjustPowerAndPhase(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM, 0) ;
    PlotGain(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
    PlotAMPM(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
    % PlotSpectrum(DelayAdjusted_In_I_EVM, DelayAdjusted_In_Q_EVM, DelayAdjusted_Out_I_EVM, DelayAdjusted_Out_Q_EVM) ;
    
    [EVM_dB EVM_perc] = EVM_calculate (DelayAdjusted_In_I_EVM,DelayAdjusted_In_Q_EVM,DelayAdjusted_Out_I_EVM,DelayAdjusted_Out_Q_EVM);
    
    display([ 'EVM          = ' num2str(EVM_perc)      ' % ' ]);
    display([ 'ACLR (L/U)   = ' num2str(ACLR_L) ' / '  num2str(ACLR_U) ' dB ' ]);
    display([ 'ACPR (L/U)   = ' num2str(ACPR_L) ' / '  num2str(ACPR_U) ' dB ' ]);
    
    [next_iteration, keep_RF_ON]  = ContinueIteration_Routine;
    if (next_iteration == 0)
%         In_I = resample(In_I,DownsampleTx,UpsampleTx);
%         In_Q = resample(In_Q,DownsampleTx,UpsampleTx);
          In_I=In_I;
          In_Q=In_Q;
        break
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %% DPD Identification and Validation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch DPD_type
        case 'Volterra_DDR'
            clear iqdata iqtotaldata
            DPD = true ;
             %        [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , VolterraParameters , NofDPDPoints , DPD ) ;
            VolterraParameters.NSupply = 1 ;
            DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
            [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput, NMSE_error ] = VolterraDpdIdentification_ET ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , circshift(DelayAdjusted_Vdd,0), VolterraParameters , NofDPDPoints , DPD ) ;
            Coeff_DR_real = 20*log10( (max(abs(real(VolterraCoeff))))/(min(abs(real(VolterraCoeff)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(VolterraCoeff))))/(min(abs(imag(VolterraCoeff)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
            num_of_coeff = size(VolterraCoeff,1);
        case 'Volterra_DDR_ET'
            Vdd_shift = 0;
            DPD = true ;
            [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification_ET ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , circshift(DelayAdjusted_Vdd,Vdd_shift), VolterraParameters , NofDPDPoints , DPD ) ;
        case 'Volterra_DDR_Aug'
            DPD = true ;
            [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification_Aug ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , VolterraParameters , NofDPDPoints , DPD ) ;
        case 'RF_Volterra'
            DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
            [Coeff_RF_Volterra, NMSE_error]=Identify_RF_Volterra_v2_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q ,DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
        case 'MP'
            [MP_coefficients, NMSE_error, Cond_A] = Identify_SingleBand_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'APD'
            [APD_coefficients, NMSE_error] = Identify_SingleBand_APD(APD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(APD_coefficients))))/(min(abs(real(APD_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(APD_coefficients))))/(min(abs(imag(APD_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'FIR_APD'
            [FIR_APD_coefficients, NMSE_error] = Identify_SingleBand_FIR_APD(FIR_APD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(FIR_APD_coefficients))))/(min(abs(real(FIR_APD_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(FIR_APD_coefficients))))/(min(abs(imag(FIR_APD_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
            if FIR_APD_modelParam.use_NL == 1
                NonlinearID_In_I = DelayAdjusted_In_I;
                NonlinearID_In_Q = DelayAdjusted_In_Q;
                NonlinearID_Out_I = DelayAdjusted_Out_I;
                NonlinearID_Out_Q = DelayAdjusted_Out_Q;
                %                 [NL_FIR_DPD_coefficients, NL_NMSE_error] = Identify_SingleBand_Cascaded_NLTB(FIR_DPD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints, FIR_DPD_coefficients);
            end
        case 'TwoStep_MP'
            [MP_coefficients, NMSE_error, Cond_A] = Identify_TwoStep_SingleBand_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'Aug_MP'
            [MP_coefficients, gamma, fval, exitflag, NMSE_error, Cond_A] = Identify_SingleBand_Aug_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'RF_MP'
            [num_coeff, den_coeff, NMSE_error, Cond_A] = Identify_SingleBand_RFMP(Param_array, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_num_real = 20*log10( (max(abs(real(num_coeff))))/(min(abs(real(num_coeff)))));
            Coeff_DR_num_imag = 20*log10( (max(abs(imag(num_coeff))))/(min(abs(imag(num_coeff)))));
            Coeff_DR_num = max(Coeff_DR_num_real,Coeff_DR_num_imag);
            Coeff_DR_den_real = 20*log10( (max(abs(real(den_coeff))))/(min(abs(real(den_coeff)))));
            Coeff_DR_den_imag = 20*log10( (max(abs(imag(den_coeff))))/(min(abs(imag(den_coeff)))));
            Coeff_DR_den = max(Coeff_DR_den_real,Coeff_DR_den_imag);
        case 'RF_Volterra_ET'
            DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
            [Coeff_RF_Volterra]=Identify_RF_Volterra_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
            %         [Coeff_RF_Volterra]=Identify_RF_Volterra_v2_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Apply DPD
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch DPD_type
        case 'Volterra_DDR'
            [ Pr_I , Pr_Q ] = VolterraDpdApply_ET ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), VolterraETParameters , VolterraCoeff ) ;
            %         [ Pr_I , Pr_Q ] = VolterraDpdApply ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , VolterraETParameters , VolterraCoeff ) ;
        case 'Volterra_DDR_ET'
            [ Pr_I , Pr_Q ] = VolterraDpdApply_ET ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , Vdd_beforeDPD, VolterraETParameters , VolterraCoeff ) ;
            %         DelayAdjusted_Vdd_beforeDPD
        case 'RF_Volterra'
            [Pr_I , Pr_Q]=Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);
            %         [Pr_I , Pr_Q]=Apply_RF_Volterra(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);
        case 'MP'
            [Pr_I, Pr_Q] = Apply_SingleBand_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients);
        case 'APD'
            [Pr_I, Pr_Q] = Apply_SingleBand_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, APD_modelParam, APD_coefficients);
        case 'FIR_APD'
            [Pr_I, Pr_Q] = Apply_SingleBand_FIR_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, FIR_APD_modelParam, FIR_APD_coefficients);
        case 'Aug_MP'
            [Pr_I, Pr_Q] = Apply_SingleBand_Aug_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients, gamma);
        case 'RF_MP'
            [Pr_I, Pr_Q] = Apply_SingleBand_RFMP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, Param_array, num_coeff, den_coeff);
        case 'RF_Volterra_ET'
            [Pr_I , Pr_Q]=Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, DelayAdjusted_Vdd_beforeDPD, Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);
    end
    % new code
    mem_truncate = length(In_I_beforeDPD_EVM) - length(Pr_I);
    Pr_I_up=Pr_I;
    Pr_Q_up=Pr_Q;
%     Pr_I_up=resample(Pr_I,DownsampleTx,UpsampleTx);
%     Pr_Q_up=resample(Pr_Q,DownsampleTx,UpsampleTx);
    
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp([' Predistorted Signal']);
    checkPower(Pr_I_up, Pr_Q_up,1);
    disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    
    Draw_spectrum (In_I_beforeDPD,In_I_beforeDPD,Pr_I_up,Pr_Q_up);
    In_I = Pr_I_up;
    In_Q = Pr_Q_up;
    close all;
end
