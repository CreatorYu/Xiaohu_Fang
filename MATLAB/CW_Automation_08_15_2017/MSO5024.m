clc
clear
%创建 VISA 对象。'ni'为销售商参数，可以为 agilent、NI 或 tek，
%'USB0::0x1AB1::0x04B0::DS2A0000000000::INSTR'为设备的资源描述符。创建后需设置设备的属性，
%本例中设置输入缓存的长度为 2048]
DP2102A_IP='TCPIP::192.168.1.106::INSTR';
Vscale=0.05;
MSO2000A = visa( 'ni',DP2102A_IP );
MSO2000A.InputBufferSize = 1400;
%打开已创建的 VISA 对象
fopen(MSO2000A);
%读取波形


fprintf(MSO2000A, ':WAV:SOUR CHAN1' );

fprintf(MSO2000A, ':wav:mode norm' );
% fprintf(MSO2000A, ':REFerence:VOFFset %f' 0 );
fprintf(MSO2000A,':REFerence:VSCale?')
fread(MSO2000A)
fprintf(MSO2000A, ':REFerence:VSCale 0.1');
% VSCale=fread(MSO2000A);
fprintf(MSO2000A, ':wav:form byte' );
fprintf(MSO2000A, ':WAV:data?' );
[data,len]= fread(MSO2000A,1400);
%
%fprintf(MSO2000A, ':WAV:SOUR CHAN2' );
%fprintf(MSO2000A, ':WAV:data?' );
%[data2,len2]= fread(MSO2000A,1400);
%

 fprintf(MSO2000A, ':WAVeform:XREFerence?' );
 YREF= fread(MSO2000A,1400);
 fprintf(MSO2000A, ':wav:YORigin?' );
 YORigin=fread(MSO2000A);
 fprintf(MSO2000A, ':wav:YINC?' );
 YINC=fread(MSO2000A);
%请求数据


%关闭设备
fclose(MSO2000A);
delete(MSO2000A);
clear MSO2000A;
wave = data(12:len-1);
%wave2 = data2(12:len-1);
wave = wave';
%wave2 = wave2';
plot(wave);
%plot(wave2);
wave_max=max(wave);
wave_min=min(wave);
amplitude=(wave_max-wave_min)*Vscale/25;
Vwave=(wave-127)*Vscale/25;
plot(Vwave);
Vavg=mean(Vwave(648:668))