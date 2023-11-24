clear
clc
close all
clearvars

path(pathdef); % Res ets the paths to remove paths outside this folder
addpath(genpath('C:\Program Files (x86)\IVI Foundation\IVI\Components\MATLAB')) ;
path('C:\Documents\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Signals',path)
path('C:\Documents\Xiaohu_Fang\EmRG_Code\TX_Calibration\Instrument_Functions\SignalCapture_UXA',path)
addpath(genpath('C:\Documents\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411')) ;
addpath(genpath(pwd))%Automatically Adds all paths in directory and subfolders

SG=SignalGenerator_E8267D(19,-25);
p_sg=-31;
PM = PowerMeter_N1911A(15);
PS_m = PowerSupply_N6705A(5);
PS_a = PowerSupply_F3643A(7);
ATN=Attenuator('Attenuator_Coupler_4_8GHz_2.s2p');
%
SG.connect;
PM.connect;
PS_m.connect;
PS_a.connect;
%
% preset the signal generator and power meter 
% SG.preset;
PM.preset;
%
%

PS_m_chan=1
Fcarrier=4.7e9;
FsampleAWG            = 0.4e9; 
AWG_AutoNorm		  = false;   % choose weather to normalize IQ data sending to the DAC
AWG_Gain       = 0.5;    % between 0.35 - 0.5;
I_offset  = 0;
Q_offset = 0;

n                   	= (0:7999)';         %  1024 sample points
FBB                 	= FsampleAWG/40;    %  baseband frequency
Amplitude           	= 0.6;

SG.frequency(Fcarrier);
PM.frequency(Fcarrier);
PM.offset(ATN.attenuation(Fcarrier)+0.5);
fprintf('Attenuation at %g Hz is %g dB\n', Fcarrier, ATN.attenuation(Fcarrier)+0.5);
    %PM.offset(0);
PM.zero_and_cal;

%
In_I                	=   cos(2*pi*(FBB/FsampleAWG)*n);
In_Q                	=  0*sin(2*pi*(FBB/FsampleAWG)*n);


BW = 20e6;
% fG = 300e3;
FsampleTx = FsampleAWG;
FrameTime = length(n)/FsampleAWG;
%
PlotSpectrum(In_I, In_Q,In_I, In_Q,1,FsampleTx);


%% APPLY CALIBRAITON
    Cal = load('IQ_Imbalance_M8190_fLO4r7GHz_BW_800MHzFreq_Domain');
    Cal = Cal.TX_CAL_RESULTS;
    iter = 3;
    [I_corr, Q_corr ] = ApplyInverseIQImbalanceFilters(In_I, In_Q, FsampleTx, ...
            Cal(iter).G.G11, Cal(iter).G.G12, Cal(iter).G.G21, Cal(iter).G.G22, Cal(iter).tones, Cal(iter).tones); 
    I_corr = real(I_corr);
    Q_corr = real(Q_corr);
    [I_corr,Q_corr] = setMeanPower(I_corr,Q_corr,0);
    
%% Upconversion the signal to AWG sampling rate    
[UpsampleTx, DownsampleTx] = rat(FsampleAWG/FsampleTx);
In_I_AWG = resample(I_corr, UpsampleTx, DownsampleTx, 500);
In_Q_AWG = resample(Q_corr, UpsampleTx, DownsampleTx, 500);
[In_I_AWG, In_Q_AWG] = setMeanPower(In_I_AWG,In_Q_AWG,0);
[meanPower, maxPower, PAPR_original] = checkPower(In_I_AWG,In_Q_AWG, 1);
PlotSpectrum(In_I_AWG, In_Q_AWG,In_I_AWG, In_Q_AWG,1,FsampleAWG);
        %%


%% AWG8241 transmitting singal
% instrumentHandle = AWG_N8241A_Setup(FsampleAWG, AWG_Gain);
% % Waveform = [In_I' + I_offset; In_Q' + Q_offset];
% Waveform = [I_corr.' + I_offset; Q_corr.' + Q_offset];
% % Upload the waveform and capture the corresponding output on PXA
% AWG_N8241A_SignalUpload(instrumentHandle, Waveform, AWG_AutoNorm);
% agt_awg_close(instrumentHandle);

%% AWG M8190 transmitting singal
% M8190 setting 
PowerBand = 0;
In_I_cal=In_I_AWG;  In_Q_cal=In_Q_AWG;
[In_I_cal, In_Q_cal]              = setMeanPower(In_I_cal, In_Q_cal, PowerBand);      % Set the mean power of the I/Q signals to be uploaded
% [In_I, In_Q]                      = setMeanPower(In_I, In_Q, 0);                      % Set the mean power of the I/Q signals to be used for DPD
% [meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;
[meanPower, maxPower, PAPR_input] = checkPower(In_I_cal, In_Q_cal, 1) ;
Amp_Corr = false;
RF_channel=1;
DAC_SamplingRate=FsampleAWG;
Expansion_Margin=0;
%     ComplexSignal{1}                  = complex(In_I_cal, In_Q_cal);
 %   Fcarrier_array{1}                 = Fcarrier ;
    ComplexSignal{1} = complex(In_I_cal, In_Q_cal);
    Fcarrier_array{1}                 = 0 ;
    FsampleTx_array{1}                = DAC_SamplingRate ;
AWG_M8190A_IQSignalUpload_ChannelSelect_FixedAvgPower(ComplexSignal, Fcarrier_array, FsampleTx_array, DAC_SamplingRate, Amp_Corr, false,RF_channel,Expansion_Margin, PAPR_input, PAPR_original, 0, 0);
AWG_M8190A_Reference_Clk('Backplane');
AWG_M8190A_DAC_Amplitude(1,0.7);
AWG_M8190A_DAC_Amplitude(2,0.7);
AWG_M8190A_MKR_Amplitude(1,1.5);       % Set the trigger amplitude to 1.5 V 
AWG_M8190A_MKR_Amplitude(2,1.5);       % Set the trigger amplitude to 1.5 V 
        %
AWG_M8190A_Output_OFF(1);
AWG_M8190A_Output_OFF(2);
        
%         %         RF_ON_Continue    = 0;
%         [RF_ON_Continue]  = PushButton_Routine (keep_RF_ON,Transmitter_type,ESGAdd,RF_channel);
        
AWG_M8190A_Output_ON(1);
AWG_M8190A_Output_ON(2);

% % Set parameters of PXA 
% FsampleRx=160e6;
% Fs=FsampleRx;
% PXAAdd                = 18;                                       % The GPIB address of the PXA
% PXA_Atten             = 10;                                       % The mechanical attenuation in dB for the PXA when dowloading the signal. From 6 to 24 with steps of 2 dB
% % Capture data using PXA
% [RecI_captured, RecQ_captured] = IQCapture_with_atten (Fcarrier, FsampleRx, FrameTime, PXAAdd, PXA_Atten);

% Set parameters of UXA 
FsampleRx=0.8e9;
Fs=FsampleRx;
UXAAdd                = 'GPIB0::18::INSTR';                                       % The GPIB address of the PXA
UXA_Atten             = 22;                                       % The mechanical attenuation in dB for the PXA when dowloading the signal. From 6 to 24 with steps of 2 dB
UXA_ClockReference       = 'External';

Psg_test=-40:1:-25;
Np=length(Psg_test);
for i=1:Np
    SG.power(Psg_test(i));
    SG.rf(1);
    SG.modulation_on
    pause(2);
    [M1_read,M2_read, M3_read, M4_read] = fun_MarkerCapture_UXA (UXAAdd);
    IMD3_L(i)=M3_read-M1_read;
    IMD3_U(i)=M4_read-M2_read;
    %% DE measurement
    V_m = PS_m.voltage(PS_m_chan);
    Vg_m = PS_m.voltage(3);
    Vg_a = PS_m.voltage(4);
    I_m(i) = PS_m.current(PS_m_chan);
    V_a = PS_a.voltage;
    I_a(i) = PS_a.current;     
    p_out(i) = PM.measure;
    SG.rf(0);
    SG.modulation_off% measurement end
        
    fprintf('P_out is %2.4f \n', p_out(i));
    fprintf('I_m is %2.4f \n', I_m(i));
    fprintf('I_a is %2.4f \n', I_a(i));                        
        
       % gain = p_out-p_in;
 %       fprintf('Gain is %2.4f \n', gain);
        p_out_w(i) = 10^((p_out(i)-30)/10); % p_out in Watts
  %      p_in_w = 10^((p_in-30)/10); % p_in in Watts
        p_dc(i) = (V_m*I_m(i)+V_a*I_a(i));
        DE(i) = 100*p_out_w(i)/p_dc(i);
        fprintf('DE is %3.2f\n', DE(i));
        display([ 'IMD3 (L/U)   = ' num2str(IMD3_L(i)) ' / '  num2str(IMD3_U(i)) ' dB ' ]);

        fprintf('---------------\n');
end
IMD3_L=IMD3_L';
IMD3_U=IMD3_U';
p_out=p_out';
I_m=I_m'*1000;
I_a=I_a'*1000;
DE=DE';
%
%
figure(1)
hold on
plot(p_out,IMD3_L,'-ro','linewidth',1)
plot(p_out,IMD3_U,'-m*','linewidth',1)
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([20,40,-50,-10]);
h=legend('IMD3_Lower','IMD3_Upper');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('IMD3 (dBc)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
%
figure(2)
hold on
plot(p_out,DE,'-ro','linewidth',1)
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([20,40,0,60]);
% h=legend('4.7GHz','4.8GHz','4.9GHz','5.0GHz','5.1GHz','5.2GHz','5.3GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Drain Efficiency','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
%
save('IMD3_4r7GHz.mat','Psg_test','p_out','I_m','I_a','p_dc','p_out_w','DE','IMD3_L','IMD3_U')    
% %% Saving Measurement Results - With DPD
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%% Making measurement directory
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% cd([pwd '\Measurements']);
% time_now = clock;
% dir_name = strcat('5GHz_40MHz',date,'_',int2str(time_now(4)),'_',int2str(time_now(5)),'_',int2str(time_now(6)));
% mkdir(dir_name)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%% Writing files
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd(dir_name)
% %%%% Input signal before DPD
% fidIEH = fopen(['I_Input_1.txt'],'wt');
% fprintf(fidIEH,'%12.20f\n',DelayAdjusted_In_I);
% fclose(fidIEH);
% fidIEH = fopen(['Q_Input_1.txt'],'wt');
% fprintf(fidIEH,'%12.20f\n',DelayAdjusted_In_Q);
% fclose(fidIEH);
% %
% fidIEH = fopen(['I_Output_1.txt'],'wt');
% fprintf(fidIEH,'%12.20f\n',DelayAdjusted_Out_I);
% fclose(fidIEH);
% fidIEH = fopen(['Q_Output_1.txt'],'wt');
% fprintf(fidIEH,'%12.20f\n',DelayAdjusted_Out_Q);
% fclose(fidIEH);
% cd ..
% cd ..
%     
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Saving Measurement Results
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%% Writing files
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd('Measurements')
% cd(dir_name)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%% Wirting Summary file
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fidIEH = fopen(['Summary.txt'],'wt');
% % fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
% fprintf(fidIEH,'Carrier Frequency = %4.3f GHz \n ',Fcarrier/1e9);
% fprintf(fidIEH,'Signal BW = %4.3f MHz \n ',BW/1e6);
% fprintf(fidIEH,['Signal Name (I) = ',InI_beforeDPD_path, '\n ']);
% fprintf(fidIEH,['Signal Name (Q) = ',InQ_beforeDPD_path, '\n ']);
% % fprintf(fidIEH,'ESG/PSG Power = %4.3f \n ',PowerBand);
% fprintf(fidIEH,'DPD sampling rate = %4.3f MHz \n ',Fs/1e6);
% fprintf(fidIEH,'Main gate bias = %4.3f V \n ',-Vg_m);
% fprintf(fidIEH,'Aux. gate bias = %4.3f V \n ',-Vg_a);
% % fprintf(fidIEH,'Internal Rx down/upsampling rate = %4.3f / %4.3f \n ',DownsampleRx,UpsampleRx);
% % fprintf(fidIEH,'Internal Tx down/upsampling rate = %4.3f / %4.3f \n ',DownsampleTx,UpsampleTx);
% % fprintf(fidIEH,'DPD Iteration = %4.3f \n ',IterationCount);
% 
% fprintf(fidIEH,'\nWithout DPD Results \n ');
% fprintf(fidIEH,'EVM (%%) = %4.3f \n ',EVM_perc);   
% fprintf(fidIEH,'ACLR_L/ACLR_U = %4.3f / %4.3f \n ',ACLR_L,ACLR_U);
% fprintf(fidIEH,'ACPR_L/ACPR_U = %4.3f / %4.3f \n ',ACPR_L,ACPR_U);
% fprintf(fidIEH,'PAPRin = %4.3f \n ',PAPRin);
% fprintf(fidIEH,'PAPRout = %4.3f \n ',PAPRout);
% 
% % if strcmp(Measure_Pout_Eff,'True')
% %     fprintf(fidIEH,'\n');
% %     fprintf(fidIEH,'With DPD Measurements');
% %     fprintf(fidIEH,'\nPout  = %4.3f   dBm ', Pout_measured_with_DPD);
% %     fprintf(fidIEH,'\nVdd   = %4.3f   V', V_m_with_DPD);
% %     fprintf(fidIEH,'\nIdd   = %4.3f   mA', I_m_with_DPD*1e3);
% %     fprintf(fidIEH,'\nDE    = %4.3f  %',DE_measured_with_DPD);
% %     fprintf(fidIEH,'\nPAE   =        %');
% fprintf(fidIEH,'\n');
% fprintf(fidIEH,'Without DPD Measurements');
% fprintf(fidIEH,'\nPin of PSG  = %4.3f   dBm ', p_sg);
% fprintf(fidIEH,'\nPout  = %4.3f   dBm ', p_out);
% fprintf(fidIEH,'\nVdd   = %4.3f   V', V_m);
% fprintf(fidIEH,'\nIddm   = %4.3f   mA', I_m*1e3);
% fprintf(fidIEH,'\nIdda   = %4.3f   mA', I_a*1e3);
% fprintf(fidIEH,'\nDE    = %4.3f  %',DE);
% fprintf(fidIEH,'\nPAE   =        %');
% % else
% %     fprintf(fidIEH,'\n');
% %     fprintf(fidIEH,'\nPout   =        dBm ');
% %     fprintf(fidIEH,'\nVdd    = 28     V');
% %     fprintf(fidIEH,'\nIdd    =        mA');
% %     fprintf(fidIEH,'\nDE     =        %');
% %     fprintf(fidIEH,'\nPAE    =        %');
% % end
% fclose(fidIEH);
% cd ..
% cd ..
