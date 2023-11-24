function [data]=fun_VNA_trace_read(trace)
% ǰ�᣺
% - ��ʹ�� R&S VISA.NET ��װ R&S?VISA 5.11.0 ����߰汾

% �򿪻Ự
 VNAadd='TCPIP0::192.168.1.105::hislip0::INSTR';
inst_handle = visa('rs',VNAadd); % VISA ���ӣ���Ҫ������
inst_handle.OutputBufferSize = 1000000; % ��������С����λ���ֽ�
inst_handle.InputBufferSize = 1000000;
fopen(inst_handle);

fprintf(inst_handle,'*IDN?'); % ������֤״̬
a=fscanf(inst_handle);
disp(a);

% fprintf(inst_handle,"*RST"); % �˲��ֱ�ʾ��Ļ����ʾ���ĸ�����
% fprintf(inst_handle,"*CLS");
% fprintf(inst_handle,'CONF:CHAN1:STAT ON');
% fprintf(inst_handle,'SWEep:TYPE LIN');
% points=201; % ���ݵ����������ü��߷ֱ���
% fprintf(inst_handle, 'SENSE1:SWEEP:POINTS %d',points);
% fcenter=1000000000;
% fprintf(inst_handle,'FREQ:CENT %d',fcenter); % ��������Ƶ��
% fspan= 500000000;
% fprintf(inst_handle,'FREQ:SPAN %d',fspan); % ����Ƶ��
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

% fprintf(inst_handle,'INIT:CONT:ALL OFF'); % ��������ŵ����õ���ɨ��ģʽ��
% fprintf(inst_handle,'INIT:ALL;*WAI'); % �������ŵ��п�ʼһ�ε���ɨ�衣

% timeout=30; % ��ʱ����λ����
% set(inst_handle,'Timeout',timeout); % �ڽ��вɼ�ǰ���ӳ�ʱ���������ͬ������

% fprintf(inst_handle,'MMEMory:CDIRectory "D:\"'); % ����ǰĿ¼��Ϊ Windows ����ʾΪ D: �� USB �洢��
% fprintf(inst_handle,'MMEMory:CDIRectory?'); % �ļ���������S �����������ڴ�λ��
% directory_path=fscanf(inst_handle); % ���ļ����䡱����
% X = 'Target Directory for saving the s2p file=';
% disp(X);
% disp(directory_path);
% fprintf(' Saving s-parameters file ...\n ');
% fprintf(inst_handle,'MMEM:STOR:TRAC:CHAN 1,"vna_traces.s2p"');

% ��һ�����ߴ����� Matlab �����������ݴ������

% fprintf(inst_handle,'INIT1:IMM;*WAI'); % Ϊ�ŵ� 1 ���е���ɨ��
% fprintf('Fetching data points ...\n ');

fprintf(inst_handle,':FORM REAL,32');
fprintf(inst_handle,trace);

data = binblockread(inst_handle,'float32');
fread(inst_handle,1); % fread ɾ���������еĶ�����ֹ��

% fprintf(inst_handle,'CALC1:DATA:TRAC? "Trc2", FDAT');
% data_2 = binblockread(inst_handle,'float32');
% fread(inst_handle,1); % fread ɾ���������еĶ�����ֹ��
% timeout=1; % ��ʱ����λ���룩�ָ�����ֵ
% set(inst_handle,'Timeout',timeout);
% fprintf(inst_handle,':FORM REAL,32');
% fprintf(inst_handle,'CALC1:DATA:TRAC? "Ch1Trc1", STIM?');
% dataX = binblockread(inst_handle,'float32');
% fread(inst_handle,1); % fread ɾ���������еĶ�����ֹ��

%--------------��ͼ����չʾ����---------
% fstart=fcenter-fspan/2;
% fstop=fcenter+fspan/2;
% resolution=fspan/points;
% points_array=1:1:points;
% for c = 1:points % ����ʱ����͹�������
% points_array(1,c)=points_array(1,c)*resolution;
% points_array(1,c)=points_array(1,c) + fstart;
% end
% phase_data=mean(data(1:100));
% Mag_data=abs(data_complex);
% dB_data=20*log10(Mag_data);
% fprintf(inst_handle,':SYST:ERR?\n'); % �������У��
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