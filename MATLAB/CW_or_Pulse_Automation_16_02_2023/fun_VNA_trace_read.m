function [data]=fun_VNA_trace_read(trace)
% 前提：
% - 已使用 R&S VISA.NET 安装 R&S?VISA 5.11.0 或更高版本

% 打开会话
 VNAadd='TCPIP0::192.168.1.105::hislip0::INSTR';
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
% fcenter=1000000000;
% fprintf(inst_handle,'FREQ:CENT %d',fcenter); % 定义中心频率
% fspan= 500000000;
% fprintf(inst_handle,'FREQ:SPAN %d',fspan); % 设置频跨
% fprintf(inst_handle,'SOUR:POW -20');
% fprintf(inst_handle,'BANDwidth 1000');
% fprintf(inst_handle,'TRIG:SOUR IMM');
% fprintf(inst_handle,'CALCulate:PARameter:DELete:ALL');
% fprintf(inst_handle,'CALC1:PAR:SDEF "Ch1Trc1", "S21" ');
% fprintf(inst_handle,'DISP:WIND1:TRAC1:FEED "Ch1Trc1"');
% fprintf(inst_handle,'CALC1:PAR:SDEF "Ch1Trc2", "S11" ');
% fprintf(inst_handle,'DISP:WIND1:TRAC2:FEED "Ch1Trc2"');
% fprintf(inst_handle,'CALC1:PAR:SDEF "Ch1Trc3", "S12" ');
% fprintf(inst_handle,'DISP:WIND1:TRAC3:FEED "Ch1Trc3"');
% fprintf(inst_handle,'CALC1:PAR:SDEF "Ch1Trc4", "S22" ');
% fprintf(inst_handle,'DISP:WIND1:TRAC4:FEED "Ch1Trc4"');

% fprintf(inst_handle,'INIT:CONT:ALL OFF'); % 针对所有信道启用单次扫描模式。
% fprintf(inst_handle,'INIT:ALL;*WAI'); % 在所有信道中开始一次单次扫描。

% timeout=30; % 超时，单位：秒
% set(inst_handle,'Timeout',timeout); % 在进行采集前增加超时，避免出现同步错误

% fprintf(inst_handle,'MMEMory:CDIRectory "D:\"'); % 将当前目录设为 Windows 中显示为 D: 的 USB 存储器
% fprintf(inst_handle,'MMEMory:CDIRectory?'); % 文件管理器，S 参数将保存在此位置
% directory_path=fscanf(inst_handle); % “文件传输”概念
% X = 'Target Directory for saving the s2p file=';
% disp(X);
% disp(directory_path);
% fprintf(' Saving s-parameters file ...\n ');
% fprintf(inst_handle,'MMEM:STOR:TRAC:CHAN 1,"vna_traces.s2p"');

% 将一个迹线传输至 Matlab 工作区，数据传输概念

% fprintf(inst_handle,'INIT1:IMM;*WAI'); % 为信道 1 运行单次扫描
% fprintf('Fetching data points ...\n ');

fprintf(inst_handle,':FORM REAL,32');
fprintf(inst_handle,trace);

data = binblockread(inst_handle,'float32');
fread(inst_handle,1); % fread 删除缓冲区中的额外终止符

% fprintf(inst_handle,'CALC1:DATA:TRAC? "Trc2", FDAT');
% data_2 = binblockread(inst_handle,'float32');
% fread(inst_handle,1); % fread 删除缓冲区中的额外终止符
% timeout=1; % 超时（单位：秒）恢复正常值
% set(inst_handle,'Timeout',timeout);
% fprintf(inst_handle,':FORM REAL,32');
% fprintf(inst_handle,'CALC1:DATA:TRAC? "Ch1Trc1", STIM?');
% dataX = binblockread(inst_handle,'float32');
% fread(inst_handle,1); % fread 删除缓冲区中的额外终止符

%--------------在图表中展示迹线---------
% fstart=fcenter-fspan/2;
% fstop=fcenter+fspan/2;
% resolution=fspan/points;
% points_array=1:1:points;
% for c = 1:points % 缩放时间轴和功率数据
% points_array(1,c)=points_array(1,c)*resolution;
% points_array(1,c)=points_array(1,c) + fstart;
% end
% phase_data=mean(data(1:100));
% Mag_data=abs(data_complex);
% dB_data=20*log10(Mag_data);
% fprintf(inst_handle,':SYST:ERR?\n'); % 错误队列校验
% a=fscanf(inst_handle);
% disp(a);
fclose(inst_handle);
delete(inst_handle);

% Pin=-35:0.2:-13;
% figure(1)
% plot(Pin,data,'r-');
% axis([-35 -13 -140 -130]);
% figure(2)
% plot(Pin,data_2,'b-');
% axis([-35 -13 15 17]);
end