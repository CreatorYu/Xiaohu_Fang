function [freq, spectrum1] = Calculated_Spectrum_Real(V,Fs)

% figure()
%     hold on
%         Fs    = 3.87e6      ;
%         h    = spectrum.welch            ;
%         h.OverlapPercent = 90            ;
%         h.SegmentLength  = 2048         ;
%         h.windowName  = 'Flat Top'       ;
%         PSDwithout_DPD = plot(msspectrum(h,I1+1i*Q1 ,'centerdc',Fs));
%         set(PSDwith_DPD ,'Color','black');
%         legend('PSD without DPD','PSD with DPD',2);
% 
% 	hold off
    
    figure()
    
%     V = complex(I1,Q1); 
    h = spectrum.welch;
    h.OverlapPercent = 50;
    h.SegmentLength  = 2^11;%2048;
    h.windowName = 'Flat Top';
%     h.windowName = 'Hamming';
%     h.windowName = 'Chebyshev';

    In  = msspectrum(h,V,'centerdc',Fs );  
    hold on
    grid on
    plot(Fs/2*(-1:2/(h.SegmentLength-1):1)+2140,10*log10(In.data),'r'); hold on;
    xlabel('Frequency (MHz)','FontSize',10)
    ylabel('Power Spectrum Density (dBm)','FontSize',10)
    % legend('Input PSD','Output PSD',4)
    title('Power Spectrum Density','FontSize',12);
    hold on

    freq = Fs/2*(-1:2/(h.SegmentLength-1):1)+2140;
    spectrum1 = 10*log10(In.data);
    
    hold off
%     figure()
%     plot(Fs/2*(-1:2/(h.SegmentLength-1):1)+2140,phase(In.data),'b'); hold on;