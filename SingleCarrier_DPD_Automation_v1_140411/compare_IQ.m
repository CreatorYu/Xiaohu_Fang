In_I_afDPD     = load(['Signals\' '40MHz_WCDMA_I_Input_PreDist_1_resample.txt']); 
In_Q_afDPD     = load(['Signals\' '40MHz_WCDMA_Q_Input_PreDist_1_resample.txt']); 
% In_I_afDPD     = load(['Signals\' '40MHz_WCDMA_I_Input_PreDist_1.txt']); 
% In_Q_afDPD     = load(['Signals\' '40MHz_WCDMA_Q_Input_PreDist_1.txt']); 
In_I_beDPD     = load(['Signals\' 'WCDMA111_LTE15_40MHz_In_I_200r0_PAPR_8r4_1ms.txt']); 
In_Q_beDPD     = load(['Signals\' 'WCDMA111_LTE15_40MHz_In_Q_200r0_PAPR_8r4_1ms.txt']); 

% In_I_afDPD = resample(In_I_afDPD, 20,16);
% In_Q_afDPD = resample(In_Q_afDPD, 20,16);

% In_I_beDPD     = load(['Signals\' '20MHz_WDMA_I_Input_PreDist_1.txt']); 
% In_Q_beDPD     = load(['Signals\' '20MHz_WDMA_Q_Input_PreDist_1.txt']); 
% In_I_afDPD     = load(['Signals\' 'WCDMA3G_4C_In_I_100r0_PAPR_7r14_1ms.txt']); 
% In_Q_afDPD     = load(['Signals\' 'WCDMA3G_4C_In_Q_100r0_PAPR_7r14_1ms.txt']); 

env_beDPD       = abs(In_I_beDPD+1i*In_Q_beDPD); 
env_afDPD       = abs(In_I_afDPD+1i*In_Q_afDPD); 
% env_afDPD       = abs(In_I_afDPD_re+1i*In_Q_afDPD_re);

normfactor_beDPD= max(env_beDPD);
env_beDPD       = env_beDPD/normfactor_beDPD;

normfactor_afDPD= max(env_afDPD);
env_afDPD       = env_afDPD/normfactor_afDPD;

figure(1)
clf; hold on;
plot(env_beDPD, 'r');
plot(env_afDPD, 'b');


% cd('Signals')
% fidIEH = fopen(['40MHz_WCDMA_I_Input_PreDist_1_resample.txt'],'wt');
% fprintf(fidIEH,'%12.20f\n',In_I_afDPD);
% fclose(fidIEH);
% fidIEH = fopen(['40MHz_WCDMA_Q_Input_PreDist_1_resample.txt'],'wt');
% fprintf(fidIEH,'%12.20f\n',In_Q_afDPD);
% fclose(fidIEH);
% cd ..