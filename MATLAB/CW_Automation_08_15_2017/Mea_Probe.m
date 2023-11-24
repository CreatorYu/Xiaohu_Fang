function Mea_Atten = Mea_Probe(freq)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
A=xlsread('D:\MMIC_Measurement\Probe_NDPA');
f=A(:,1);
A=A(:,2);
%Mea_Atten=-30;
%freq=5.4e9;
N=length(A);

for i=1:N
if freq==f(i)
    Mea_Atten=A(i);
end
end
end