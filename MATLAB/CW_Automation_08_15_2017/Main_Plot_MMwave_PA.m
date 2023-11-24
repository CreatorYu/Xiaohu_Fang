clc
clear
close all
% load('PA_data_2022-10-23-23-21.mat')
% f_start =24.5e9;
% f_stop =29.5e9;
% f_step =0.5e9;
%
load('PA_data_Pulse2022-10-24-22-02.mat')
f_start =24.5e9;
f_stop =29.5e9;
f_step =0.5e9;
% desired characterization power range (in dBm) at the output of the driver
n=2;
p_min = -20;
p_max = -7;
p_step = 1;
Pout_real=[];
for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    for p_target=p_min:p_step:p_max
        p_idx = 1+(p_target-p_min)/p_step;
        Pout_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,5);   
        Gain_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,6);
        Pin_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,1);
        DE_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,7);
        PAE_real(p_idx,f_idx)=Performan_PA(p_idx+n-1,8);  
        Att_out(f_idx)=Mea_Attenuator_MMWave_2(freq);
    end
    n=n+15;
end
%
% 一下code用于plot paper中的图
[N1,N2]=size(Pout_real);
RFfreq=(f_start:f_step:f_stop)/1e9;
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv','-bs');
%
figure(1)
hold on
plot(RFfreq,Gain_real(1,:),'-ro');
set(gcf,'color','w');
% h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

figure(2)
hold on
plot(RFfreq,max(Pout_real),'-ro')
set(gcf,'color','w');
% h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Saturation Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

figure()
hold on
plot(RFfreq,max(DE_real),'-ro');
plot(RFfreq,max(PAE_real), '-bv');
set(gcf,'color','w');
h=legend('DE','PAE');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Efficiency (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

figure()
hold on
for i=1:N2
    plot(Pout_real(:,i),Gain_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz');
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
for i=1:N2
    plot(Pout_real(:,i),DE_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on


figure()
hold on
for i=1:N2
    plot(Pout_real(:,i),PAE_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PAE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=9:11
    plot(Pout_real(:,i),Gain_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('28.5GHz','29GHz','29.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=9:11
    plot(Pout_real(:,i),DE_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('28.5GHz','29GHz','29.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on