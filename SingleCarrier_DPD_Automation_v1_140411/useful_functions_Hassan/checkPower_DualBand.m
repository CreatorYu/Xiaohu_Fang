%% This function display the mean and max power and the PAPR of a dual band signal
function [meanPower, maxPower, PAPR] = checkPower_DualBand(I1, Q1, I2, Q2, Fsample, Fcarrier1, Fcarrier2,Display)
    switch nargin
        case 4
            Display = false ;
    end
    Upsample = 10;
    I1 = resample(I1,Upsample,1);
    I2 = resample(I2,Upsample,1);
    Q1 = resample(Q1,Upsample,1);
    Q2 = resample(Q2,Upsample,1);
    tstep = Fsample*Upsample;
    time = [0:tstep:(tstep*(size(I1)-1))]';
    Power = abs((I1+1i*Q1).*exp(1i*2*pi*Fcarrier1*time) + (I2+1i*Q2).*exp(1i*2*pi*Fcarrier2*time)).^2;
    meanPower = mean(Power) ;
    meanPower = 10*log10(meanPower/100)+30 ;
    maxPower = max(Power) ;
    maxPower = 10*log10(maxPower/100)+30 ;
    PAPR = maxPower - meanPower ;
    clear Power I1 I2 Q1 Q2 time
    if Display
        display([ 'Average DB Power = ' num2str(floor(100*meanPower)/100) ' dBm' ]);
        display([ 'Max DB Power     = ' num2str(floor(100*maxPower)/100)  ' dBm' ]);
        display([ 'DB PAPR          = ' num2str(floor(100*PAPR)/100)      ' dB ' ]);
    end