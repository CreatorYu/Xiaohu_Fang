function [error per]= EVM_calculate (I_in,Q_in,I_out,Q_out)
%% Offset Alignment
%     X = complex( I_in , Q_in ) ;
%     avgPowerX = abs( X ) ;
%     avgPowerX = 10 * log10( mean(avgPowerX .^ 2) / 100 ) + 30 ;
%     Offset_In =  10 ^ ( - avgPowerX / 20 ) ;
% 
%     I_in = I_in * Offset_In ; 
%     Q_in = Q_in * Offset_In ;
% 
%     rin  = abs( complex( I_in  ,  Q_in  ) ) ;
%     rout = abs( complex( I_out , Q_out  ) ) ;
% 
%     Offset_Out = 10 * ( ( log10( mean(rin.^ 2) ) ) - ( log10( mean(rout.^ 2) ) ) ) ;
%     Offset_Out = 10 ^ ( Offset_Out / 20 ) ;
% 
%     Out_I = I_out * Offset_Out ; 
%     Out_Q = Q_out * Offset_Out ;
%     
    %%  Phase Alignement
    
%     x_in  = complex(I_in,Q_in);
%     y_out = complex(Out_I,Out_Q);
%     
%     phase = angle(y_out) - angle(x_in);
%     Ind = phase > 2*pi;
%         phase = phase - 2*Ind*pi;
%     Ind = phase <= 0;
%         phase = phase + 2*Ind*pi;
%     mean_phase = mean(phase);
%     
%     y_out = y_out.*exp(-1i* mean_phase);
%     
%     Out_I = real(y_out);
%     Out_Q = imag(y_out);
    
%% EVM error calculation

    Out_I = I_out;
    Out_Q = Q_out;
   
    x_in  = complex(I_in,Q_in);
    y_out = complex(Out_I,Out_Q);
    
    Perror = mean(abs(y_out-x_in).^2);
    Pref = mean(abs(x_in).^2);
    error = 10*log10( Perror / Pref );
    
    E = mean((I_in-Out_I).^2 + (Q_in-Out_Q).^2);
    ref = mean(I_in.^2 + Q_in.^2);
    per = 100 * sqrt(E/ref);
