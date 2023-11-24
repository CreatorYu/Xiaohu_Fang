function [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay] = ...
            UltraFineAdjustDelay_EVM_Method(In_I, In_Q, Out_I, Out_Q, Fs, ResampleRate, ResampleOrder)
    switch nargin
    	case 4
            Fs            = 100e6; %92.16e6 ;
            ResampleRate  = 100 ;
            ResampleOrder = 10 ;
        case 5
            ResampleRate  = 100 ;
            ResampleOrder = 10 ;
        case 6                
            ResampleOrder = 10 ;
    end        
        
    lags           = (-30:1:30); % search window for EVM estimation
    MaxDataLength  = 5e3;
%% Power alignment
    [In_I, In_Q]   = setMeanPower(In_I, In_Q, 0);
    [Out_I, Out_Q] = setMeanPower(Out_I, Out_Q, 0);
    FineTimeStep   = 1 / Fs / ResampleRate; 
    FineTimeAdjust = lags * FineTimeStep;  
    N              = length(In_I) ;
    if  N > MaxDataLength
        N = MaxDataLength ;
        I_in = In_I(1:N) ; 
        Q_in = In_Q(1:N) ;
        I_out = Out_I(1:N) ;
        Q_out = Out_Q(1:N) ;
    end      

    % ultra fine delay adjust based on EVM 
    EVM_perc_array = size(FineTimeAdjust);
    for ind = 1 : length(FineTimeAdjust)
         progressbar(ind/length(FineTimeAdjust), 0, 0) ;
        [t_I, t_Q] = UltraFineTimeDelay_Adjust(I_in, Q_in, Fs, ResampleRate,ResampleOrder, FineTimeAdjust(ind));
        [A,B,C,D]  = AdjustPowerAndPhase(t_I, t_Q, I_out, Q_out, 0);
        [EVM_dB EVM_perc] = EVM_calculate (A,B,C,D);
        EVM_perc_array(ind) = EVM_perc;
    end

    [minEVM, minEVMIndex] = min(EVM_perc_array) ; 
    shift     = abs(lags(minEVMIndex));
    timedelay = FineTimeAdjust(minEVMIndex); % in ps
  
%     %plot the corelation results
%     figure();
%     plot(lags, EVM_perc_array, '.r') ;
%     grid off ;
%     xlabel('Lags', 'FontSize', 12) ;
%     ylabel('Fine Delay (EVM Method)', 'FontSize', 12) ;
%     legend('\fontsize{12}EVM', 4) ;
%     % adjust the axis properties for IEEE publication
%     set(gca, 'LineWidth', 1) ;
%     set(gca, 'FontSize', 12) ;
%     pause(0.0001) ; %allows the display of the figure before adjusting the delay

%% Adjust the Estimated Delay    
        I_in        = In_I ; 
        Q_in        = In_Q ; 
        I_out       = Out_I ; 
        Q_out       = Out_Q ;        

    if and(timedelay~=0, isnan(timedelay)==0)
        L           = min([length(I_in), length(I_out), length(Q_in), length(Q_out)]) ;
        I_in        = I_in(1:L) ; 
        I_out       = I_out(1:L) ; 
        Q_in        = Q_in(1:L) ;
        Q_out       = Q_out(1:L) ; 
    % Shift the Input and the Output
        [I_in, Q_in] = UltraFineTimeDelay_inChunk(I_in, Q_in, Fs, ResampleRate, ResampleOrder, timedelay);   
    %Eliminate corrupted data caused by the interpolation
        DelayAdjusted_In_I  = I_in(ResampleOrder * 2 : end - ResampleOrder*2) ; 
        DelayAdjusted_In_Q  = Q_in(ResampleOrder * 2 : end - ResampleOrder*2) ; 
        DelayAdjusted_Out_I = I_out(ResampleOrder * 2 : end - ResampleOrder*2) ;
        DelayAdjusted_Out_Q = Q_out(ResampleOrder * 2 : end - ResampleOrder*2) ;
    else
        L = min([length(I_in), length(I_out), length(Q_in), length(Q_out)]) ;
        DelayAdjusted_In_I = I_in(1:L) ; 
        DelayAdjusted_Out_I = I_out(1:L) ; 
        DelayAdjusted_In_Q = Q_in(1:L) ;
        DelayAdjusted_Out_Q = Q_out(1:L) ;
    end
end