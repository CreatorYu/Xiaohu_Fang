function [pin,S21_D] = Mea_driver_MMWave_CW(fs1,fs2,indf,indp)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
%indf=1;
% indp=1;
% A=xlsread('D:\MMIC_Measurement/Driver_MMWave_Single_PA.xlsx');
% A=A(:,10:16);
% pin=A(indp,:);
% fs1=28.5e9;
% fs2=29.5e9;
% indp=5;
% indf=3;
S21=[];
load('Driver_MMWave_PA_data_CW2023-01-12-17-13.mat')
A=mea_Pout;
f_start =20e9;
f_stop =30e9;
f_step =0.5e9;
f_idx1 = ceil(1+(fs1-f_start)/f_step);
f_idx2 = ceil(1+(fs2-f_start)/f_step);
%A=xlsread('D:\MMIC_Measurement\Driver_MMWave_Doherty_PA');
if f_idx1==f_idx2
   A1=A(:,f_idx1);
   pin=A1(indp);
   S21_M=S21(:,f_idx1);
   S21_D=S21_M(indp);
else
   A1=A(:,f_idx1:f_idx2);
   pin=A1(indp,indf);
   S21_M=S21(:,f_idx1:f_idx2);
   S21_D=S21_M(indp,indf);
end

% 
