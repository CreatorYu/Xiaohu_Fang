%% This function is used to combine two signals
function [I, Q] = Combine_Signal(I1, Q1, I2, Q2, f1, fs1, f2, fs2, Fs)
    % compute the upsampling rate for the first signal
        [Upsample1, Downsample1] = rat(Fs/fs1) ;
            I1 = resample(I1, Upsample1, Downsample1) ;
            Q1 = resample(Q1, Upsample1, Downsample1) ;
        data1 = complex(I1, Q1) ;
    % compute the upsampling rate for the second signal
        [Upsample2, Downsample2] = rat(Fs/fs2) ;
            I2 = resample(I2, Upsample2, Downsample2) ;
            Q2 = resample(Q2, Upsample2, Downsample2) ;
        data2  = complex( I2 , Q2 ) ;
    L = min(length(data1), length(data2)) ;
        data1 = data1(1:L) ;
        data2 = data2(1:L) ;
    % modualte the first signal around -f1 and second signal around f2
        t = transpose(0:1/Fs:1e-3-1/Fs) ; % a frame of 1ms max
            if length(t)<L
                data1 = data1(1:length(t)) ;
            else
                t = t(1:L) ;
            end
    % normalize f1 and f2
        fc = (f2+f1)/2 ;
        f2 = (f2-fc) ;
        f1 = (f1-fc) ;
        data1 = data1.*exp(-1i*2*pi*(f2-Fs)*t) ;
        data2 = data2.*exp(-1i*2*pi*(f1-Fs)*t) ;    
        data = data1 + data2 ;
    I = real(data) ;
    Q = imag(data) ;