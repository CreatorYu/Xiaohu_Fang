function Mea_Atten = Mea_Attenuator_SLCG(freq)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
A=xlsread('D:\MMIC_Measurement\SLCG_PA_attenuator\Attenuator');
f=A(:,1);
A=A(:,3);
N=length(f);
%Mea_Atten=-30;
%freq=1e9;
for i=1:N
if freq==f(i)
    Mea_Atten=A(i);
end
end
end