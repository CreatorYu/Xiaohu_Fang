% clc
% clear all
% close all

%% MP
% 
% I_signal=importfile('36I_after_MP_DPD.txt');
% Q_signal=importfile('36Q_after_MP_DPD.txt');
% 
% I_signal=resample(I_signal,2,1);
% Q_signal=resample(Q_signal,2,1);
% norm1=max(max(I_signal),max(Q_signal))
% norm2=max((abs(I_signal + 1j * Q_signal)))
% I_signal=I_signal(1:floor(length(I_signal)/8)*8)/norm2;%
% agt_awg_savebin('36I_after_MP_DPD',I_signal,0)
% Q_signal=Q_signal(1:floor(length(Q_signal)/8)*8)/norm2;%/norm
% agt_awg_savebin('36Q_after_MP_DPD',Q_signal,0)

%% OpVolterra
% 
% I_signal=importfile('In_I_data_1001_168r96_PAPR_8r7.txt');
% Q_signal=importfile('In_Q_data_1001_168r96_PAPR_8r7.txt');
% 
% I_signal=resample(I_signal,2,1);
% Q_signal=resample(Q_signal,2,1);
% norm=max(max(I_signal),max(Q_signal));
% I_signal=I_signal(1:floor(length(I_signal)/8)*8)/norm;%
% agt_awg_savebin('In_I_data_1001_168r96_PAPR_8r7',I_signal,0)
% Q_signal=Q_signal(1:floor(length(Q_signal)/8)*8)/norm;%/norm
% agt_awg_savebin('In_Q_data_1001_168r96_PAPR_8r7',Q_signal,0)

%%
I_signal=importfile('Pr_IQ_I.txt');
Q_signal=importfile('Pr_IQ_Q.txt');

% I_signal=I_signal(1:168960);
% Q_signal=Q_signal(1:168960);

% I_signal=resample(I_signal,2,1);
% Q_signal=resample(Q_signal,2,1);

% norm=max(max(I_signal),max(Q_signal));
norm=max((abs(I_signal + 1j * Q_signal)));
I_signal=I_signal(1:floor(length(I_signal)/8)*8)/norm;%
agt_awg_savebin('Pr_IQ_I',I_signal,0)
Q_signal=Q_signal(1:floor(length(Q_signal)/8)*8)/norm;%/norm
agt_awg_savebin('Pr_IQ_Q',Q_signal,0)

a=I_signal+1i*Q_signal;
% avg=10*log10(mean((abs(a)).^2)/100)+30
% peak=10*log10(max((abs(a)).^2)/100)+30
% PAPR=peak-avg

%%
% I_signal=importfile('In_I_data_1001_168r96_PAPR_8r7.txt');
% Q_signal=importfile('In_Q_data_1001_168r96_PAPR_8r7.txt');
% 
% I_signal=resample(I_signal,2,1);
% Q_signal=resample(Q_signal,2,1);
% 
% norm=max(max(I_signal),max(Q_signal));
% I_signal=I_signal(1:floor(length(I_signal)/8)*8)/norm;%
% agt_awg_savebin('In_I_data_1001_168r96_PAPR_8r7',I_signal,0)
% Q_signal=Q_signal(1:floor(length(Q_signal)/8)*8)/norm;%/norm
% agt_awg_savebin('In_Q_data_1001_168r96_PAPR_8r7',Q_signal,0)


%% ET a(t) signal generation

% I_signal=importfile('In_I_data_4C_DPD_10x7_v2.txt');
% Q_signal=importfile('In_Q_data_4C_DPD_10x7_v2.txt');
% 
% % I_signal=I_signal(1:168960);
% % Q_signal=Q_signal(1:168960);
% 
% I_signal=resample(I_signal,4,1);
% Q_signal=resample(Q_signal,4,1);
% 
% a=sqrt(I_signal.^2+Q_signal.^2);
% 
% % norm=max(max(I_signal),max(Q_signal));
% norm=max((abs(a)));
% a=a(1:floor(length(a)/8)*8)/norm;%
% agt_awg_savebin('a_4C_WCDMA',a,0);

%%
%%%%%%%%Spectrum

    figure() 
    
    hold on
        Fs    = 92.16e6*4            ;
        h     = spectrum.welch       ;
        h.OverlapPercent = 90        ;
        h.SegmentLength  = 4096      ;
        h.windowName     = 'Flat Top';
        PSD_Meas =plot(msspectrum(h,a,'centerdc',Fs));
        h_legend=legend('Measured input');
        set(h_legend,'FontSize',14);

        h=title('Welch Mean-Square Spectrum Estimate');
        set(h, 'FontName', 'Helvetica','FontSize',14)
    
    hold off
close all
%%

avg=10*log10(mean((abs(a)).^2)/100)+30
peak=10*log10(max((abs(a)).^2)/100)+30 
PAPR=peak-avg