clc
clear
Y=Y';
In_I_QAM=real(Y);In_Q_QAM=imag(Y)
save D:\Matlab\DPD_2022_09\256QAM_400MHz_In_I_1200r0_PAPR_8r6_12_2us.txt -ascii In_I_QAM
save D:\Matlab\DPD_2022_09\256QAM_400MHz_In_Q_1200r0_PAPR_8r6_12_2us.txt -ascii In_Q_QAM