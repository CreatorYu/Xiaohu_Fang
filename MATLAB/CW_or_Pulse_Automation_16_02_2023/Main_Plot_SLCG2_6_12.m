clc
clear
close all
% load('PA_data_2022-10-23-23-21.mat')
% f_start =24.5e9;
% f_stop =29.5e9;
% f_step =0.5e9;
%
 
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_0_6G_16V2023-06-10-15-29.mat')
data_1=data;
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_0_9G_16V2023-06-10-18-05.mat')
data_2=data;
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_1_2G_16V2023-06-10-19-48.mat')
data_3=data;
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_1_5G_16V2023-06-10-20-04.mat')
data_4=data;
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_1_8G_16V2023-06-10-20-01.mat')
data_5=data;
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_2_1G_16V2023-06-10-20-14.mat')
data_6=data;
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_2_4G_16V2023-06-10-20-24.mat')
data_7=data;
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_2_7G_16V2023-06-10-20-32.mat')
data_8=data;
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_3_0G_16V2023-06-10-20-35.mat')
data_9=data;
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_3_3G_16V2023-06-10-20-39.mat')
data_10=data;
load('D:\Matlab\Xiaohu_Fang\MATLAB\CW_or_Pulse_Automation_16_02_2023\SLCG_2_data_CW_3_5G_16V2023-06-10-20-47.mat')
data_11=data;
data_com=[data_1 data_2 data_3 data_4 data_5 data_6 data_7 data_8 data_9 data_10 data_11];
data=data_com;
%
f_start =0.6e9;
f_stop =3.6e9;
f_step =0.3e9;
% desired characterization power range (in dBm) at the output of the driver
% n=2;
p_min = -35;
p_max = -15;
p_step = 1;
% Pout_real=[];


% linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv');
% load('PA_data_2017-08-19-21-39')
Nf=(f_stop-f_start)/f_step+1;
Pf=(p_max-p_min)/p_step+1;
%
Psat=zeros(1,Nf);
PAEsat=zeros(1,Nf);
freq=zeros(1,Nf);
Att_out=zeros(1,Nf);
Pin_real=zeros(Pf,Nf);
Pout_real=zeros(Pf,Nf);
Gain_real=zeros(Pf,Nf);
DE_real=zeros(Pf,Nf);
PAE_real=zeros(Pf,Nf);
%
for i=1:Nf
%         Gain_real(p_idx,f_idx)=data(f_idx).table(p_idx,9);
%         Pin_real(p_idx,f_idx)=data(f_idx).table(p_idx,2);
%         DE_real(p_idx,f_idx)=data(f_idx).table(p_idx,11);
%         PAE_real(p_idx,f_idx)=data(f_idx).table(p_idx,10);
%         Att_out(f_idx)=Mea_Attenuator_2(freq); 
    freq(i)=data(i).frequency;
    Pin_real(:,i)=data(i).table(:,2);  
    Vm_real(:,i)=data(i).table(:,3);
    Im_real(:,i)=data(i).table(:,4);
    Ia_real(:,i)=data(i).table(:,5);
    Pout_real(:,i)=data(i).table(:,8);   
    Gain_real(:,i)=data(i).table(:,9);  
    DE_real(:,i)=data(i).table(:,11);
    PAE_real(:,i)=data(i).table(:,10);
 %   Att_out(i)=Mea_Attenuator_2(freq(i)); 
end
%
%
%% Interpolate the DE and PAE to find 6dB Back-off DE and PAE
PAE_max=max(PAE_real);
Pout_max=max(Pout_real);
Gain_max=max(Gain_real);
for i=1:Nf
    PAE_6dB(i)=interp1(Pout_real(:,i),PAE_real(:,i),Pout_max(i)-6,'linear');
    DE_6dB(i)=interp1(Pout_real(:,i),DE_real(:,i),Pout_max(i)-6,'linear');
    DE_7_5dB(i)=interp1(Pout_real(:,i),DE_real(:,i),Pout_max(i)-7.5,'linear');
   % Pout_1dB(i)=interp1(Gain_real(:,i),Pout_real(:,i),Gain_max(i)-2,'linear');
end
%
%
% �?下code用于plot paper中的�?
[N1,N2]=size(Pout_real);
RFfreq=(f_start:f_step:f_stop)/1e9;
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv','-bs','-g>', '-y<', '-ko');
%
figure(1)
hold on
plot(RFfreq,Gain_real(1,:),'-ro');
set(gcf,'color','w');
% h=legend('1.0GHz','1.2GHz','1.4GHz','1.6GHz','1.8GHz','2.0GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

figure(2)
hold on
plot(RFfreq,max(Pout_real),'-ro');
% plot(RFfreq,Pout_1dB,'-bv')
set(gcf,'color','w');
h=legend('Saturation','1dB Compression');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

figure()
hold on
plot(RFfreq,max(DE_real),'-ro');
plot(RFfreq,DE_6dB, '-m*');
plot(RFfreq,DE_7_5dB,'-c^');
% plot(RFfreq,PAE_6dB, '-bv');
set(gcf,'color','w');
axis([0.6,3.6,30,70]);
h=legend('Saturation DE','6dB-OBO DE','7.5dB-OBO PAE');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Efficiency (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off
grid on

figure()
hold on
for i=1:N2
    plot(Pout_real(:,i),Gain_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([20,42,6,14]);
h=legend('1.0GHz','1.2GHz','1.4GHz','1.6GHz','1.8GHz','2GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
%
%


figure()
hold on
for i=1:6
    plot(Pout_real(:,i),DE_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([20,42,20,70]);
h=legend('1.0GHz','1.2GHz','1.4GHz','1.6GHz','1.8GHz','2.0GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on


figure()
hold on
for i=7:11
    plot(Pout_real(:,i),DE_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([26,38,20,70]);
h=legend('2.2GHz','2.4GHz','2.6GHz','2.8GHz','3.0GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
%

% figure()
% hold on
% for i=1:N2
%     plot(Pin_real(:,i),Pout_real(:,i),linestyle1(i,:),'linewidth',2);
% end
% set(gcf,'color','w');
% % axis([-20,0,0,30]);
% h=legend('1.0GHz','1.2GHz','1.4GHz','1.6GHz','1.8GHz','2.0GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% % title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
% xlabel('Input Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
% hold off    
% grid on


figure()
hold on
for i=1:N2
    plot(Pout_real(:,i),Gain_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('1.0GHz','1.2GHz','1.4GHz','1.6GHz','1.8GHz','2.0GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

k1=7; k2=9;
figure()
hold on
for i=k1:k2
    plot(Pout_real(:,i),Im_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');

for i=k1:k2
 plot(Pout_real(:,i),Ia_real(:,i),linestyle1(i+1,1:2),'linewidth',2);
end
h=legend('Main_1','Main_2','Main_3','Aux_1','Aux_2','Aux_3');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Drain Current (A)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

figure()
hold on
for i=k1:k2
    plot(Pout_real(:,i),Gain_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('2.2GHz','2.4GHz','2.6GHz','2.8GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=k1:k2
    plot(Pout_real(:,i),DE_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
axis([26,38,20,70]);
h=legend('2.2GHz','2.4GHz','2.6GHz','2.8GHz','3.0GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on