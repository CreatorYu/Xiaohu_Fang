clc
clear
% path('C:\Documents\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurement07-Sep-2017_15_25_12',path);
I = load('I_Output_WithDPD_1.txt');
Q = load('Q_Output_WithDPD_1.txt');


sig  = complex(I(1:100000), Q(1:100000));
ps(sig, 1e9)


sig_nospurs = remove_spurious_specific(sig, 1e9, [-50e6 0]);
