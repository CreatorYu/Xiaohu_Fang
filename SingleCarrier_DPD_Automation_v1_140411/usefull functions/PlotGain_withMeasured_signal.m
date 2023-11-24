%% This function is used to plot the Gain distortion characteristic
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
        xout = complex(Out_I, Out_Q) ;
    figure()
        hold on
        grid on    
            plot(10*log10(abs(xin).^2/100)+30, 20*log10(abs(xout)./abs(xin)), '.') ;
            title('Gain Distortion', 'FontSize', 20) ;
            xlabel('Input Power (dBm)', 'FontSize', 15) ;
            ylabel('Gain Distortion (dB)', 'FontSize', 15) ;
        hold off        