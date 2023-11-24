clc
clear
close all
% frequency settings of PA                      
f_start =24.5e9;
f_stop =29e9;
f_step =0.5e9;
RFfreq=f_start:f_step:f_stop;
Nf=length(RFfreq);
Np_interp=25;
Pin_interp=zeros(Nf,Np_interp);
Gain_interp=zeros(Nf,Np_interp);
Phase_PA_Driver_interp=zeros(Nf,Np_interp);
Pout_interp=zeros(Nf,Np_interp);
Phase_PA_Driver_n=zeros(Nf,Np_interp);


for i=1:Nf
    if RFfreq(i)==24.5e9
        load('MMwave_single_PA_24_5GHz_pulse.mat');
    elseif RFfreq(i)==25e9
        load('MMwave_single_PA_25GHz_pulse.mat');
    elseif RFfreq(i)==25.5e9
        load('MMwave_single_PA_25_5GHz_pulse.mat')
    elseif RFfreq(i)==26e9
        load('MMwave_single_PA_26GHz_pulse.mat') 
    elseif RFfreq(i)==26.5e9
        load('MMwave_single_PA_26_5GHz_pulse.mat')
    elseif RFfreq(i)==27e9
        load('MMwave_single_PA_27GHz_pulse.mat')
    elseif RFfreq(i)==27.5e9
        load('MMwave_single_PA_27_5GHz_pulse.mat')
    elseif RFfreq(i)==28e9
        load('MMwave_single_PA_28GHz_pulse.mat')
    elseif RFfreq(i)==28.5e9
        load('MMwave_single_PA_28_5GHz_pulse.mat')
    else
        load('MMwave_single_PA_29GHz_pulse.mat')
    end
    Np=length(Gain_PA);
    Pin=1:1:Np;
    Pin_interp(i,:)=1:(Np-1)/(Np_interp-1):Np;
    Gain_interp(i,:)=interp1(Pin,Gain_PA,Pin_interp(i,:),'linear');
    Phase_PA_Driver_interp(i,:)=interp1(Pin,Phase_PA_Driver,Pin_interp(i,:),'linear');
    Phase_PA_Driver_n(i,:)=Phase_PA_Driver_interp(i,:)-Phase_PA_Driver_interp(i,1);
    Pout_interp(i,:)=interp1(Pin,Pout,Pin_interp(i,:),'linear');
    Gain_PA=[]; Phase_PA_Driver=[]; Pout=[]; 
end

linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv', '-bv', '-gs', '-y>', '-k<','-r*', '-m^', '-cv');
% Np=21; Np_interp=25;
% Pin=1:1:Np;
% Pin_test=1:(Np-1)/(Np_interp-1):Np;

figure()
hold on
for i=1:Nf
    plot(Pout_interp(i,:),Phase_PA_Driver_n(i,:),linestyle1(i,:),'linewidth',2);
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


