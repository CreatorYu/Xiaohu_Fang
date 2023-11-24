clc
clear
close all
for i=1:1:6
    if i==1
        load('PA_SLCG_voltage_sweep_1G_2023-05-11-17-03.mat');
    elseif  i==2
        load('PA_SLCG_voltage_sweep_1_2G_2023-05-11-17-12.mat');
    elseif  i==3
        load('PA_SLCG_voltage_sweep_1_4G_2023-05-11-17-14.mat');
    elseif   i==4
        load('PA_SLCG_voltage_sweep_1_6G_2023-05-11-17-16.mat');
    elseif   i==5
        load('PA_SLCG_voltage_sweep_1_8G_2023-05-11-17-20.mat');
    elseif  i==6
        load('PA_SLCG_voltage_sweep_2_0G_2023-05-11-17-22.mat');
    end
     DC_Vda(:,i)=data(1).table(:,3);
     Pout_PA(:,i)=data(1).table(:,8);
     DE_PA(:,i)=data(1).table(:,11);
end
f_start=1e9;
f_stop=2e9;
f_step=0.2e9;
Nf=(f_stop-f_start)/f_step+1;

linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv');
figure()
hold on
for i=1:Nf
    plot(DC_Vda(:,i),Pout_PA(:,i),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([27,39,35,43]);
h=legend('1.0GHz','1.2GHz','1.4GHz','1.6GHz','1.8GHz','2.0GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Vda (V)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Pout (dBm)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on

figure()
hold on
for i=1:Nf
    plot(DC_Vda(:,i),DE_PA(:,i),linestyle1(i,:),'linewidth',1)
end
% for i=1:Nx
%     plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
%     plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
% end
set(gcf,'color','w');
axis([27,39,15,70]);
h=legend('1.0GHz','1.2GHz','1.4GHz','1.6GHz','1.8GHz','2.0GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Vda (V)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on