clc
clear
close all
load('PA_SLCG_voltage_sweep_1_0_2_0G_2023-05-11-20-19.mat');
f_start=1e9;
f_stop=2e9;
f_step=0.2e9;
Nf=(f_stop-f_start)/f_step+1;
for i=1:1:Nf
     DC_Vda(:,i)=data(i).table(:,3);
     Pout_PA(:,i)=data(i).table(:,8);
     DE_PA(:,i)=data(i).table(:,11);
end

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
axis([27,39,15,75]);
h=legend('1.0GHz','1.2GHz','1.4GHz','1.6GHz','1.8GHz','2.0GHz');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Vda (V)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('DE (%)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on