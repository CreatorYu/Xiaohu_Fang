function pin = Mea_driver_sub6G(fs1,fs2,indf,indp)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
%indf=1;
% indp=1;
% A=xlsread('D:\MMIC_Measurement/Driver_MMWave_Single_PA.xlsx');
% A=A(:,10:16);
% pin=A(indp,:);
%  fs1=5e9;
%  fs2=6e9;
%  indp=5;
%  indf=3;
f_start =4.8e9;
f_stop =6e9;
f_step =0.1e9;
f_idx1 = ceil(1+(fs1-f_start)/f_step);
f_idx2 = ceil(1+(fs2-f_start)/f_step);
A=xlsread('D:\MMIC_Measurement\Driver_sub6G_on_wafer_2023_1_11');
A=A(:,f_idx1:f_idx2);
pin=A(indp,indf);
end
% 
