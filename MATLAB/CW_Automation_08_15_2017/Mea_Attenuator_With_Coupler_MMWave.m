function Mea_Atten = Mea_Attenuator_With_Coupler_MMWave(freq)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
A=xlsread('D:\MMIC_Measurement/Attenuator_With_Coupler_MMWave');
f=A(:,1);
A=A(:,2);
%Mea_Atten=-30;
%freq=5.4e9;
for i=1:21
if freq==f(i)
    Mea_Atten=A(i);
end
end
end