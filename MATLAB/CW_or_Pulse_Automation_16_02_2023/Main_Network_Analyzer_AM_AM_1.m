clc
clear
Nt=10;
[data,data_2]=fun_VNA_S21_phase_read;
for i=1:Nt
    [data_t,data_2_t]=fun_VNA_S21_phase_read;
    data=(data+data_t)/2;
    data_2=(data_2+data_2_t)/2;
end
Pin1=-30; Pin2=-15;
Nd=length(data);
Step=(Pin2-Pin1)/(Nd-1);
Pin=Pin1:Step:Pin2; Pin=Pin';
Phase=data;
Gain=data_2;
Pout=Pin+Gain;
figure(1)
plot(Pout,Gain)
figure(2)
plot(Pout,Phase)
figure(3)
plot(Pin,Gain)
% save('Driver_5_4GHz_CW.mat')
save('PA_5_4GHz_Pulse.mat')