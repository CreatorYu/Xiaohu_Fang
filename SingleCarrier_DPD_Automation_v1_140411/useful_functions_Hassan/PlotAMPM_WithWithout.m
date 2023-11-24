%% This function is used to plot the AM/PM characteristic
function PlotAMPM_WithWithout(In_I, In_Q, Out_I, Out_Q, Out_I2, Out_Q2)
    [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q) ;
    [In_I, In_Q, Out_I2, Out_Q2] = UnifyLength(In_I, In_Q, Out_I2, Out_Q2) ;
        xin  = complex(In_I , In_Q ) ;
    figure()        
        hold on    
        grid on
        % Compute the phase distortion
        Phaseout = atan2(Out_Q, Out_I)-atan2(In_Q, In_I) ;
        Phaseout2 = atan2(Out_Q2, Out_I2)-atan2(In_Q, In_I) ;
        % Wrap the phase to -pi to pi
        Ind = Phaseout>pi ;
            Phaseout = Phaseout-2*Ind*pi ;
        Ind = Phaseout<-pi ;
            Phaseout = Phaseout+2*Ind*pi ;
            
        Ind2 = Phaseout2>pi ;
            Phaseout2 = Phaseout2-2*Ind2*pi ;
        Ind2 = Phaseout2<-pi ;
            Phaseout2 = Phaseout2+2*Ind2*pi ;
        % plot the AMPM response in Degrees
        plot( 10*log10(abs(xin).^ 2/100)+30, Phaseout.*(180/pi), 'b.') ; 
        plot( 10*log10(abs(xin).^ 2/100)+30, Phaseout2.*(180/pi), 'r.') ; 
            title('AM/PM Distortion', 'FontSize', 20) ;
            xlabel('Input Power (dBm)', 'FontSize', 15) ;
            ylabel('Phase Distortion (degree)', 'FontSize', 15) ;
        hold off