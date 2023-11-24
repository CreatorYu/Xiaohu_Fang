function [freq, spectrum1] = CalculatedSpectrum(In, Fs)
figure()

h = spectrum.welch;
h.OverlapPercent = 50;
h.SegmentLength  = 2^11;%2048;
h.windowName = 'Flat Top';
%     h.windowName = 'Hamming';
%     h.windowName = 'Chebyshev';

In  = msspectrum(h,In,'centerdc',Fs );
hold on
grid on
plot(Fs/2*(-1:2/(h.SegmentLength-1):1)+2140,10*log10(In.data),'r');
xlabel('Frequency (MHz)','FontSize',10)
ylabel('Power Spectrum Density (dBm)','FontSize',10)
% legend('Input PSD','Output PSD',4)
title('Power Spectrum Density','FontSize',12);
hold on

freq = Fs/2*(-1:2/(h.SegmentLength-1):1)+2140;
spectrum1 = 10*log10(In.data);

hold off

end
