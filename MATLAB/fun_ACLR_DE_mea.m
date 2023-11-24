function [ACLR_L ACLR_H EVM Im Ia DE]=fun_ACLR_DE_mea[BW fG In_I In_Q FsampleAWG]

% AWG setting
AWG_Gain=0.5;
AWG_AutoNorm=0;
I_offset=0;
Q_offset=0;

SG.power(p_sg);
SG.rf(1);
SG.modulation_on
pause(0.5);
%
% [instrumentHandle ]= AWG_N8241A_TriggerMode_Setup(FsampleAWG, AWG_Gain);
AWG_handle = AWG_N8241A_Setup(FsampleAWG, AWG_Gain);
Waveform = [In_I' + I_offset; In_Q' + Q_offset];
% Upload the waveform and capture the corresponding output on PXA
AWG_N8241A_SignalUpload(AWG_handle, Waveform, AWG_AutoNorm);
agt_awg_close(AWG_handle);
% PXA setting
FsampleRx=160e6;
Fs=FsampleRx;
PXAAdd                = 18;                                       % The GPIB address of the PXA
PXA_Atten             = 16;                                       % The mechanical attenuation in dB for the PXA when dowloading the signal. From 6 to 24 with steps of 2 dB
%
[RecI_captured, RecQ_captured] = IQCapture_with_atten (Fcarrier, FsampleRx, FrameTime, PXAAdd, PXA_Atten);
ResampledRecI = RecI_captured(200:end);
ResampledRecQ = RecQ_captured(200:end);
%
[UpsampleTx, DownsampleTx] = rat(FsampleRx/FsampleAWG);
    In_I = resample(In_I,UpsampleTx,DownsampleTx);
    In_Q = resample(In_Q,UpsampleTx,DownsampleTx);
  %  PlotSpectrum(In_I, In_Q,ResampledRecI, ResampledRecQ,1,FsampleRx);
    
    %
    data_length = length(In_I);
    %
    checkPower(In_I, In_Q,1);
    checkPower(ResampledRecI, ResampledRecQ,1);
    
    [In_I, In_Q, ResampledRecI, ResampledRecQ]  = AdjustPowerAndPhase(In_I, In_Q, ResampledRecI, ResampledRecQ, 0);
    [In_I, In_Q, out_I1, out_Q1]                = UnifyLength(In_I, In_Q, ResampledRecI, ResampledRecQ);
    
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay(In_I, In_Q, out_I1, out_Q1,FsampleRx,2000) ;
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
    [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
 %  PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
 %  PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
 %  PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    
    [EVM_dB EVM_perc] = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);
    [freq, spectrum] = Calculated_Spectrum(DelayAdjusted_Out_I,DelayAdjusted_Out_Q,FsampleRx);
    [ACLR_L, ACLR_U] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
    [ACPR_L, ACPR_U] = Calculate_ACPR (freq, spectrum, 0, BW, fG);
    [meanPower, maxPower, PAPRin] = checkPower(DelayAdjusted_In_I,DelayAdjusted_In_Q,0);
    [meanPower, maxPower, PAPRout] = checkPower(DelayAdjusted_Out_I,DelayAdjusted_Out_Q,0);

       
    display([ 'EVM          = ' num2str(EVM_perc)      ' % ' ]);
    display([ 'ACLR (L/U)   = ' num2str(ACLR_L) ' / '  num2str(ACLR_U) ' dB ' ]);
    display([ 'ACPR (L/U)   = ' num2str(ACPR_L) ' / '  num2str(ACPR_U) ' dB ' ]);
    
%% DE measurement
   V_m = PS_m.voltage(PS_m_chan);
   I_m = PS_m.current(PS_m_chan);
   V_a = PS_a.voltage;
   I_a = PS_a.current;
%     
   p_out = PM.measure;
   SG.rf(0);
   SG.modulation_off% measurement end
        
                      
        
       % gain = p_out-p_in;
 %       fprintf('Gain is %2.4f \n', gain);
        p_out_w = 10^((p_out-30)/10); % p_out in Watts
  %      p_in_w = 10^((p_in-30)/10); % p_in in Watts
        p_dc = (V_m*I_m+V_a*I_a);
        DE = 100*p_out_w/p_dc;
        fprintf('DE is %3.2f\n', DE);
        fprintf('---------------\n');

    
%% Saving Measurement Results - With DPD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Making measurement directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
cd([pwd '\Measurements']);
time_now = clock;
dir_name = strcat('Measurement',date,'_',int2str(time_now(4)),'_',int2str(time_now(5)),'_',int2str(time_now(6)));
mkdir(dir_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Writing files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(dir_name)
%%%% Input signal before DPD
fidIEH = fopen(['I_Input_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',DelayAdjusted_In_I);
fclose(fidIEH);
fidIEH = fopen(['Q_Input_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',DelayAdjusted_In_Q);
fclose(fidIEH);
%
fidIEH = fopen(['I_Output_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',DelayAdjusted_Out_I);
fclose(fidIEH);
fidIEH = fopen(['Q_Output_1.txt'],'wt');
fprintf(fidIEH,'%12.20f\n',DelayAdjusted_Out_Q);
fclose(fidIEH);
cd ..
cd ..
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saving Measurement Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Writing files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd('Measurements')
cd(dir_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Wirting Summary file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fidIEH = fopen(['Summary.txt'],'wt');
% fprintf(fidIEH,['DPD type =  ', DPD_type, '\n ']);
fprintf(fidIEH,'Carrier Frequency = %4.3f GHz \n ',Fcarrier/1e9);
fprintf(fidIEH,'Signal BW = %4.3f MHz \n ',BW/1e6);
fprintf(fidIEH,['Signal Name (I) = ',InI_beforeDPD_path, '\n ']);
fprintf(fidIEH,['Signal Name (Q) = ',InQ_beforeDPD_path, '\n ']);
% fprintf(fidIEH,'ESG/PSG Power = %4.3f \n ',PowerBand);
fprintf(fidIEH,'DPD sampling rate = %4.3f MHz \n ',Fs/1e6);
% fprintf(fidIEH,'Internal Rx down/upsampling rate = %4.3f / %4.3f \n ',DownsampleRx,UpsampleRx);
% fprintf(fidIEH,'Internal Tx down/upsampling rate = %4.3f / %4.3f \n ',DownsampleTx,UpsampleTx);
% fprintf(fidIEH,'DPD Iteration = %4.3f \n ',IterationCount);

fprintf(fidIEH,'\nWithout DPD Results \n ');
fprintf(fidIEH,'EVM (%%) = %4.3f \n ',EVM_perc);
fprintf(fidIEH,'ACLR_L/ACLR_U = %4.3f / %4.3f \n ',ACLR_L,ACLR_U);
fprintf(fidIEH,'ACPR_L/ACPR_U = %4.3f / %4.3f \n ',ACPR_L,ACPR_U);
fprintf(fidIEH,'PAPRin = %4.3f \n ',PAPRin);
fprintf(fidIEH,'PAPRout = %4.3f \n ',PAPRout);

% if strcmp(Measure_Pout_Eff,'True')
%     fprintf(fidIEH,'\n');
%     fprintf(fidIEH,'With DPD Measurements');
%     fprintf(fidIEH,'\nPout  = %4.3f   dBm ', Pout_measured_with_DPD);
%     fprintf(fidIEH,'\nVdd   = %4.3f   V', V_m_with_DPD);
%     fprintf(fidIEH,'\nIdd   = %4.3f   mA', I_m_with_DPD*1e3);
%     fprintf(fidIEH,'\nDE    = %4.3f  %',DE_measured_with_DPD);
%     fprintf(fidIEH,'\nPAE   =        %');
fprintf(fidIEH,'\n');
fprintf(fidIEH,'Without DPD Measurements');
fprintf(fidIEH,'\nPout  = %4.3f   dBm ', p_out);
fprintf(fidIEH,'\nVdd   = %4.3f   V', V_m);
fprintf(fidIEH,'\nIdd   = %4.3f   mA', I_m*1e3);
fprintf(fidIEH,'\nDE    = %4.3f  %',DE);
fprintf(fidIEH,'\nPAE   =        %');
% else
%     fprintf(fidIEH,'\n');
%     fprintf(fidIEH,'\nPout   =        dBm ');
%     fprintf(fidIEH,'\nVdd    = 28     V');
%     fprintf(fidIEH,'\nIdd    =        mA');
%     fprintf(fidIEH,'\nDE     =        %');
%     fprintf(fidIEH,'\nPAE    =        %');
% end
fclose(fidIEH);
cd ..
cd ..
