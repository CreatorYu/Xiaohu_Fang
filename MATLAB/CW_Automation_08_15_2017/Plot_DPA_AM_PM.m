%
clc
clear
close all
clear all
path('D:\Document\08_17_2017\Xiaohu_Fang\Document\Xiaohu_Fang\CW_Automation_08_15_2017\Test_data',path);
%
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<');
load('PA_data_2017-09-07-17-43')
Nf=length(data);
freq=zeros(1,Nf);
Psat=zeros(1,Nf);
for i=1:Nf
    freq(i)=data(i).frequency;
    Psat(i)=max(data(i).table(:,3));
end 
% figure; plot(data(f_idx).table(:,3),data(f_idx).table(:,10))
% figure; plot(data(f_idx).table(:,3),data(f_idx).table(:,4))
figure(1)
hold on
for i=1:Nf
    plot(data(i).table(:,3),data(i).table(:,10),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([20,40,0,60]);
h=legend('4.7GHz','4.8GHz','4.9GHz','5.0GHz','5.1GHz','5.2GHz','5.3GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Drain Efficiency','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
% 平时简单的绘图如下
figure(2)
hold on
for i=1:Nf
    plot(data(i).table(:,3),data(i).table(:,4),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([20,40,0,10]);
h=legend('4.7GHz','4.8GHz','4.9GHz','5.0GHz','5.1GHz','5.2GHz','5.3GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
figure(3)
hold on
for i=1:Nf
    plot(data(i).table(:,3),data(i).table(:,6)*1000,linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([20,40,0,300]);
h=legend('4.7GHz','4.8GHz','4.9GHz','5.0GHz','5.1GHz','5.2GHz','5.3GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
for i=1:Nf
    plot(data(i).table(:,3),data(i).table(:,8)*1000,linestyle1(i,:),'linewidth',1)
end
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Output Power (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DC Drain Current (mA)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
%
figure(4)
hold on
plot(freq/1e9, Psat, linestyle1(1,:),'linewidth',1)
set(gcf,'color','w');
axis([4.7,5.3,37,40]);
% h=legend('4.9GHz','5.0GHz','5.1GHz');
% set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Saturation Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
