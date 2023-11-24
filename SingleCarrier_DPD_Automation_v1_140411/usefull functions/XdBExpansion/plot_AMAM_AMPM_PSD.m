function plot_AMAM_AMPM_PSD(I_in,Q_in,I_out,Q_out,Fs)
	%% AM/AM
    L = min ( [ length(I_in) length(Q_in) length(I_out) length(Q_out) ] ) ;
    I_in = I_in ( 1 : L ) ;
    Q_in = Q_in ( 1 : L ) ;
    I_out = I_out ( 1 : L ) ;
    Q_out = Q_out ( 1 : L ) ;
    figure()
        title('AM/AM Distortion','FontSize',20);
        xlabel('Pin (dBm)','FontSize',15);
        ylabel('Pout./Pin (dB)','FontSize',15);
        Vin  = complex(I_in,Q_in)  ; 
        Vout = complex(I_out,Q_out); 
        rin  = abs(Vin);
        rout = abs(Vout);
        hold on
            plot(10*log10(rin.^2/100)+30 ,10*log10(rout.^2./rin.^2),'.' );
        hold off  
	%% AM/PM
    figure()
        title('AM/PM Distortion','FontSize',20);
        xlabel('Pin (dBm)','FontSize',15);
        ylabel('Phase distortion (degree)','FontSize',15);        
        angle_distortion = atan2(I_in,Q_in)-atan2(I_out,Q_out);        
        Ind = angle_distortion > pi;
        angle_distortion = angle_distortion - 2*Ind*pi;
        Ind = angle_distortion < -pi;
        angle_distortion = angle_distortion + 2*Ind*pi;
        hold on
            plot(10*log10(rin.^2/100)+30,angle_distortion*180/pi,'.') ;
        hold off
	%% PSD
    figure()
        hold on
%         Fs = str2double(get(handles.Tag_Sampling_Frequency_Value,'String'))*10^6;
        h                = spectrum.welch ;
        h.OverlapPercent = 40             ;
        h.SegmentLength  = 2048           ;
        h.windowName     = 'Flat Top'     ;
        msspectrum(h,Vin,'centerdc',Fs)           ;
        H = plot(msspectrum(h,Vout,'centerdc',Fs));
        set(H,'Color','RED')                  ;
        legend('Input PSD','Output PSD',2);
        hold off   