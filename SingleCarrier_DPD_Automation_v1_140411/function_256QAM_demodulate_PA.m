function [EVM_withDPD3,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA()


% path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions',path);
% path('D:\Matlab\DPD_2022_09\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions',path);
j=sqrt(-1);
% a=rand(2000,1);
% 
% load('64QAM_PAPR_6_6dB.mat','a');
% freq=3.8e9;

fG        = 1500e3;       % Gaurd band for the modulated signal - Used to calculated ACLR and ACPR from the downloaded I/Q signals
BW        = 200e6; 
Fs=4*BW;
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
% PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
% PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
% PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
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
% scatterplot(Base_In);

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
% scatterplot(Base_Out_WithoutDPD);
% scatterplot(Base_Out_WithDPD);
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

% disp('With DPD');
% display([ ' EVM with DPD        = ' num2str(EVM_withDPD3)      ' % ' ]);
% display([ ' ACLR (L/U) with DPD = ' num2str(ACLR_L_withDPD) ' / '  num2str(ACLR_U_withDPD) ' dB ' ]);
% display([ ' ACPR (L/U) with DPD = ' num2str(ACPR_L_withDPD) ' / '  num2str(ACPR_U_withDPD) ' dB ' ]);
% 
% disp('Without DPD');
% display([ ' EVM without DPD        = ' num2str(EVM_withoutDPD3)      ' % ' ]);
% display([ ' ACLR (L/U) without DPD = ' num2str(ACLR_L_withoutDPD) ' / '  num2str(ACLR_U_withoutDPD) ' dB ' ]);
% display([ ' ACPR (L/U) without DPD = ' num2str(ACPR_L_withoutDPD) ' / '  num2str(ACPR_U_withoutDPD) ' dB ' ]);

end
