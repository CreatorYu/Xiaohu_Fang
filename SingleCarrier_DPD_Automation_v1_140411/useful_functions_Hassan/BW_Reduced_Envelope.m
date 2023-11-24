function [Vdd_BW_Reduced] = BW_Reduced_Envelope(I_orig,Q_orig,BW,Fs)

% load  FIR_filter_fs_100r0MHz_fpass_3r75MHz_Order881.mat
% load  FIR_filter_fs_100r0MHz_fpass_7r5MHz_Order441
load FIR_filter_fs_200r0MHz_fpass_10r0MHz_Order881
FIR_filter_num = Num;

I = [I_orig(end-1e3:end)', I_orig'];
Q = [Q_orig(end-1e3:end)', Q_orig'];

Env = abs(I_orig + 1i*Q_orig);

time = [0:1/Fs:((size(I,2)-1)/Fs)];

V_comp1 = (I+1i*Q).*exp(1i*2*pi*-BW/2*time);
V_comp2 = (I+1i*Q).*exp(1i*2*pi*BW/2*time);

I_fil1 = filter(FIR_filter_num,[1 0], real(V_comp1));
Q_fil1 = filter(FIR_filter_num,[1 0], imag(V_comp1));
I_fil2 = filter(FIR_filter_num,[1 0], real(V_comp2));
Q_fil2 = filter(FIR_filter_num,[1 0], imag(V_comp2));

V_comp1 = (I_fil1+1i*Q_fil1).*exp(1i*2*pi*BW/2*time);
V_comp2 = (I_fil2+1i*Q_fil2).*exp(1i*2*pi*-BW/2*time);

% Calculated_Spectrum(I',Q',Fs);
% Calculated_Spectrum(real(V_comp1+V_comp2),imag(V_comp1+V_comp2),Fs);

% BW_Reduced_Env = abs(V_comp1+V_comp2);
BW_Reduced_Env = abs(complex(I_fil1,Q_fil1)) + abs(complex(I_fil2,Q_fil2));

max_Env = max(Env);
Env = Env./max_Env;
BW_Reduced_Env = BW_Reduced_Env./max_Env;

Vdd_BW_Reduced_temp = BW_Reduced_Env(1e3:(1e3 + size(I_orig,1)-1));
Vdd_BW_Reduced = circshift(Vdd_BW_Reduced_temp',-882/2+1);

% figure(1)
% plot(Env); hold on;
% plot(Vdd_BW_Reduced,'r'); hold on;
end