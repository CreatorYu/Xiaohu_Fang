%% This function is used to plot the Gain distortion characteristic
function PlotGain_WithWithout(In_I, In_Q, Out_I, Out_Q, Out_I2, Out_Q2)
    [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q) ;
    [In_I, In_Q, Out_I2, Out_Q2] = UnifyLength(In_I, In_Q, Out_I2, Out_Q2) ;
        xin  = complex(In_I , In_Q ) ;
        xout = complex(Out_I, Out_Q) ;
        xout2 = complex(Out_I2, Out_Q2) ;
    figure()
        hold on
        grid on    
            plot(10*log10(abs(xin).^2/100)+30, 20*log10(abs(xout)./abs(xin)), '.') ; hold on;
            plot(10*log10(abs(xin).^2/100)+30, 20*log10(abs(xout2)./abs(xin)), '.r') ;
            title('Gain Distortion', 'FontSize', 20) ;
            xlabel('Input Power (dBm)', 'FontSize', 15) ;
            ylabel('Gain Distortion (dB)', 'FontSize', 15) ;
        hold off        