function pin = Mea_driver(indf,indp)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
%indf=1;
%indp=1;
A=xlsread('D:\MMIC_Measurement/Driver_2.xlsx');
A=A(:,indf+1);
pin=A(indp);

end