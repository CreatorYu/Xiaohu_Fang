% function meas_DP821A_CH1=PowerSupply_DP932U(DP821A_IP)
clc
clear
close all
Lan_addr='192.168.1.105';
% dp800 = visa( 'ni',Lan_addr); %创建VISA对象
visa_str = sprintf('TCPIP0::%s::inst0::INSTR', Lan_addr); 
% TCPIP0::192.168.1.105::inst0::INSTR
          obj.socket = visa('ni', visa_str);

dp800=obj.socket;
fopen(dp800); %打开已创建的VISA对象
fprintf(dp800, ':MEAS:ALL? CH2' ); %发送请求
meas_CH1 = fscanf(dp800); %读取数据
meas_DP821A_CH1=str2double(regexp(meas_CH1,',','split'));
fclose(dp800); %关闭VISA对象
% display(meas_DP821A_CH1) %显示已读取的设备信息


        
