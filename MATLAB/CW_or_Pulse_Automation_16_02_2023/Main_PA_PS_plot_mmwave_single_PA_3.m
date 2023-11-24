clc
clear
close all
% frequency settings of PA                      
f_start =24.5e9;
f_stop =29e9;
f_step =0.5e9;
RFfreq=f_start:f_step:f_stop;
Nf=length(RFfreq);
Np_interp=23;
Pin_interp=zeros(Np_interp,Nf);
Gain_interp=zeros(Np_interp,Nf);
Phase_PA_interp=zeros(Np_interp,Nf);
Pout_interp=zeros(Np_interp,Nf);
Phase_PA_Driver_n=zeros(Np_interp,Nf);
Phase_PA=zeros(Np_interp,Nf);
Phase_PA_interp_ave=zeros(Np_interp,Nf);
Phase_PA_Drive_interp=zeros(Np_interp,Nf);
Phase_PA_Drive_interp_ave=zeros(Np_interp,Nf);
phase_Driver=zeros(Np_interp,Nf);
for i=1:Nf
    if RFfreq(i)==24.5e9
        load('MMwave_single_PA_2_24_5GHz_pulse.mat');
        load('Driver_AMPM_Pout_24_5GHz_CW.mat')
    elseif RFfreq(i)==25e9
        load('MMwave_single_PA_2_25GHz_pulse.mat');
        load('Driver_AMPM_Pout_25GHz_CW.mat');
    elseif RFfreq(i)==25.5e9
        load('MMwave_single_PA_2_25_5GHz_pulse.mat');
        load('Driver_AMPM_Pout_25_5GHz_CW.mat');
        Np=length(Gain_PA);
        Phase_PA_Driver=Phase_PA_Driver(1:(Np-2));
    elseif RFfreq(i)==26e9
        load('MMwave_single_PA_2_26GHz_pulse.mat');
        load('Driver_AMPM_Pout_26GHz_CW.mat')
    elseif RFfreq(i)==26.5e9
        load('MMwave_single_PA_2_26_5GHz_pulse.mat');
        load('Driver_AMPM_Pout_26_5GHz_CW.mat');
    elseif RFfreq(i)==27e9
        load('MMwave_single_PA_2_27GHz_pulse.mat');
        load('Driver_AMPM_Pout_27GHz_CW.mat');
    elseif RFfreq(i)==27.5e9
        load('MMwave_single_PA_2_27_5GHz_pulse.mat');
        load('Driver_AMPM_Pout_27_5GHz_CW.mat');
    elseif RFfreq(i)==28e9
        load('MMwave_single_PA_2_28GHz_pulse.mat');
        load('Driver_AMPM_Pout_28GHz_CW.mat');
       
    elseif RFfreq(i)==28.5e9
        load('MMwave_single_PA_2_28_5GHz_pulse.mat');
        load('Driver_AMPM_Pout_28_5GHz_CW.mat');
    else
        load('MMwave_single_PA_2_29GHz_pulse.mat');
        load('Driver_AMPM_Pout_29GHz_CW.mat');
    end
    Np=length(Phase_PA_Driver);
    Phase_PA(1:Np,i)=Phase_PA_Driver(1:Np)-S21_phase(1:Np);
    phase_Driver(1:Np_interp,i)=S21_phase(1:Np_interp)-mean(S21_phase(1:Np_interp));
    Pout_driver(1:Np_interp,i)=Pout_VNA(1:Np_interp);
    Pin=1:1:Np;
    Pin=Pin';
    Pin_interp(:,i)=1:(Np-1)/(Np_interp-1):Np;
    Phase_PA_interp(:,i)=interp1(Pin,Phase_PA(1:Np,i),Pin_interp(:,i),'linear');
    Phase_PA_interp_ave(:,i)=Phase_PA_interp(:,i)-mean(Phase_PA_interp(:,i));
    Pout_interp(:,i)=interp1(Pin,Pout(1:Np),Pin_interp(:,i),'linear');
    Phase_PA_Drive_interp(:,i)=interp1(Pin,Phase_PA_Driver,Pin_interp(:,i),'linear');
    Phase_PA_Drive_interp_ave(:,i)=Phase_PA_Drive_interp(:,i)-mean(Phase_PA_Drive_interp(:,i));
   
%     Pin=1:1:Np;
%     Pin_interp(i,:)=1:(Np-1)/(Np_interp-1):Np;
%     Gain_interp(i,:)=interp1(Pin,Gain_PA,Pin_interp(i,:),'linear');
%     Phase_PA_interp(i,:)=interp1(Pin,Phase_PA_Driver,Pin_interp(i,:),'linear');
%     Phase_PA_Driver_n(i,:)=Phase_PA_interp(i,:)-mean(Phase_PA_interp(i,:));
%     Pout_interp(i,:)=interp1(Pin,Pout,Pin_interp(i,:),'linear');
    Gain_PA=[]; Phase_PA_Driver=[]; Pout=[]; 
end
Phase_PA_interp_movemean=movmean(Phase_PA_interp_ave,3);
Phase_PA_driver_interp_movemean=movmean(Phase_PA_Drive_interp_ave,3);
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv');
% Np=21; Np_interp=25;
% Pin=1:1:Np;
% Pin_test=1:(Np-1)/(Np_interp-1):Np;

figure()
hold on
for i=1:Nf
    plot(Pout_interp(:,i),Phase_PA_interp_ave(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('24.5GHz','25GHz','25.5GHz','26.0GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(Pout_interp(:,i),Phase_PA_Drive_interp_ave(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('24.5GHz','25GHz','25.5GHz','26.0GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(Pout_interp(:,i),Phase_PA_interp_movemean(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('24.5GHz','25GHz','25.5GHz','26.0GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(Pout_interp(:,i),Phase_PA_driver_interp_movemean(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('24.5GHz','25GHz','25.5GHz','26.0GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(Pout_driver(:,i),phase_Driver(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('24.5GHz','25GHz','25.5GHz','26.0GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on




