%% This function is used to plot the Spectrum
function acpr = ACPR(In_I, In_Q, Out_I, Out_Q, id , Fs, h)
    [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q);
        xin  = complex( In_I  , In_Q  ) ;
        xout = complex( Out_I , Out_Q ) ; 
        % check if Fs and h are given as input variable or set them to
        % default values
    switch nargin
        case 4
            id = 0 ;
            Fs = 92.16e6; %default value
            h = spectrum.welch ;
            h.OverlapPercent = 95 ;
            h.SegmentLength = 4096 ;
            h.windowName = 'Flat Top';
        case 5
            Fs = 92.16e6; %default value
            h = spectrum.welch ;
            h.OverlapPercent = 95 ;
            h.SegmentLength = 4096 ;
            h.windowName = 'Flat Top';
        case 6
            h = spectrum.welch ;
            h.OverlapPercent = 95 ;
            h.SegmentLength = 4096 ;
            h.windowName = 'Flat Top';
    end
        acpr = msspectrum(h, xout, 'centerdc', Fs) ;
        acpr = smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(smooth(10*log10(acpr.data))))))))))))))))) ;
        acpr = max(acpr([1680:1780 1880:2000 2000:2200 2300:2400]))-max(acpr([300:1600 2500:3800])) ;
