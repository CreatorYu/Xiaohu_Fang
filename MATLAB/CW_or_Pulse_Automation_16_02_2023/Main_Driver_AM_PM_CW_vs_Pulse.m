clc
clear
close all
load('Driver_5_4GHz_CW.mat')
Pin_CW=Pin;
Pout_CW=Pout;
Phase_CW=Phase-mean(Phase);
Gain_CW=Gain-mean(Gain);
%
% load('Driver_5_4GHz_Pulse.mat')
% Pin_Pulse=Pin;
% Pout_Pulse=Pout;
% Phase_Pulse=Phase-mean(Phase);
% Gain_Pulse=Gain-mean(Gain);
%
load('PA_5_4GHz_Pulse.mat')
Pin_PA_Pulse=Pin;
Pout_PA_Pulse=Pout;
Phase_PA_Pulse=Phase-mean(Phase);
Gain_PA_Pulse=Gain-mean(Gain);

%
figure(1)
plot(Pin_CW,Gain_CW,'-r',Pin_PA_Pulse,Gain_PA_Pulse,'-b')
figure(2)
plot(Pin_CW,Phase_CW,'-r',Pin_PA_Pulse,Phase_PA_Pulse,'-b')
figure(3)
plot(Pin,Gain)
% save('Driver_5_4GHz_CW.mat')
% save('Driver_5_4GHz_Pulse.mat')

