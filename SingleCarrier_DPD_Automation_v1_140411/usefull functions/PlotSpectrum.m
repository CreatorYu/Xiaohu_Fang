%% This function is used to plot the Spectrum
function PlotSpectrum(In_I, In_Q, Out_I, Out_Q, id , Fs, h)
    [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q);
        xin  = complex( In_I  , In_Q  ) ;
        xout = complex( Out_I , Out_Q ) ; 
        % check if Fs and h are given as input variable or set them to
        % default values
    switch nargin
        case 4
            id = 0 ;
           Fs = 100e6;
             Fs = 92.16e6; %default value
            h = spectrum.welch ;
            h.OverlapPercent = 95 ;
            h.SegmentLength = 4096 ;
            h.windowName = 'Flat Top';
        case 5
            Fs = 92.16e6; %default value
            h = spectrum.welch ;
            h.OverlapPercent = 95 ;
            h.SegmentLength = 4096;
            h.windowName = 'Flat Top';
        case 6
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
        PSDin = plot(msspectrum(h, xin, 'centerdc', Fs)) ;
            set(PSDin, 'Color', 'blue', 'LineWidth', 2) ;
        PSDout = plot(msspectrum(h, xout, 'centerdc', Fs)) ;
            set(PSDout, 'Color', 'red', 'LineWidth', 2 ) ;
        legend( 'Input Power Spectrum Density' , 'Output Power Spectrum Density');
        hold off
