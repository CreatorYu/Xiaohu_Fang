function Pout_driver_real=fun_SBP_Driver_in2out(Pin_real, Freq_real)
% load('driver_data_SBP_23_31G_2023-08-28-11-38.mat');
load('driver_data_SBP_24G_31G_2023-09-01-11-33.mat')
% Freq=0.5:0.1:4; Freq_real=0.5;
% Pout_driver_max=33; 
% Gain_LP=Gain(1,:);
% Gain_esti=interp1(Freq,Gain_LP,Freq_real,'linear');
% Pin_driver_max=Pout_driver_max-Gain_esti;
% Pin_real=-10; Freq_real=1;
if Freq_real>1e7
    Freq_real=Freq_real/1e9;
end
Freq=24:0.5:31; Pin=pin';
fd_idx=round(1+(Freq_real-24)/0.5);
[X,Y]=meshgrid(Freq,Pin);
[Xq,Yq]=meshgrid(Freq_real,Pin_real);
% zz = interp2(x,y,vl,x2,y2,'bicubic');
% Gain_real= interp2(pin,Freq,Gain,Pin_real,Freq_real,'linear');
Gain_real= interp2(X,Y,Gain,Xq,Yq,'linear');
% [Xq,Yq] = meshgrid(-3:0.2:3);
Pout_driver_real=Pin_real+Gain_real;
if Pin_real < -40
   Pout_driver_real=Pin_real+Gain(1,fd_idx);   
end

