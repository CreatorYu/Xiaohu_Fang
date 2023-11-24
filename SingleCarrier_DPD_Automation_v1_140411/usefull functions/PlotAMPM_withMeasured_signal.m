%% This function is used to plot the AM/PM characteristic

InI_path = 'I_no_VS_in_20MHz_850MHz.txt';
OutI_path = 'I_no_VS_out_20MHz_850MHz.txt';
InQ_path = 'Q_no_VS_in_20MHz_850MHz.txt';
OutQ_path = 'Q_no_VS_out_20MHz_850MHz.txt';

In_I     = load(['To_Plot\' InI_path]); 
In_Q     = load(['To_Plot\' InQ_path]); 
Out_I     = load(['To_Plot\' OutI_path]); 
Out_Q     = load(['To_Plot\' OutQ_path]); 

    [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q) ;
        xin  = complex(In_I , In_Q ) ;
    figure()        
        hold on    
        grid on
        % Compute the phase distortion
        Phaseout = atan2(Out_Q, Out_I)-atan2(In_Q, In_I) ;
        % Wrap the phase to -pi to pi
        Ind = Phaseout>pi ;
            Phaseout = Phaseout-2*Ind*pi ;
        Ind = Phaseout<-pi ;
            Phaseout = Phaseout+2*Ind*pi ;
        % plot the AMPM response in Degrees
        plot( 10*log10(abs(xin).^ 2/100)+30, Phaseout.*(180/pi), 'r.') ; 
            title('AM/PM Distortion', 'FontSize', 20) ;
            xlabel('Input Power (dBm)', 'FontSize', 15) ;
            ylabel('Phase Distortion (degree)', 'FontSize', 15) ;
        hold off