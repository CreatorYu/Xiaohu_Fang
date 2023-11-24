InI_beforeDPD_path = '../Signals/4CWCDMA_I_122p88_7dB.txt';
InQ_beforeDPD_path = '../Signals/4CWCDMA_Q_122p88_7dB.txt';


In_I_beforeDPD = load(InI_beforeDPD_path); In_I_beforeDPD = In_I_beforeDPD(:, 1);
In_Q_beforeDPD = load(InQ_beforeDPD_path); In_Q_beforeDPD = In_Q_beforeDPD(:, 1);

iqdata1=complex(In_I_beforeDPD,In_Q_beforeDPD);


InI_beforeDPD_path2 = '../Signals/1001CWCDMA_I_122p88_7dB.txt';
InQ_beforeDPD_path2 = '../Signals/1001CWCDMA_Q_122p88_7dB.txt';

In_I_beforeDPD2 = load(InI_beforeDPD_path2); In_I_beforeDPD2 = In_I_beforeDPD2(:, 1);
In_Q_beforeDPD2 = load(InQ_beforeDPD_path2); In_Q_beforeDPD2 = In_Q_beforeDPD2(:, 1);

iqdata2=complex(In_I_beforeDPD2,In_Q_beforeDPD2);

marker = [];
% iqdata = [];
fs = 122.88e6;

ipfct = @(data,r) interp(double(data), r);
factor = 40;
 iqdata1 = ipfct(iqdata1, factor);
 iqdata2 = ipfct(iqdata2, factor);

 fs = fs * factor;
 
    fc1 = 2e9-100e6;
    n = length(iqdata1);
    iqdata1 = iqdata1 .* exp(1i*2*pi*round(n*fc1/fs)/n*(1:n)');
    
    fc2 = 2e9+100e6;
    n = length(iqdata2);
    iqdata2 = iqdata2 .* exp(1i*2*pi*round(n*fc2/fs)/n*(1:n)');
    
    iqdata=iqdata1+iqdata2;
    
    
assignin('base', 'iqdata', iqdata);
assignin('base', 'fs', fs);

 iqplot(iqdata, fs, 'marker', marker);