function fun_VNA_freq_power_set(fcenter,power,VNAadd,n)
% VNAadd='TCPIP0::192.168.1.105::hislip0::INSTR';
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
% fcenter=1200000000;
% power=-25;
fprintf(inst_handle,'FREQ %d',fcenter); % ��������Ƶ��
% fspan= 500000000;
% fprintf(inst_handle,'FREQ:SPAN %d',fspan); % ����Ƶ��
fprintf(inst_handle,'SOUR:POW %d',power);
if n==1
fprintf(inst_handle,'OUTP ON'); % ����Ƶ
elseif n==0
fprintf(inst_handle,'OUTP OFF'); % �ر���Ƶ
end
fclose(inst_handle);
delete(inst_handle);
end