%% This function is used to plot the AM/PM characteristic
function PlotAMPM(In_I, In_Q, Out_I, Out_Q)
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
        axis([-10 10 -30 30]); set(gcf,'color','w');
            title('AM/PM Distortion', 'FontSize', 20) ;
            xlabel('Input Power (dBm)', 'FontSize', 15) ;
            ylabel('Phase Distortion (degree)', 'FontSize', 15) ;
        hold off