% ǰ�᣺
% - ��ʹ�� R&S VISA.NET ��װ R&S?VISA 5.11.0 ����߰汾

% �򿪻Ự
clc;
clear
inst_handle = visa('rs','TCPIP0::192.168.1.103::hislip0::INSTR'); % VISA ���ӣ���Ҫ������
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
% % fprintf(inst_handle, 'SENSE1:SWEEP:POINTS %d',points);
% fcenter=1000000000;
% % fprintf(inst_handle,'FREQ:CENT %d',fcenter); % ��������Ƶ��
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

fprintf(inst_handle,'INIT1:IMM;*WAI'); % Ϊ�ŵ� 1 ���е���ɨ��
fprintf('Fetching data points ...\n ');

fprintf(inst_handle,':FORM REAL,32');
fprintf(inst_handle,'CALC1:DATA:TRAC? "Trc1", FDAT');

data = binblockread(inst_handle,'float32');
fread(inst_handle,1); % fread ɾ���������еĶ�����ֹ��
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
plot(1:N1,data);
axis([1,2000,-180,180]);
N1=length(data);
real_data=data(1:2:N1-1);
imag_data=data(2:2:N1);
data_complex=complex(real_data,imag_data);
N2=length(data_complex);
data_complex_Avg=mean(data_complex(100:floor(N2-100)));
phase_data=phase(data_complex)/pi*180;
% Mag_data=abs(data_complex);
% dB_data=20*log10(Mag_data);
plot(1:N1/2,phase_data);
axis([1,2000,-180,180]);
% dataAvg=mean(data(100:floor(N1-100)));
% fprintf(inst_handle,':SYST:ERR?\n'); % �������У��
% a=fscanf(inst_handle);
% disp(a);
fclose(inst_handle);
delete(inst_handle);