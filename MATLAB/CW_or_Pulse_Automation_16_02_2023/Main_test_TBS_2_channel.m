% Main_test_TBS_2_channel
%
clc
clear
scale1 = 'CH1:SCALE 0.02';
scale2 = 'CH1:SCALE 0.1';
tri = 'TRIGGER:A:LEVEL:CH2 0.10';
I_m=fun_Main_TBS_Osc_ch(scale2,tri);
I_a=fun_Main_TBS_Osc_ch2(scale1,tri);
