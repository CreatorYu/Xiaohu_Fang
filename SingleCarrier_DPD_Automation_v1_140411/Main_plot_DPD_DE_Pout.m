clc
clear
close all
% %NDPA
% for i=1:1:13
%     if i==1
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24G\200M\MP');
% 
%     elseif i==2
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24_5G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\24_5G\200M\MP');
% 
%     elseif i==3
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25G\200M\MP');
% 
%     elseif i==4
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25_5G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\25_5G\200M\MP');
% 
%     elseif i==5
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26G\200M\MP');
% 
%     elseif i==6
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26_5G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\26_5G\200M\MP');
% 
%     elseif i==7
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27G\200M\MP');
% 
%     elseif i==8
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27_5G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\27_5G\200M\MP');
% 
%     elseif i==9
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28G\200M\MP');
% 
%     elseif i==10
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28_5G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\28_5G\200M\MP');
% 
%     elseif i==11
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29G\200M\MP');
% 
%     elseif i==12
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29_5G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\29_5G\200M\MP');
% 
%     elseif i==13
%     addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\30G\200M\MP',path);
%     filename = 'Summary.txt';                      %文件名
%     delimiterIn = ' ';                          %列分隔符
%     headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
%     c101=importdata(filename,delimiterIn,headerlinesIn);
%     Pout_char=c101{41,1};
%     Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     DE_char=c101{44,1};
%     DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
%     data(i,1)=DE;data(i,2)=Pout;
%     rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\NDPA\30G\200M\MP');
%     end
% end
% data1=str2num(char(data));

%DEPA
for i=1:1:13
    if i==1
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24G\200M\MP');

    elseif i==2
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24_5G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\24_5G\200M\MP');

    elseif i==3
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25G\200M\MP');

    elseif i==4
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25_5G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\25_5G\200M\MP');

    elseif i==5
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26G\200M\MP');

    elseif i==6
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26_5G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\26_5G\200M\MP');

    elseif i==7
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27G\200M\MP');

    elseif i==8
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27_5G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\27_5G\200M\MP');

    elseif i==9
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28G\200M\MP');

    elseif i==10
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28_5G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\28_5G\200M\MP');

    elseif i==11
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29G\200M\MP');

    elseif i==12
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29_5G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\29_5G\200M\MP');

    elseif i==13
    addpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\30G\200M\MP',path);
    filename = 'Summary.txt';                      %文件名
    delimiterIn = ' ';                          %列分隔符
    headerlinesIn =45;                           %读取从第 headerlinesIn+1 行开始的数值数据
    c101=importdata(filename,delimiterIn,headerlinesIn);
    Pout_char=c101{41,1};
    Pout=regexp(Pout_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    DE_char=c101{44,1};
    DE=regexp(DE_char,'\d*\.?\d*','match'); %提取这一行的浮点数
    data(i,1)=DE;data(i,2)=Pout;
    rmpath('D:\Matlab\Xiaohu_Fang\SingleCarrier_DPD_Automation_v1_140411\Measurements\DEPA\30G\200M\MP');
    end
end
data1=str2num(char(data));
