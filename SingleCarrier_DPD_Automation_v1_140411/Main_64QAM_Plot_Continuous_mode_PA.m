clc
clear
close all
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions',path);
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions\delayAdjustment',path);
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\SBP_Driver_with_PA\Measurement07-Apr-2023_19_59_28',path);
addpath(genpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions'));
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\useful_functions_Hassan',path);
% path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions',path);
% path('D:\Matlab\DPD_2022_09\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions',path);
j=sqrt(-1);
% a=rand(2000,1);
% 
% load('64QAM_PAPR_6_6dB.mat','a');
% freq=3.8e9;

fG        = 2000e3;       % Gaurd band for the modulated signal - Used to calculated ACLR and ACPR from the downloaded I/Q signals
BW        = 200e6; 
Fs=5*BW;
SampleRate=Fs;
Center_F=5.2e9;
%
InI = load('I_Input_NoDPD_1.txt');
InQ = load('Q_Input_NoDPD_1.txt');
OutI_WithDPD= load('I_Output_WithDPD_1.txt');
OutQ_WithDPD= load('Q_Output_WithDPD_1.txt');
OutI_WithoutDPD= load('I_Output_WithoutDPD.txt');
OutQ_WithoutDPD= load('Q_Output_WithoutDPD.txt');
In=InI+j*InQ;
Out_WithDPD=OutI_WithDPD+j*OutQ_WithDPD;
Out_WithoutDPD=OutI_WithoutDPD+j*OutQ_WithoutDPD;
%%



[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay_zero(InI, InQ, OutI_WithoutDPD, OutQ_WithoutDPD,Fs,2000) ;
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q]             = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;

[DelayAdjusted_In_I2, DelayAdjusted_In_Q2, DelayAdjusted_Out_I2, DelayAdjusted_Out_Q2, timedelay2] = AdjustDelay_zero(InI, InQ, OutI_WithDPD, OutQ_WithDPD,Fs,2000) ;
[DelayAdjusted_In_I2, DelayAdjusted_In_Q2, DelayAdjusted_Out_I2, DelayAdjusted_Out_Q2]             = AdjustPowerAndPhase(DelayAdjusted_In_I2, DelayAdjusted_In_Q2, DelayAdjusted_Out_I2, DelayAdjusted_Out_Q2, 0) ;
[DelayAdjusted_In_I2, DelayAdjusted_In_Q2, DelayAdjusted_Out_I2, DelayAdjusted_Out_Q2]             = AdjustPowerAndPhase(DelayAdjusted_In_I2, DelayAdjusted_In_Q2, DelayAdjusted_Out_I2, DelayAdjusted_Out_Q2, 0) ;

xin1=complex(DelayAdjusted_In_I(1:9000),DelayAdjusted_In_Q(1:9000));
xout1=complex(DelayAdjusted_Out_I(1:9000),DelayAdjusted_Out_Q(1:9000));
xin2=complex(DelayAdjusted_In_I2(1:9000),DelayAdjusted_In_Q2(1:9000));
xout2=complex(DelayAdjusted_Out_I2(1:9000),DelayAdjusted_Out_Q2(1:9000));

DelayAdjusted_In_I=DelayAdjusted_In_I(500:9500);
DelayAdjusted_In_Q=DelayAdjusted_In_Q(500:9500);
DelayAdjusted_In_I2=DelayAdjusted_In_I2(500:9500);
DelayAdjusted_In_Q2=DelayAdjusted_In_Q2(500:9500);
DelayAdjusted_Out_I=DelayAdjusted_Out_I(500:9500);
DelayAdjusted_Out_Q=DelayAdjusted_Out_Q(500:9500);
DelayAdjusted_Out_I2=DelayAdjusted_Out_I2(500:9500);
DelayAdjusted_Out_Q2=DelayAdjusted_Out_Q2(500:9500);
PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
%     
[EVM_dB_withoutDPD EVM_withoutDPD] = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);
[freq, spectrum] = Calculated_Spectrum(DelayAdjusted_Out_I(1:9000), DelayAdjusted_Out_Q(1:9000), 5*BW);
[ACLR_L_withoutDPD, ACLR_U_withoutDPD] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
[ACPR_L_withoutDPD, ACPR_U_withoutDPD] = Calculate_ACPR (freq, spectrum, 0, BW, fG);
%    
[EVM_dB_withDPD EVM_withDPD] = EVM_calculate (DelayAdjusted_In_I2,DelayAdjusted_In_Q2,DelayAdjusted_Out_I2,DelayAdjusted_Out_Q2);
[freq, spectrum] = Calculated_Spectrum(DelayAdjusted_Out_I2(1:9000), DelayAdjusted_Out_Q2(1:9000), 5*BW);
[ACLR_L_withDPD, ACLR_U_withDPD] = Calculate_ACLR (freq, spectrum, 0, BW, fG);
[ACPR_L_withDPD, ACPR_U_withDPD] = Calculate_ACPR (freq, spectrum, 0, BW, fG);
%

% [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q);
%         xin  = complex( In_I  , In_Q  ) ;
%         xout = complex( Out_I , Out_Q ) ; 
        % check if Fs and h are given as input variable or set them to
        % default values

%
%
rolloff = 0.2;     % Rolloff factor
span = 30;           % Filter span in symbols
sps = 6;            % Samples per symbol
% % 
% coeff = rcosdesign(rolloff,span,sps,'sqrt');
coeff = rcosdesign(rolloff,span,sps);
% %
Base_In = upfirdn(xin1, coeff, 1, sps);
Base_In = Base_In(span+1:end-span);
% % Y_out=resample(Y_up_out,1,10,1000);
scatterplot(Base_In);

Base_Out_WithoutDPD = upfirdn(xout1, coeff, 1, sps);
Base_Out_WithoutDPD = Base_Out_WithoutDPD(span+1:end-span);
% scatterplot(Base_Out_WithoutDPD);

Base_Out_WithDPD = upfirdn(xout2, coeff, 1, sps);
Base_Out_WithDPD = Base_Out_WithDPD(span+1:end-span);
% scatterplot(Base_Out_WithDPD);
T=100; N1=length(Base_In);
Base_In=Base_In(T:N1);
Base_Out_WithDPD=Base_Out_WithDPD(T:N1);
Base_Out_WithoutDPD=Base_Out_WithoutDPD(T:N1);
scatterplot(Base_Out_WithoutDPD);
scatterplot(Base_Out_WithDPD);
%
[Base_In_I, Base_In_Q, Base_Out_WithoutDPD_I, Base_Out_WithoutDPD_Q]             = AdjustPowerAndPhase(real(Base_In),imag(Base_In),real(Base_Out_WithoutDPD),imag(Base_Out_WithoutDPD), 0) ;
[Base_In_I, Base_In_Q, Base_Out_WithoutDPD_I, Base_Out_WithoutDPD_Q]             = AdjustPowerAndPhase(Base_In_I, Base_In_Q, Base_Out_WithoutDPD_I, Base_Out_WithoutDPD_Q, 0) ;
[Base_In_I, Base_In_Q, Base_Out_WithDPD_I, Base_Out_WithDPD_Q]             = AdjustPowerAndPhase(Base_In_I, Base_In_Q,real(Base_Out_WithDPD),imag(Base_Out_WithDPD), 0) ;
[Base_In_I, Base_In_Q, Base_Out_WithDPD_I, Base_Out_WithDPD_Q]             = AdjustPowerAndPhase(Base_In_I, Base_In_Q, Base_Out_WithDPD_I, Base_Out_WithDPD_Q, 0) ;
[EVM_dB_withDPD3 EVM_withDPD3] = EVM_calculate (Base_In_I, Base_In_Q, Base_Out_WithDPD_I, Base_Out_WithDPD_Q);
[EVM_dB_withoutDPD3 EVM_withoutDPD3] = EVM_calculate (Base_In_I, Base_In_Q, Base_Out_WithoutDPD_I, Base_Out_WithoutDPD_Q);

%
[EVM_dB_withDPD2 EVM_withDPD2] = EVM_calculate (real(Base_In),imag(Base_In),real(Base_Out_WithDPD),imag(Base_Out_WithDPD));
[EVM_dB_withoutDPD2 EVM_withoutDPD2] = EVM_calculate (real(Base_In),imag(Base_In),real(Base_Out_WithoutDPD),imag(Base_Out_WithoutDPD));

Error=abs(Base_Out_WithDPD-Base_In)/abs(Base_In)*100;

Scaling_factor=1/max(Base_In_I);
Base_In_I=Base_In_I*Scaling_factor;
Base_In_Q=Base_In_Q*Scaling_factor;
Base_Out_WithoutDPD_I=Base_Out_WithoutDPD_I*Scaling_factor;
Base_Out_WithoutDPD_Q=Base_Out_WithoutDPD_Q*Scaling_factor;
Base_Out_WithDPD_I=Base_Out_WithDPD_I*Scaling_factor;
Base_Out_WithDPD_Q=Base_Out_WithDPD_Q*Scaling_factor;
%
limits = 1.07;


figure()
hold on
plot(Base_Out_WithoutDPD_I,Base_Out_WithoutDPD_Q,'.r',Base_Out_WithDPD_I,Base_Out_WithDPD_Q,'.b');
set(gcf,'color','w');
box(gca,'on');
% axis([26.8,27.2,-90,-20]);
limits = 1.2;
axis equal;
axis([-limits limits -limits limits]);
% h=legend('w/o DPD','with DPD');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('In-phase','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Quadrature','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

disp('With DPD');
display([ ' EVM with DPD        = ' num2str(EVM_withDPD3)      ' % ' ]);
display([ ' ACLR (L/U) with DPD = ' num2str(ACLR_L_withDPD) ' / '  num2str(ACLR_U_withDPD) ' dB ' ]);
display([ ' ACPR (L/U) with DPD = ' num2str(ACPR_L_withDPD) ' / '  num2str(ACPR_U_withDPD) ' dB ' ]);

disp('Without DPD');
display([ ' EVM without DPD        = ' num2str(EVM_withoutDPD3)      ' % ' ]);
display([ ' ACLR (L/U) without DPD = ' num2str(ACLR_L_withoutDPD) ' / '  num2str(ACLR_U_withoutDPD) ' dB ' ]);
display([ ' ACPR (L/U) without DPD = ' num2str(ACPR_L_withoutDPD) ' / '  num2str(ACPR_U_withoutDPD) ' dB ' ]);

%% Plot Data
% linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<');
% win=hamming(1024);
% [PSD1,F1]=pwelch(xout1,win,50,1024,SampleRate,'centered');
% [PSD2,F2]=pwelch(xout2,win,50,1024,SampleRate,'centered');
% F1=F1+Center_F;
% F2=F2+Center_F;
% %
% figure( )
% hold on
% grid on
% plot(F1/1e9,10*log10(PSD1)+60,'r');
% plot(F2/1e9,10*log10(PSD2)+60,'b');
% set(gcf,'color','w');
% axis([26.8,27.2,-90,-20]);
% h=legend('w/o DPD','with DPD');
% set(h,'fontsize',14,'fontname','Times New Roman')
% % title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
% xlabel('Frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('PSD (dBm/Hz)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
% hold off  
% grid on
% hold off
% %
% figure()
% hold on
% grid on    
% plot(10*log10(abs(xin1).^2/100)+30, 20*log10(abs(xout1)./abs(xin1)), '.r') ;
% plot(10*log10(abs(xin2).^2/100)+30, 20*log10(abs(xout2)./abs(xin2)), '.b') ;
% axis([-10 10 -5 5]); set(gcf,'color','w');
% h=legend('w/o DPD','with DPD');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('AM-AM(dB)', 'FontSize', 20) ;
% xlabel('Normalized Input Power (dB)', 'FontSize', 15) ;
% ylabel('AM-AM(dB)', 'FontSize', 15) ;
% hold off 
% %
% figure()
% hold on
% grid on 
%         plot( 10*log10(abs(xin1).^ 2/100)+30, phase(xout1./xin1)*(180/pi), 'r.') ; 
%         plot( 10*log10(abs(xin2).^ 2/100)+30, phase(xout2./xin2)*(180/pi), 'b.') ; 
%         axis([-10 10 -30 30]); set(gcf,'color','w');
%         h=legend('w/o DPD','with DPD');
% set(h,'fontsize',14,'fontname','Times New Roman')
%             title('AM/PM Distortion', 'FontSize', 20) ;
%             xlabel('Normalized Input Power (dB)', 'FontSize', 15) ;
%             ylabel('AM-PM (degree)', 'FontSize', 15) ;
%         hold off
% 
%
%
%
%  figure(1)
%  hold on
%  grid on
%  PSDin = plot(msspectrum(h, xin, 'centerdc', Fs)) ;
%  set(PSDin, 'Color', 'blue', 'LineWidth', 2) ;
%  PSDout = plot(msspectrum(h, xout, 'centerdc', Fs)) ;
%  set(PSDout, 'Color', 'red', 'LineWidth', 2 ) ;
%  h=legend('without DPD','with DPD');
% set(h,'fontsize',14,'fontname','Times New Roman')
% % title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
% xlabel('Frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('PSD (dBm/Hz)','fontsize',15,'fontname','Times New Roman','fontweight','b');  
%  hold off    
% % [freq, spectrum] = Calculated_Spectrum(OUT_I_ACP, OUT_Q_ACP, 5*BW);
%%
% 
% % [In_I_withDPD, In_Q_withDPD, ResampledRecI, ResampledRecQ]                                     = AdjustPowerAndPhase(In_I_withDPD, In_Q_withDPD, ResampledRecI, ResampledRecQ, 0) ;
% [In_withDPD, out_1_withDPD]                                   = UnifyLength(In, Out_WithDPD) ;
% [DelayAdjusted_In,  DelayAdjusted_Out,  timedelay1] = AdjustDelay(In_withDPD, out_1_withDPD, Fs,2000) ;
% [DelayAdjusted_In,  DelayAdjusted_Out]             = AdjustPowerAndPhase(DelayAdjusted_In,  DelayAdjusted_Out, 0) ;
% PlotGain(DelayAdjusted_In,  DelayAdjusted_Out) ;
% PlotAMPM(DelayAdjusted_In,  DelayAdjusted_Out) ;
% PlotSpectrum(DelayAdjusted_In,  DelayAdjusted_Out, Fs) ;
% [EVM_dB, EVM_per]= CalculateEVM (DelayAdjusted_In,  DelayAdjusted_Out)
% 
%     [freq, spectrum] = CalculatedSpectrum(DelayAdjusted_Out, 5*BW);
%     [ACLR_L, ACLR_U] = CalculateACLR (freq, spectrum, 0, BW, fG);
%     [ACPR_L, ACPR_U] = CalculateACPR (freq, spectrum, 0, BW, fG);
% 
% % a = floor(a*64);
% %%
% % M = 64;
% % y = qammod(a,M);
% % scatterplot(y)
% % PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
% % 





% 
% Base_WithDPD = upfirdn(DelayAdjusted_Out, coeff, 1, sps);
% Base_WithDPD = Base_WithDPD(span+1:end-span);
% % Y_out=resample(Y_up_out,1,10,1000);
% scatterplot(Base_WithDPD);
% 
% % [val,pos] = max(coeff);
% impz(coeff,1);
% % save('Coefficient_filter.mat','Num')
% % load('Coefficient_filter.mat','Num')
% y_up = upfirdn(y, coeff, sps); 
% % y_up=y_up';
% %
% In_I_QAM=real(y_up); In_Q_QAM=imag(y_up);
% PlotSpectrum(In_I_QAM, In_Q_QAM, In_I_QAM, In_Q_QAM) ;
% % In_I_MOD=real(z); In_Q_MOD=imag(z);
% [In_I_QAM, In_Q_QAM]                      = setMeanPower(In_I_QAM, In_Q_QAM, 0);  
% % [In_I_MOD, In_Q_MOD]                      = setMaxPower(In_I_MOD, In_Q_MOD, 0);    
% [meanPower_QAM, maxPower_QAM, PAPR_QAM] = checkPower(In_I_QAM, In_Q_QAM, 1) ;       
% % [meanPower_MOD, maxPower_MOD, PAPR_MOD] = checkPower(In_I_MOD, In_Q_MOD, 1) ;  
% Fsampling=500e6;
% N1=length(In_I_QAM);
% Frametime=N1/Fsampling;
% 
% %%
% Y_up = complex(In_I_QAM, In_Q_QAM) ;
% Y_up_Power = 10*log10(abs(Y_up).^2/100)+30;
% %
% 
% plot(Y_up_Power);
% % Z = complex(In_I_MOD, In_Q_MOD) ;
% % Z_Power = 10*log10(abs(Z).^2/100)+30;
% % % plot(Z_Power);
% %%
% %Y_up_Power=-20:10;
% % AM_PM=fun_AM_AM_model_new(Y_up_Power,-15);
% % gainY_up=exp(j*AM_PM./180*pi);
% % Y_up_out=Y_up.*gainY_up;
% Y_up_out=Y_up;
% % figure(10) 
% % hold on
% % plot(Y_up_Power,AM_PM,'or')
% % hold off
% % 
% Y_out = upfirdn(Y_up_out, coeff, 1, sps);
% Y_out = Y_out(span+1:end-span);
% % Y_out=resample(Y_up_out,1,10,1000);
% scatterplot(Y_out);
% %%
% 
% [In_I_QAM1, In_Q_QAM1]                      = setMeanPower(real(y), imag(y), 0);  
% [In_I_MOD1, In_Q_MOD1]                      = setMeanPower(real(Y_up), imag(Y_up), 0);  
% 
% [In_I_QAM2, In_Q_QAM2]                      = setMeanPower(real(Y_out), imag(Y_out), 0);  
% [In_I_MOD2, In_Q_MOD2]                      = setMeanPower(real(Y_up_out), imag(Y_up_out), 0);  
% 
% [meanPower_Yout, maxPower_Yout, PAPR_Yout] = checkPower(real(Y_up), imag(Y_up), 1);
% [meanPower_Yout, maxPower_Yout, PAPR_Yout] = checkPower(In_I_MOD2, In_Q_MOD2, 1);
% [meanPower_QAM, maxPower_QAM, PAPR_QAM] = checkPower(In_I_QAM2, In_Q_QAM2, 1) ;
% [EVM_dB_QAM EVM_per_QAM]= EVM_calculate (In_I_QAM1, In_Q_QAM1,In_I_QAM2, In_Q_QAM2)
% [EVM_dB_MOD EVM_per_MOD]= EVM_calculate (In_I_MOD1, In_Q_MOD1,In_I_MOD2, In_Q_MOD2)
% 
% figure
% 
% plot(In_I_QAM1, In_Q_QAM1, 'r.');
% 
% title('Ô­Ê¼ÐÅºÅÐÇ×ùÍ¼'); 
% 
% hold on
% scatterplot(In_I_QAM1+j*In_Q_QAM1);
% scatterplot(In_I_QAM2+j*In_Q_QAM2);
% hold off
% 
% plot(20*log10(abs(fftshift(fft(Y_up_out))))); hold on
% plot(20*log10(abs(fftshift(fft(Y_up))))); hold off
% 
% ccdf = comm.CCDF('PAPROutputPort',true,'MaximumPowerLimit', 50);
% [Fy,Fx,PAPR] = ccdf(y_up);
% plot(ccdf)
% 
% % save D:\Matlab\DPD_2022_09\64QAM_100MHz_In_I_500r0_PAPR_6r6_24_3us.txt -ascii In_I_QAM
% % save D:\Matlab\DPD_2022_09\64QAM_100MHz_In_Q_500r0_PAPR_6r6_24_3us.txt -ascii In_Q_QAM
