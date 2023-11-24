function meas_DP821A_CH1=PowerSupply_DP821A(DP821A_IP)
dp800 = visa( 'ni',DP821A_IP); %创建VISA对象
fopen( dp800 ); %打开已创建的VISA对象
fprintf(dp800, ':MEAS:ALL? CH1' ); %发送请求
meas_CH1 = fscanf(dp800); %读取数据
meas_DP821A_CH1=str2double(regexp(meas_CH1,',','split'));
fclose(dp800); %关闭VISA对象
% display(meas_DP821A_CH1) %显示已读取的设备信息
end


        
