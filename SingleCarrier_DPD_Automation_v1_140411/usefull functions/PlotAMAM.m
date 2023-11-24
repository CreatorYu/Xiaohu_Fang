%% This function is used to plot the AM/AM characteristic
function PlotAMAM(In_I, In_Q, Out_I, Out_Q)
    [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q) ;
        xin  = complex(In_I , In_Q ) ;
        xout = complex(Out_I, Out_Q) ;
    figure()
        hold on
        grid on    
            plot(10*log10(abs(xin ).^ 2/100)+30, 10*log10(abs(xout).^ 2/100)+30, '.') ;
            title('AM/AM Distortion', 'FontSize', 20) ;
            xlabel('Input Power (dBm)', 'FontSize', 15) ;
            ylabel('Output Power (dBm)', 'FontSize', 15) ;
        hold off