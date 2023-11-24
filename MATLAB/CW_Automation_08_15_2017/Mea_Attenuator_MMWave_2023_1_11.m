function Mea_Atten = Mea_Attenuator_MMWave_2023_1_11(freq)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
A=xlsread('D:\MMIC_Measurement\Attenuator_MMWave_on_wafer');
f=A(:,1);
A=A(:,6);
N=length(f);
%Mea_Atten=-30;
%freq=1e9;
for i=1:N
if freq==f(i)
    Mea_Atten=A(i);
end
end
end