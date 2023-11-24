function fun_VNA_freq_power_set(fcenter,power,VNAadd,n)
% VNAadd='TCPIP0::192.168.1.105::hislip0::INSTR';
inst_handle = visa('rs',VNAadd); % VISA 连接，需要工具箱
inst_handle.OutputBufferSize = 1000000; % 缓冲区大小，单位：字节
inst_handle.InputBufferSize = 1000000;
fopen(inst_handle);

fprintf(inst_handle,'*IDN?'); % 仪器验证状态
a=fscanf(inst_handle);
disp(a);

% fprintf(inst_handle,"*RST"); % 此部分表示屏幕上显示的四个迹线
% fprintf(inst_handle,"*CLS");
% fprintf(inst_handle,'CONF:CHAN1:STAT ON');
% fprintf(inst_handle,'SWEep:TYPE LIN');
% points=201; % 数据点数量，设置迹线分辨率
% fprintf(inst_handle, 'SENSE1:SWEEP:POINTS %d',points);
% fcenter=1200000000;
% power=-25;
fprintf(inst_handle,'FREQ %d',fcenter); % 定义中心频率
% fspan= 500000000;
% fprintf(inst_handle,'FREQ:SPAN %d',fspan); % 设置频跨
fprintf(inst_handle,'SOUR:POW %d',power);
if n==1
fprintf(inst_handle,'OUTP ON'); % 打开射频
elseif n==0
fprintf(inst_handle,'OUTP OFF'); % 关闭射频
end
fclose(inst_handle);
delete(inst_handle);
end