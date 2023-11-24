%% This function is used to plot the Gain distortion characteristic
function PlotGain(In_I, In_Q, Out_I, Out_Q)
    [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q) ;
        xin  = complex(In_I , In_Q ) ;
        xout = complex(Out_I, Out_Q) ;
    figure()
        hold on
        grid on    
            plot(10*log10(abs(xin).^2/100)+30, 20*log10(abs(xout)./abs(xin)), '.') ;
            axis([-10 10 -5 5]); set(gcf,'color','w');
            title('Gain Distortion', 'FontSize', 20) ;
            xlabel('Input Power (dBm)', 'FontSize', 15) ;
            ylabel('Gain Distortion (dB)', 'FontSize', 15) ;
        hold off        