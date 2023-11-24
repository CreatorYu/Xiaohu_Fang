function Draw_spectrum(I1,Q1,I2,Q2)

figure()
    hold on
        Fs    = 3.87e6      ;
        h    = spectrum.welch            ;
        h.OverlapPercent = 90            ;
        h.SegmentLength  = 2048         ;
        h.windowName  = 'Flat Top'       ;
        PSDwithout_DPD = plot(msspectrum(h,I1+1i*Q1 ,'centerdc',Fs));
        PSDwith_DPD = plot(msspectrum(h,I2+1i*Q2 ,'centerdc',Fs));
        set(PSDwith_DPD ,'Color','black');
        legend('Input PSD','Output PSD');

	hold off
    
