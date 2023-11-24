%Main_NDPA_DPA_AM_PM
clc
clear
close all

%
Freq_real=24.5:0.5:27; Pin_real=-36:1:-9; 
pin_min=-36;
pin_max=-9;
load('Driver_24G_30G_SBP_mmwave_2.mat')

%
Nd=length(Gain_driver); Nf=length(Freq_real);
AMPM_real=zeros(Nd,Nf); AMAM_real=zeros(Nd,Nf); 
Pout_real=zeros(Nd,Nf); DE_real1=zeros(Nd,Nf);
Gain_PA_real=zeros(Nd,Nf); PAE_real1=zeros(Nd,Nf);
AMPM_both=zeros(Nd,Nf);AMPM_ave=zeros(Nd,Nf);
AMPM_PA=zeros(Nd,Nf);AMPM_PA2=zeros(Nd,Nf);
AMPM_PA_ave=zeros(Nd,Nf);AMPM_driver=zeros(Nd,Nf);
%
%AMPM_real(:,1)=Phase_PA-mean(Phase_PA);
% driver_array=fun_phase_array_SBP(Freq_real(1)*1e9,pin_min,pin_max);
% AMPM_driver(:,1)=driver_array-mean(driver_array);
% AMPM_both(:,1)=Phase_PA_Driver-mean(Phase_PA_Driver);
% AMPM_PA(:,1)=AMPM_both(:,1)-driver_array(1);
% AMPM_PA2(:,1)=AMPM_PA(:,1)-mean(AMPM_PA(:,1));
% AMPM_PA_ave(:,1)=movmean(AMPM_PA2(:,1),5);
% AMPM_ave(:,1)=movmean(AMPM_both(:,1),5);
% Pout_real(:,1)=Pout;
% AMAM_real(:,1)=Gain_PA;
% figure()
% plot(Pout_real(:,1),Gain_PA_real(:,1))
% figure()
% plot(Pout_real(:,1),AMPM_real(:,1))

for k=1:6
    if k==1
        load('MMwave_DPA_24_5GHz_CW_2.mat')
    elseif k==2
        load('MMwave_DPA_25GHz_CW_2.mat');
    elseif k==3
        load('MMwave_DPA_25_5GHz_CW_2.mat');
    elseif k==4
        load('MMwave_DPA_26GHz_CW_2.mat');
    elseif k==5
        load('MMwave_DPA_26_5GHz_CW_2.mat');
    elseif k==6
        load('MMwave_DPA_27GHz_CW_2.mat');     
    end
driver_array=phase_driver(:,k+1);
AMPM_both(:,k)=Phase_PA_Driver;
AMPM_both2(:,k)=Phase_PA_Driver-mean(Phase_PA_Driver);
% 
AMPM_PA(:,k)=AMPM_both(:,k)-driver_array;
AMPM_PA2(:,k)=AMPM_PA(:,k)-mean(AMPM_PA(:,k));
AMPM_ave(:,k)=movmean(AMPM_both2(:,k),5);
AMPM_PA_ave(:,k)=movmean(AMPM_PA2(:,k),5);
Pout_real(:,k)=Pout;
AMAM_real(:,k)=Gain_PA;
AMPM_driver(:,k)=driver_array-driver_array(1);
end
% %

% 

linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv','-bs','-g>', '-y<', '-ko');
%
RFfreq=24.5:0.5:27;

% ;
figure()
hold on
plot(RFfreq,max(Pout_real),'-ro');
% plot(RFfreq,Pout_1dB,'-bv')
axis([24.5,27,25,42]);
set(gcf,'color','w');
h=legend('Saturation','1dB Compression');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

figure()
hold on
for i=1:1:Nf
    plot(Pout_real(:,i),AMPM_ave(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([14,34,-5,5]);
h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('AM PM both ave (degree)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

%
% figure()
% hold on
% for i=1:1:Nf
%     plot(Pout_real(:,i),AMPM_both(:,i),linestyle1(i,:),'linewidth',2);
% end
% set(gcf,'color','w');
% axis([5,34,-10,20]);
% h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');set(h,'fontsize',14,'fontname','Times New Roman')
% % title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
% xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('AM PM both (degree)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
% hold off    
% grid on


% figure()
% hold on
% for i=1:1:Nf
%     plot(Pout_real(:,i),AMPM_PA2(:,i),linestyle1(i,:),'linewidth',2);
% end
% set(gcf,'color','w');
% axis([5,34,-10,20]);
% h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');set(h,'fontsize',14,'fontname','Times New Roman')
% % title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
% xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('AM PM PA (degree)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
% hold off    
% grid on

%
figure()
hold on
for i=1:1:Nf
    plot(Pout_real(:,i),AMPM_PA_ave(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([14,34,-5,5]);
h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('AM PM PA ave (degree)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:1:Nf
    plot(Pout_real(:,i),AMPM_driver(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([14,34,-5,7]);
h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('AM PM driver (degree)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:1:Nf
    plot(Pout_real(:,i),AMAM_real(:,i)+4.4,linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([14,34,0,10]);
h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz');set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('AM AM PA (degree)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

