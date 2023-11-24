function Pin_driver_max=fun_SBP_Driver_out2in(Pout_driver_max,Freq_real) 
% load('driver_data_SBP_23_31G_2023-08-28-11-38.mat')
load('driver_data_SBP_24G_31G_2023-09-01-11-33.mat')
% Pout_driver_max=33;  Freq_real=0.5;
if Freq_real>1e7
    Freq_real=Freq_real/1e9;
end
Freq=24:0.5:31; 
Gain_LP=Gain(1,:);
Gain_esti=interp1(Freq,Gain_LP,Freq_real,'linear');
Pin_driver_max=Pout_driver_max-Gain_esti;
end


% Pin_real=-35:1:-10; Freq_real=1:0.1:3.6;
% Freq=0.5:0.1:4; Pin=pin';
% [X,Y]=meshgrid(Freq,Pin);
% [Xq,Yq]=meshgrid(Freq_real,Pin_real);
% % zz = interp2(x,y,vl,x2,y2,'bicubic');
% % Gain_real= interp2(pin,Freq,Gain,Pin_real,Freq_real,'linear');
% Gain_real= interp2(X,Y,Gain,Xq,Yq,'linear');
% % [Xq,Yq] = meshgrid(-3:0.2:3);
% figure()
% plot(Freq,Gain(1,:),'-r',Freq_real,Gain_real(1,:),'-b');
% figure()
% plot(Freq,Gain(1,:));

