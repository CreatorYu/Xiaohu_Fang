function Voltage_Setting_DP821A(DP821A_IP,voltage,channel)
% DP821A_IP='TCPIP0::192.168.1.101::INSTR';        % set the address of voltage source
% channel=2;
% voltage=4.8;
dp800 = visa( 'ni',DP821A_IP); %创建VISA对象
fopen( dp800 ); %打开已创建的VISA对象
Voltage_str = sprintf(':SOURce%s:VOLT %s',num2str(channel),num2str(voltage)); %conbine voltage struct
fprintf(dp800, Voltage_str); %发送请求
% meas_CH1 = fscanf(dp800); %读取数据
% meas_DP821A_CH1=str2double(regexp(meas_CH1,',','split'));
fclose(dp800); %关闭VISA对象
% display(meas_DP821A_CH1) %显示已读取的设备信息
end


        
