clc
clear
close all

path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions',path);
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions\delayAdjustment',path);
addpath(genpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions'));
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\useful_functions_Hassan',path);

data=[];

for i=1:1:13
    if i==1
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\24_5G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\24_5G');


    elseif i==2
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\25G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\25G');
    

    elseif i==3
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\25_5G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\25_5G');
   

    elseif i==4
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\26G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\26G');
    

    elseif i==5
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\26_5G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\26_5G');
    

    elseif i==6
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\27G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\27G');
  
    elseif i==7
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\27_5G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\27_5G');
     

    elseif i==8
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\28G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\28G');
    

    elseif i==9
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\28_5G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\28_5G');
    

    elseif i==10
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\29G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\29G');
     

    elseif i==11
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\29_5G',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_mmwave();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurements_singlePA\200M_2023_6_8\29_5G');

    
    end
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;
     
end

