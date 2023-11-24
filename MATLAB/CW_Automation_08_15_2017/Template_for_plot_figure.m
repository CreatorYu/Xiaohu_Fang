% 一下code用于plot paper中的图
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<');
figure(10)
hold on
for i=1:Nx
    plot(Pout_dB_legend(:,i),eff_legend(:,i),linestyle1(i,:),'linewidth',2);
end
for i=1:Nx
    plot(Pout_dB_mark(:,i),eff_mark(:,i),linestyle1(i,2:3),'linewidth',2);
    plot(Pout_dB(:,i),eff(:,i),linestyle1(i,1:2),'linewidth',2);
end
set(gcf,'color','w');
axis([-20,0,0,90]);
h=legend('x_n=0, OBO=4.78','x_n=1, OBO=6.27','x_n=2, OBO=8.77','x_n=3, OBO=11.04','x_n=4, OBO=12.97');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Normalized output Power (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Drain Efficiency','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off    
grid on
% 平时简单的绘图如下
