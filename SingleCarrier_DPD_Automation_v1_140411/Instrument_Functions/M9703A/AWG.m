% restoredefaultpath; 
% close all ; clear all ; clc ;
% AddPath ;
%% Parameters
    % Signal
    SignalPath = 'Test/' ;
        OrI1_path = [SignalPath, '1111_In_I.txt'] ;
        OrQ1_path = [SignalPath, '1111_In_Q.txt'] ;
%         OrI2_path = [SignalPath, '1111_In_I.txt'] ;
%         OrQ2_path = [SignalPath, '1111_In_Q.txt'] ;
%         OrI3_path = [SignalPath, '1111_In_I.txt'] ;
%         OrQ3_path = [SignalPath, '1111_In_Q.txt'] ;
    % For the measurement equipments
        AWGAdd = load('../iqtools/arbConfig.mat') ;
        Fcarrier1 = 100e6 ; %Fcarrier2 = 2.7e9 ; Fcarrier3 = 2.9e9 ;
        FsampleTx1 = 250e6 ; %FsampleTx2 = 100e6 ; FsampleTx3 = 100e6 ;
        FsampleRx1 = 100e6 ; %FsampleRx2 = 100e6 ; FsampleRx3 = 100e6 ;
        FramTime = 1e-3 ;
        data_length = 70e3 ;
        NbOfPoint = data_length ;
        CDTRFTB = 0 ;
        PowerBand1 = 20 ; %PowerBand2 = 20 ; PowerBand3 = 20 ;
        PXA_Atten1 = 10 ; %PXA_Atten2 = 10 ; PXA_Atten3 = 10 ;
        PXAAdd = 18 ;
%% Import signals
    [UpSample, DownSample] = rat(250/92.16) ;
    Or_I1 = loadfile(OrI1_path, NbOfPoint+CDTRFTB) ; Or_I1 = resample(Or_I1, UpSample, DownSample) ; Or_I1 = Or_I1(CDTRFTB+1:end) ;
    Or_Q1 = loadfile(OrQ1_path, NbOfPoint+CDTRFTB) ; Or_Q1 = resample(Or_Q1, UpSample, DownSample) ; Or_Q1 = Or_Q1(CDTRFTB+1:end) ;
%     Or_I2 = loadfile(OrI2_path, NbOfPoint+CDTRFTB) ; Or_I2 = resample(Or_I2, UpSample, DownSample) ; Or_I2 = Or_I2(CDTRFTB+1:end) ;
%     Or_Q2 = loadfile(OrQ2_path, NbOfPoint+CDTRFTB) ; Or_Q2 = resample(Or_Q2, UpSample, DownSample) ; Or_Q2 = Or_Q2(CDTRFTB+1:end) ;
%     Or_I3 = loadfile(OrI3_path, NbOfPoint+CDTRFTB) ; Or_I3 = resample(Or_I3, UpSample, DownSample) ; Or_I3 = Or_I3(CDTRFTB+1:end) ;
%     Or_Q3 = loadfile(OrQ3_path, NbOfPoint+CDTRFTB) ; Or_Q3 = resample(Or_Q3, UpSample, DownSample) ; Or_Q3 = Or_Q3(CDTRFTB+1:end) ;    
%         [Or_I1, Or_Q1, Or_I2, Or_Q2] = UnifyLength(Or_I1, Or_Q1, Or_I2, Or_Q2, NbOfPoint) ;
%         [Or_I1, Or_Q1, Or_I3, Or_Q3] = UnifyLength(Or_I1, Or_Q1, Or_I3, Or_Q3, NbOfPoint) ;
%         [Or_I1, Or_Q1, Or_I2, Or_Q2] = UnifyLength(Or_I1, Or_Q1, Or_I2, Or_Q2, NbOfPoint) ;
    [Or_I1, Or_Q1] = setMeanPower(Or_I1, Or_Q1, PowerBand1) ;
%     [Or_I2, Or_Q2] = setMeanPower(Or_I2, Or_Q2, PowerBand2) ;
%     [Or_I3, Or_Q3] = setMeanPower(Or_I3, Or_Q3, PowerBand3) ;
%         PlotSpectrum(Or_I1, Or_Q1, Or_I2, Or_Q2) ;
%         PlotSpectrum(Or_I1, Or_Q1, Or_I3, Or_Q3) ;
%% First iteration - no DPD
        Pr_I1 = Or_I1 ;
        Pr_Q1 = Or_Q1 ;
%         Pr_I2 = Or_I2 ;
%         Pr_Q2 = Or_Q2 ;
%         Pr_I3 = Or_I3 ;
%         Pr_Q3 = Or_Q3 ;
        In_I1 = Pr_I1 ;
        In_Q1 = Pr_Q1 ;
%         In_I2 = Pr_I2 ;
%         In_Q2 = Pr_Q2 ;
%         In_I3 = Pr_I3 ;
%         In_Q3 = Pr_Q3 ;
%% Upload the signal to the ESGs
        [In_I1, In_Q1] = setMeanPower(In_I1, In_Q1, PowerBand1) ;
        ComplexSignal{1} = complex(In_I1, In_Q1);
%         [In_I2, In_Q2] = setMeanPower(In_I2, In_Q2, PowerBand2) ;
%         ComplexSignal{2} = complex(In_I2, In_Q2);
%         [In_I3, In_Q3] = setMeanPower(In_I3, In_Q3, PowerBand3) ;
%         ComplexSignal{3} = complex(In_I3, In_Q3);
        Fcarrier{1} = Fcarrier1 ;
%         Fcarrier{2} = Fcarrier2 ;
%         Fcarrier{3} = Fcarrier3 ;
        FsampleTx{1} = FsampleTx1 ;
%         FsampleTx{2} = FsampleTx2 ;
%         FsampleTx{3} = FsampleTx3 ;    
%     [Iin, Qin] = Combine_3Signals(In_I1, In_Q1, In_I2, In_Q2, In_I3, In_Q3, Fcarrier{1}, FsampleTx{1}, Fcarrier{2}, FsampleTx{2}, Fcarrier{3}, FsampleTx{3}, 4e9) ;
%     checkPower(Iin, Qin,1);
% 	PlotSpectrum(Iin, Qin, Iin, Qin) ;
%% break
%     AWG_M8190A_RF_OFF() ;
    AWG_M8190A_SignalUpload(ComplexSignal(1), Fcarrier(1), FsampleTx(1), 8e9, false)
    display('Upload Complete') ;
%     AWG_M8190A_Output_OFF(1)
    break
%     AWG_M8190A_RF_ON() ;
% break
%% Download the signal
%     AWG_M8190A_Output_ON(1)
%         [Out_I1, Out_Q1] = IQCapture_with_atten(Fcarrier1, FsampleRx1, FramTime, PXAAdd, 6) ;
%         [Out_I2, Out_Q2] = IQCapture_with_atten(Fcarrier2, FsampleRx2, FramTime, PXAAdd, 6) ;
%         [Out_I3, Out_Q3] = IQCapture_with_atten(Fcarrier3, FsampleRx3, FramTime, PXAAdd, 6) ;
%     %Turn Off PSG
%     AWG_M8190A_RF_OFF() ;
%     [Iout, Qout] = Combine_3Signals(Out_I1(2:end), Out_Q1(2:end), Out_I2(2:end), Out_Q2(2:end), Out_I3(2:end), Out_Q3(2:end), Fcarrier{1}, FsampleTx{1}, Fcarrier{2}, FsampleTx{2}, Fcarrier{3}, FsampleTx{3}, 4e9) ;
%     checkPower(Iout, Qout,1);
%     display('Download Complete') ;

%%
    checkPower(Or_I1, Or_Q1,1);
    checkPower(RecI.', RecQ.',1);
    [Or_I1, Or_Q1, RecI, RecQ] = AdjustPowerAndPhase(Or_I1, Or_Q1, RecI.', RecQ.', 0) ;
    PlotSpectrum(Or_I1, Or_Q1, RecI, RecQ) ;
%% Save Results
    close all ;
    
    Out_I1=RecI;
    Out_Q1=RecQ;
    [or_I1, or_Q1, out_I1, out_Q1] = UnifyLength(Or_I1, Or_Q1, Out_I1, Out_Q1, NbOfPoint) ;
    [or_I1, or_Q1, out_I1, out_Q1, timedelay1] = AdjustDelay(or_I1, or_Q1, out_I1, out_Q1,250e6,1000) ;
        [or_I1, or_Q1, out_I1, out_Q1] = AdjustPowerAndPhase(or_I1, or_Q1, out_I1, out_Q1, 0) ;
            PlotGain(or_I1, or_Q1, out_I1, out_Q1) ;
            PlotAMPM(or_I1, or_Q1, out_I1, out_Q1) ;
            PlotSpectrum(or_I1, or_Q1, out_I1, out_Q1) ;
            break
    [or_I2, or_Q2, out_I2, out_Q2] = UnifyLength(Or_I2, Or_Q2, Out_I2, Out_Q2, NbOfPoint) ;
    [or_I2, or_Q2, out_I2, out_Q2, timedelay2] = AdjustDelay(or_I2, or_Q2, out_I2, out_Q2) ;            
        [or_I2, or_Q2, out_I2, out_Q2] = AdjustPowerAndPhase(or_I2, or_Q2, out_I2, out_Q2, 0) ;
            PlotGain(or_I2, or_Q2, out_I2, out_Q2) ;
            PlotAMPM(or_I2, or_Q2, out_I2, out_Q2) ;
            PlotSpectrum(or_I2, or_Q2, out_I2, out_Q2) ;
    [or_I3, or_Q3, out_I3, out_Q3] = UnifyLength(Or_I3, Or_Q3, Out_I3, Out_Q3, NbOfPoint) ;
    [or_I3, or_Q3, out_I3, out_Q3, timedelay3] = AdjustDelay(or_I3, or_Q3, out_I3, out_Q3) ;            
        [or_I3, or_Q3, out_I3, out_Q3] = AdjustPowerAndPhase(or_I3, or_Q3, out_I3, out_Q3, 0) ;
            PlotGain(or_I3, or_Q3, out_I3, out_Q3) ;
            PlotAMPM(or_I3, or_Q3, out_I3, out_Q3) ;
            PlotSpectrum(or_I3, or_Q3, out_I3, out_Q3) ;
    TimeDifference = (timedelay1-timedelay2)*1e6 ;
	display(TimeDifference) ;
    TimeDifference = (timedelay1-timedelay3)*1e6 ;
	display(TimeDifference) ;
%%    
	NMSE_ProposedDualBand{1} = ComputeNMSE((or_I1(1e3:end-1e3)), (or_Q1(1e3:end-1e3)), out_I1(1e3:end-1e3), out_Q1(1e3:end-1e3)) ;
    NMSE_ProposedDualBand{2} = ComputeNMSE((or_I2(20e3:end-1e3)), (or_Q2(20e3:end-1e3)), out_I2(20e3:end-1e3), out_Q2(20e3:end-1e3)) ;
    NMSE_ProposedDualBand{3} = ComputeNMSE((or_I3(1e3:end-1e3)), (or_Q3(1e3:end-1e3)), out_I3(1e3:end-1e3), out_Q3(1e3:end-1e3)) 

            display([' NMSE1 = ', num2str(NMSE_ProposedDualBand{1}), ' dB']) ;
            display([' NMSE2 = ', num2str(NMSE_ProposedDualBand{2}), ' dB']) ;
            display([' NMSE3 = ', num2str(NMSE_ProposedDualBand{3}), ' dB']) ;
    
        id = 1 ;
    NMSE(id,1) = NMSE_ProposedDualBand{1} ;
    acpr(id,1) = ACPR(or_I1, or_Q1, out_I1, out_Q1) ;
    NMSE(id,2) = NMSE_ProposedDualBand{2} ;
    acpr(id,2) = ACPR(or_I2, or_Q2, out_I2, out_Q2) ;            
    NMSE(id,3) = NMSE_ProposedDualBand{3} ;
    acpr(id,3) = ACPR(or_I3, or_Q3, out_I3, out_Q3) ;            
break            
%%
    path = '.\SaveSignals\' ;
            
    fid = fopen( [path 'Or_I1.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , or_I1 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'Or_Q1.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , or_Q1 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'In_I1.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , In_I1 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'In_Q1.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , In_Q1 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'Out_I1.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , out_I1 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'Out_Q1.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , out_Q1 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'Or_I2.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , or_I2 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'Or_Q2.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , or_Q2 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'In_I2.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , In_I2 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'In_Q2.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , In_Q2 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'Out_I2.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , out_I2 ) ;
    fclose( fid ) ;
    fid = fopen( [path 'Out_Q2.txt'], 'wt' ) ;
        fprintf( fid , '%12.20f\n' , out_Q2 ) ;
    fclose( fid ) ;
    fid = fopen( '.\SaveSignals\Or_I3.txt', 'wt' ) ;
        fprintf( fid , '%12.20f\n' , or_I3 ) ;
    fclose( fid ) ;
    fid = fopen( '.\SaveSignals\Or_Q3.txt', 'wt' ) ;
        fprintf( fid , '%12.20f\n' , or_Q3 ) ;
    fclose( fid ) ;
    fid = fopen( '.\SaveSignals\In_I3.txt', 'wt' ) ;
        fprintf( fid , '%12.20f\n' , In_I3 ) ;
    fclose( fid ) ;
    fid = fopen( '.\SaveSignals\In_Q3.txt', 'wt' ) ;
        fprintf( fid , '%12.20f\n' , In_Q3 ) ;
    fclose( fid ) ;
    fid = fopen( '.\SaveSignals\Out_I3.txt', 'wt' ) ;
        fprintf( fid , '%12.20f\n' , out_I3 ) ;
    fclose( fid ) ;
    fid = fopen( '.\SaveSignals\Out_Q3.txt', 'wt' ) ;
        fprintf( fid , '%12.20f\n' , out_Q3 ) ;
    fclose( fid ) ;