clc
clear
close all
%
% load('PA_data_Pulse2022-10-26-15-38.mat')
% performance1=Performan_PA;
% Performan_PA=[];
% 
% load('PA_data_Pulse2022-10-26-16-08.mat')
% performance2=Performan_PA;
% Performan_PA=[];
% 
% load('PA_data_Pulse2022-10-26-16-19.mat')
% performance3=Performan_PA;
% save('NDPA.mat','performance1','performance2','performance3');
load('NDPA.mat');

f_start =24.0e9;
f_stop =30e9;
f_step =0.5e9;
% desired characterization power range (in dBm) at the output of the driver

p_min1 = -35;
p_max1 = -25;
p_step = 1;
%
p_min2 = -25;
p_max2 = -16;
%
p_min3 = -16;
p_max3 = -10;

Pout_real1=[]; Pout_real2=[]; Pout_real3=[];

n=2;
for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    for p_target=p_min1:p_step:p_max1
        p_idx = 1+(p_target-p_min1)/p_step;
        Pin_real1(p_idx,f_idx)=performance1(p_idx+n-1,1);
        Pout_real1(p_idx,f_idx)=performance1(p_idx+n-1,5);   
        Gain_real1(p_idx,f_idx)=performance1(p_idx+n-1,6);
        DE_real1(p_idx,f_idx)=performance1(p_idx+n-1,7);
        PAE_real1(p_idx,f_idx)=performance1(p_idx+n-1,8);  
  %       Att_out(f_idx)=Mea_Attenuator_MMWave_2(freq);
    end
    n=n+30;
end
n=2;
for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    for p_target=p_min2:p_step:p_max2
        p_idx = 1+(p_target-p_min2)/p_step;
        Pin_real2(p_idx,f_idx)=performance2(p_idx+n-1,1);
        Pout_real2(p_idx,f_idx)=performance2(p_idx+n-1,5);   
        Gain_real2(p_idx,f_idx)=performance2(p_idx+n-1,6);
        DE_real2(p_idx,f_idx)=performance2(p_idx+n-1,7);
        PAE_real2(p_idx,f_idx)=performance2(p_idx+n-1,8);  
  %       Att_out(f_idx)=Mea_Attenuator_MMWave_2(freq);
    end
    n=n+30;
end
n=2;
for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    for p_target=p_min3:p_step:p_max3
        p_idx = 1+(p_target-p_min3)/p_step;
        Pin_real3(p_idx,f_idx)=performance3(p_idx+n-1,1);
        Pout_real3(p_idx,f_idx)=performance3(p_idx+n-1,5);   
        Gain_real3(p_idx,f_idx)=performance3(p_idx+n-1,6);
        DE_real3(p_idx,f_idx)=performance3(p_idx+n-1,7);
        PAE_real3(p_idx,f_idx)=performance3(p_idx+n-1,8);  
  %       Att_out(f_idx)=Mea_Attenuator_MMWave_2(freq);
    end
    n=n+30;
end
[N1,N2]=size(Pin_real2);
Pin_real=[]
Pin_real=[Pin_real1;Pin_real2(2:N1-1,:);Pin_real3];
Pout_real=[Pout_real1;Pout_real2(2:N1-1,:);Pout_real3];
Gain_real=[Gain_real1;Gain_real2(2:N1-1,:);Gain_real3];
DE_real=[DE_real1;DE_real2(2:N1-1,:);DE_real3];
PAE_real=[PAE_real1;PAE_real2(2:N1-1,:);PAE_real3];

%% Interpolate the DE and PAE to find 6dB Back-off DE and PAE
PAE_max=max(PAE_real);
Pout_max=max(Pout_real);
Gain_max=max(Gain_real);
for i=1:N2
    PAE_6dB(i)=interp1(Pout_real(:,i),PAE_real(:,i),Pout_max(i)-6,'linear');
    DE_6dB(i)=interp1(Pout_real(:,i),DE_real(:,i),Pout_max(i)-6,'linear');
    Pout_1dB(i)=interp1(Gain_real(:,i),Pout_real(:,i),Gain_max(i)-3,'linear');
end
 


%
%% Correct the error in the output power
[N1,N2]=size(Pout_real);
Pout_W_real=10.^((Pout_real-30)/10);
PDC_real=Pout_W_real./DE_real*100;
for i=1:N1
    for k=1:N2
        if Pout_real(i,k)<10
            Pout_real(i,k)=(Pout_real(i-1,k)+Pout_real(i+1,k))/2;
        end
    end
end
Pout_W_real2=10.^((Pout_real-30)/10);
Pin_W_real2=10.^((Pin_real-30)/10);
Gain_real=Pout_real-Pin_real-0.7;
DE_real=Pout_W_real2./PDC_real*100;
PAE_real=(Pout_W_real2-Pin_W_real2)./PDC_real*100;


%% Plot Data
RFfreq=(f_start:f_step:f_stop)/1e9;
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv','-bs','-g>', '-y<', '-ko');
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
plot(RFfreq,max(Pout_real),'-ro');
plot(RFfreq,Pout_1dB,'-bv')
set(gcf,'color','w');
h=legend('Saturation','1dB Compression');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');   
hold off

figure()
hold on
% plot(RFfreq,max(DE_real),'-ro');
plot(RFfreq,max(PAE_real), '-ro');
% plot(RFfreq,DE_6dB,'-c^');
plot(RFfreq,PAE_6dB-1, '-bv');
set(gcf,'color','w');
axis([24,30,0,40]);
h=legend('Saturation PAE','6dB PAE');
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
axis([20,38,10,25]);
h=legend('24.0GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz');
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
 %axis([10,20,0,50]);
h=legend('23.5GHz','24.0GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz');
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
axis([20,38,0,40]);
h=legend('24.0GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PAE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:N2
    plot(Pin_real(:,i),Pout_real(:,i),linestyle1(i,:),'linewidth',2);
end
set(gcf,'color','w');
% axis([-20,0,0,30]);
h=legend('23.5GHz','24.0GHz','24.5GHz','25GHz','25.5GHz','26GHz','26.5GHz','27GHz','27.5GHz','28GHz','28.5GHz','29GHz','29.5GHz','30GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Input Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on


figure()
hold on
for i=1:2:11
    plot(Pout_real(:,i),Gain_real(:,i),linestyle1((i+1)/2,:),'linewidth',2);
end
plot(Pout_real(:,7),Gain_real(:,7),linestyle1(7,:),'linewidth',2);
set(gcf,'color','w');
axis([20,38,10,25]);
h=legend('24GHz','25GHz','26GHz','27GHz','28GHz','29GHz','29.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:2:11
    plot(Pout_real(:,i),PAE_real(:,i),linestyle1((i+1)/2,:),'linewidth',2);
end
plot(Pout_real(:,7),PAE_real(:,7),linestyle1(7,:),'linewidth',2);
set(gcf,'color','w');
axis([20,38,0,40]);
h=legend('24GHz','25GHz','26GHz','27GHz','28GHz','29GHz','29.5GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PAE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on