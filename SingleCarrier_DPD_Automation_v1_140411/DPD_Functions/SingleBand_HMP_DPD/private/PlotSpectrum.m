%% This function is used to plot the Spectrum
function PlotSpectrum(In, Out, id , Fs, vargin)
% check if Fs and h are given as input variable or set them to
% default values
switch nargin
    case 2
        id = 0 ;
        Fs = 100e6;
        %             Fs = 92.16e6; %default value
        h = spectrum.welch ;
        h.OverlapPercent = 95 ;
        h.SegmentLength = 4096 ;
        h.windowName = 'Flat Top';
    case 3
        Fs = 92.16e6; %default value
        h = spectrum.welch ;
        h.OverlapPercent = 95 ;
        h.SegmentLength = 4096 ;
        h.windowName = 'Flat Top';
    case 4
        h = spectrum.welch ;
        h.OverlapPercent = 95 ;
        h.SegmentLength = 4096 ;
        h.windowName = 'Flat Top';
end
if id
    figure(id)
else
    figure()
end
hold on
grid on
PSDin = plot(msspectrum(h, In, 'centerdc', Fs)) ;
set(PSDin, 'Color', 'blue', 'LineWidth', 2) ;
PSDout = plot(msspectrum(h, Out, 'centerdc', Fs)) ;
set(PSDout, 'Color', 'red', 'LineWidth', 2 ) ;
legend( 'Input Power Spectrum Density' , 'Output Power Spectrum Density' , 1);
hold off

end
