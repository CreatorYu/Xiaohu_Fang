function Mea_Atten = Mea_Attenuator_MMWave(freq)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
A=xlsread('D:\MMIC_Measurement\Mea_data_for_MMwave\Attenuator_2023_6_5');
f=A(:,1);
A=A(:,7);
%Mea_Atten=-30;
%freq=5.4e9;
N=length(A);
for i=1:N
if freq==f(i)
    Mea_Atten=A(i);
end
end
end