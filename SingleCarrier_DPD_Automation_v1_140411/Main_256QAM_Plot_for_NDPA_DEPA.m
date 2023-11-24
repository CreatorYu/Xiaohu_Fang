clc
clear
close all

path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions',path);
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions\delayAdjustment',path);
addpath(genpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\usefull functions'));
path('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\useful_functions_Hassan',path);

data=[];

%DEPA MP
% for i=1:1:13
%     if i==1
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==2
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24_5G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24_5G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==3
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==4
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25_5G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25_5G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==5
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==6
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26_5G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26_5G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==7
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==8
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27_5G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27_5G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==9
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==10
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28_5G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28_5G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==11
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==12
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29_5G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29_5G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==13
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\30G\200M\MP',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\30G\200M\MP');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
%     end
% end

% %DEPA DDR
% for i=1:1:13
%     if i==1
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==2
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==3
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==4
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==5
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==6
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==7
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==8
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==9
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==10
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==11
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==12
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==13
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\30G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\30G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
%     end
% end

% NDPA MP
for i=1:1:13
    if i==1
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==2
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24_5G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24_5G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==3
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==4
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25_5G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25_5G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==5
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==6
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26_5G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26_5G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==7
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==8
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27_5G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27_5G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==9
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==10
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28_5G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28_5G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==11
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==12
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29_5G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29_5G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;

    elseif i==13
     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\30G\200M\MP',path);
     [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\30G\200M\MP');
     data(i,1)=EVM_withDPD;
     data(i,2)=-ACPR_L_withDPD;
     data(i,3)=-ACPR_U_withDPD;
     data(i,4)=EVM_withoutDPD3;
     data(i,5)=-ACPR_L_withoutDPD;
     data(i,6)=-ACPR_U_withoutDPD;
    end
end

% %NDPA DDR
% for i=1:1:13
%     if i==1
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==2
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==3
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==4
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==5
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==6
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==7
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==8
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==9
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==10
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==11
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==12
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29_5G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29_5G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
% 
%     elseif i==13
%      addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\30G\200M\DDR',path);
%      [EVM_withDPD,ACPR_L_withDPD,ACPR_U_withDPD,EVM_withoutDPD3,ACPR_L_withoutDPD,ACPR_U_withoutDPD]=function_256QAM_demodulate_PA();
%      rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\30G\200M\DDR');
%      data(i,1)=EVM_withDPD;
%      data(i,2)=-ACPR_L_withDPD;
%      data(i,3)=-ACPR_U_withDPD;
%      data(i,4)=EVM_withoutDPD3;
%      data(i,5)=-ACPR_L_withoutDPD;
%      data(i,6)=-ACPR_U_withoutDPD;
%     end
% end

