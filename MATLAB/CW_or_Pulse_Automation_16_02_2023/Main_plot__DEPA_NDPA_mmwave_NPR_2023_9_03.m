clc
clear
close all
load('PA_data_NDPA_NPR_27_5G_one_notch_2023-09-05-14-14.mat')
data1=data;
load('PA_data_NDPA_NPR_28G_one_notch_2023-09-05-14-43.mat')
data2=data;
load('PA_data_NDPA_NPR_28_5G_30_5G_one_notch_2023-09-04-19-32.mat');
data3=data;
data=[data1 data2 data3];

f_start =27.5e9;
f_stop =30.5e9;
f_step =0.5e9;
% desired characterization power range (in dBm) at the output of the driver
% n=2;
p_min = -50;
p_max = -15;
p_step = 1;

Nf=(f_stop-f_start)/f_step+1;
Pf=(p_max-p_min)/p_step+1;
%
Psat=zeros(1,Nf);
PAEsat=zeros(1,Nf);
freq=zeros(1,Nf);
Pin_real=zeros(Pf,Nf);
Pout_real=zeros(Pf,Nf);
Gain_real=zeros(Pf,Nf);
DE_real=zeros(Pf,Nf);
PAE_real=zeros(Pf,Nf);
NPR_real=zeros(Pf,Nf);

for i=1:Nf
%         Gain_real(p_idx,f_idx)=data(f_idx).table(p_idx,9);
%         Pin_real(p_idx,f_idx)=data(f_idx).table(p_idx,2);
%         DE_real(p_idx,f_idx)=data(f_idx).table(p_idx,11);
%         PAE_real(p_idx,f_idx)=data(f_idx).table(p_idx,10);
%         Att_out(f_idx)=Mea_Attenuator_2(freq); 
    freq(i)=data(i).frequency;
    Pin_real(:,i)=data(i).table(:,2);  
    Pdc_real(:,i)=data(i).table(:,3);
    Pout_real(:,i)=data(i).table(:,4);   
    Gain_real(:,i)=data(i).table(:,5);  
    PAE_real(:,i)=data(i).table(:,7);
    DE_real(:,i)=data(i).table(:,6);
    NPR_real(:,i)=data(i).table(:,8);
 %   Att_out(i)=Mea_Attenuator_2(freq(i)); 
end

            
             %fun_VNA_freq_power_set(freq,p_target,VNA_addr,0);
%               scale1 = 'CH1:SCALE 0.02';
%               tri = 'TRIGGER:A:LEVEL:CH1 0.027';
%               I=fun_Main_TBS_Osc(scale1,tri);
%             pause(1);
        % create the data table
        %mea_P(f_idx)=mean(Atten);
       

% 一下code用于plot paper中的图

linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv');
% load('PA_data_2017-08-19-21-39')
Nf=length(data);
freq=zeros(1,Nf);

% figure; plot(data(f_idx).table(:,3),data(f_idx).table(:,10))
% figure; plot(data(f_idx).table(:,3),data(f_idx).table(:,4))

% 平时简单的绘图如下
figure()
hold on
for i=1:Nf
    plot(Pout_real(:,i),Gain_real(:,i),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([10,40,12,22]);
h=legend('27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz','30.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(Pout_real(:,i),DE_real(:,i),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([10,40,0,40]);
h=legend('27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz','30.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(Pout_real(:,i),PAE_real(:,i),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([10,40,0,40]);
h=legend('27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz','30.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PAE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(Pout_real(:,i),NPR_real(:,i),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([10,40,0,40]);
h=legend('27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz','30.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('NPR (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:2:Nf
    plot(Pout_real(:,i),NPR_real(:,i),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([10,40,0,40]);
h=legend('27.5GHz','28.5GHz','29.5GHz','30.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('NPR (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:2:Nf
    plot(Pout_real(:,i),Gain_real(:,i),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([10,40,12,22]);
h=legend('27.5GHz','28.5GHz','29.5GHz','30.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on