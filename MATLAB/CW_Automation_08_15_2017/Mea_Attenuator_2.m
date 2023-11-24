function Mea_Atten = Mea_Attenuator_2(freq)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
A=xlsread('D:\MMIC_Measurement\Doherty_linear_PA\attenuator');
f=A(:,1);
A=A(:,8);
N=length(f);
%Mea_Atten=-30;
%freq=1e9;
for i=1:N
if freq==f(i)
    Mea_Atten=A(i);
end
end
end