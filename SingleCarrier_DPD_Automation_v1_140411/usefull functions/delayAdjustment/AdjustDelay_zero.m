%% This function align delay between the input and the output signal
function [DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay] = ...
            AdjustDelay_zero(In_I, In_Q, Out_I, Out_Q, Fs, BlockSize, InterpolationRate, InterpolationOrder)
%         Out_I = Out_I(80:end);
%         Out_Q = Out_Q(80:end);
    switch nargin
    	case 4
            Fs = 100e6; ...92.16e6 ;
            BlockSize = 200 ;... 1000 ;
            InterpolationRate = 25 ;
            InterpolationOrder = 3 ;
        case 5
            BlockSize = 1000 ;
            InterpolationRate = 25 ;
            InterpolationOrder = 3 ;
        case 6                
            InterpolationRate = 25 ;
            InterpolationOrder = 3 ;
        case 7 
            InterpolationOrder = 3 ;
    end
%% Estimate the Delay	
	length_of_data_used_for_the_correlation = 20e3;%46080 ;
    advNum = 1000 ;
    % Data
    % Get parameters
        UpSample = InterpolationRate ; 
        Block_Size = BlockSize ;
        Interpolation_Order = InterpolationOrder ;
    %read the input data
        I_in = In_I ; 
        Q_in = In_Q ; 
        I_out = Out_I ; 
        Q_out = Out_Q ; 
	%Elimintate excedent data if they exist
        if length(I_in) ~= length(I_out)
            N1 = length (I_in) ;
            N2 = length (I_out) ;
            if N1>N2
                I_in((N2+1):N1) = [] ;
                Q_in((N2+1):N1) = [] ;
            elseif N1<N2
                I_out((N1+1):N2) = [] ;
                Q_out((N1+1):N2) = [] ;
            end
        end
        if size(I_in) ~= size(I_out)
            I_out = transpose(I_out) ;
            Q_out = transpose(Q_out) ;
        end
        N = length(I_in) ;
    %take just the right amount of data that will be used in the delay estimation
    if  N > length_of_data_used_for_the_correlation
        N = length_of_data_used_for_the_correlation ;
        I_in = I_in(1:N) ; 
        I_out = I_out(1:N) ;
        Q_in = Q_in(1:N) ;
        Q_out = Q_out(1:N) ;
    end
    %Discard the first advNum = 1000 data to remove the effects of the system initilization
        I_in = I_in(advNum+1:N) ;
        I_out = I_out(advNum+1:N) ;
        Q_in = Q_in(advNum+1:N) ;
        Q_out = Q_out(advNum+1:N) ;
    
	%Create the complex data
        Data_In = complex(I_in, Q_in) ;
        Data_Out = complex(I_out, Q_out) ;
    
	%convert the data to magnitude 
        mag_in = abs(Data_In) ;
        mag_out = abs(Data_Out) ;

    orignalDataBlock_x2 = 2*(Block_Size+Interpolation_Order) ;
    mag_in_block_x2 = mag_in(1:orignalDataBlock_x2) ;
    mag_out_block_x2 = mag_out(1:orignalDataBlock_x2) ;

    %Lagrange interpolation
    %For the Output Signal
        [time_out_Lagrange,mag_out_Lagrange] = LagrangeInterpolation(mag_out_block_x2, UpSample, Interpolation_Order, 0) ; 
    %For the Input Signal    
        [time_in_Lagrange,mag_in_Lagrange] = LagrangeInterpolation(mag_in_block_x2, UpSample, Interpolation_Order, 1) ;
    
	maxlags = floor(length(mag_in_Lagrange)/2) ;
    option = 'coeff' ; %, to normalize the sequence so the auto-covariances at zero lag are identically 1.0 
    [Cxy, lags] = xcov(mag_out_Lagrange, mag_in_Lagrange, maxlags, option) ; %option: 'coeff', 'unbiased', 'biased'
    [maxCxy, maxCxyIndex] = max(Cxy) ;
    maxCxyLag = lags(maxCxyIndex) ;
    timedelay = (maxCxyLag/((UpSample+1)*Fs))*1000.0 ;
    progressbar (1, 0, 1) ;
    
    %plot the corelation results
    figure();
        plot(lags, Cxy, '.r') ;
        grid off ;
        xlabel('Lags', 'FontSize', 12) ;
        ylabel('Cross-Correlation', 'FontSize', 12) ;
    %    legend('\fontsize{12}Cross-Correlation', 4) ;
        % adjust the axis properties for IEEE publication
        set(gca, 'LineWidth', 2) ;
        set(gca, 'FontSize', 12) ;
        pause(0.0001) ; %allows the display of the figure before adjusting the delay

%% Adjust the Estimated Delay    
    if and(timedelay~=0, isnan(timedelay)==0)
        % Set parameters
            %The original signal will be reduced/augmented to UpSample/DownSample
            DownSample = 1;
            %The length of the FIR filter resample uses is proportional to n. The default for n is 10
            n = 20;
        % Import the data
        %Load the IQ files
            I_in = In_I ; 
            Q_in = In_Q ; 
            I_out = Out_I ; 
            Q_out = Out_Q ;
        %Remove useless part of the signal
        	L = min([length(I_in), length(I_out), length(Q_in), length(Q_out)]) ;
            I_in = I_in(1:L) ; 
            I_out = I_out(1:L) ; 
            Q_in = Q_in(1:L) ;
            Q_out = Q_out(1:L) ;
        % Upsample the Input ant Output
    	progressbar(1/10, 0, 0) ;
        Modified_I_in = resample(I_in, UpSample, DownSample, n) ; 
        progressbar(2/10, 0, 0) ;
        Modified_Q_in = resample(Q_in, UpSample, DownSample, n) ; 
        progressbar(3/10, 0, 0) ;
        Modified_I_out = resample(I_out, UpSample, DownSample, n) ;
        progressbar(4/10, 0, 0) ;
        Modified_Q_out= resample(Q_out, UpSample, DownSample, n) ;
        progressbar(5/10, 0, 0) ;
        %Compute the new Sampling Frequency after UpSampling
        Modified_Fs = UpSample*(Fs) ;
        timestep = 1/Modified_Fs ;
        Modified_L = length(Modified_I_out) ; 
    % Shift the Input and the Output
        shift = abs(round(timedelay*1e-03/timestep)) ;
        if timedelay<0
%             Modified_I_in = Modified_I_in(shift+1:Modified_L) ;
%             Modified_Q_in = Modified_Q_in(shift+1:Modified_L) ;
%             Modified_I_out = Modified_I_out(1:Modified_L-shift) ;
%             Modified_Q_out = Modified_Q_out(1:Modified_L-shift) ;
            
            Modified_I_in = Modified_I_in;
            Modified_Q_in= Modified_Q_in;
           % Modified_I_out = Modified_I_out(1-shift:Modified_L-2*shift) ;
%            Modified_I_out=[]
            Modified_I_out = [Modified_I_out(1-shift+Modified_L:Modified_L);Modified_I_out(1:Modified_L-shift)];            
             Modified_Q_out = [Modified_Q_out(1-shift+Modified_L:Modified_L);Modified_Q_out(1:Modified_L-shift)];                
        elseif timedelay>0
            Modified_I_in = Modified_I_in(1:Modified_L-shift) ;
            Modified_Q_in = Modified_Q_in(1:Modified_L-shift) ;
            Modified_I_out = Modified_I_out(shift+1:Modified_L) ;
            Modified_Q_out = Modified_Q_out(shift+1:Modified_L) ;
        end
    % Downsample
        progressbar(6/10, 0, 0) ;
        Modified_I_in = resample(Modified_I_in, DownSample, UpSample, n) ;
        progressbar(7/10, 0, 0) ;
        Modified_Q_in = resample(Modified_Q_in, DownSample, UpSample, n) ;
        progressbar(8/10, 0, 0) ;
        Modified_I_out = resample(Modified_I_out, DownSample, UpSample, n) ;
        progressbar(9/10, 0, 0) ;
        Modified_Q_out = resample(Modified_Q_out, DownSample, UpSample, n) ;
        progressbar(10/10, 0 ,1 ) ;    
    %Eliminate corrupted data caused by the interpolation
        DelayAdjusted_In_I = Modified_I_in(1:length(Modified_I_in)-1) ; 
        DelayAdjusted_In_Q = Modified_Q_in(1:length(Modified_Q_in)-1) ; 
        DelayAdjusted_Out_I = Modified_I_out(1:length(Modified_I_out)-1) ;
        DelayAdjusted_Out_Q = Modified_Q_out(1:length(Modified_Q_out)-1) ;
    else
        L = min([length(I_in), length(I_out), length(Q_in), length(Q_out)]) ;
        DelayAdjusted_In_I = I_in(1:L) ; 
        DelayAdjusted_Out_I = I_out(1:L) ; 
        DelayAdjusted_In_Q = Q_in(1:L) ;
        DelayAdjusted_Out_Q = Q_out(1:L) ;
    end