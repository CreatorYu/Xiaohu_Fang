function [ DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q ] = ...
            AdjustDelay_mutual_info ( In_I , In_Q , Out_I , Out_Q , Fs , BlockSize , InterpolationRate , InterpolationOrder  )

    % Get parameters
    UpSample            = InterpolationRate ; 
    Block_Size          = BlockSize ;
    Interpolation_Order = InterpolationOrder ;
    
%% Estimate the Delay	

    length_of_data_used = 10000; % ;
    advNum = 1000;
    fs=Fs;
    % Determine upsamp so that time resolution become < 0.5 ns
    upsamp=round(1/(175e6*0.5e-9))+1;%Don't exceed 25
    downsamp=1;
    max_delay=500e-9;% 500ns
    length_mutualInfo_calc=max_delay*(fs*upsamp)

    %Data
    InI=In_I;
    InQ=In_Q;
    OutI=Out_I;
    OutQ=Out_Q;

    %Offset removal
    avg_in=10*log10(mean((abs(InI+1i*InQ).^2))/100)+30;
    avg_out=10*log10(mean((abs(OutI+1i*OutQ).^2))/100)+30;
    InI=InI*10^((30-avg_in)/20);
    InQ=InQ*10^((30-avg_in)/20);
    OutI=OutI*10^((30-avg_out)/20);
    OutQ=OutQ*10^((30-avg_out)/20);

    %same length for In and out
    if length(InI)< length(OutI)
        OutI=OutI(1:length(InI));
        OutQ=OutQ(1:length(InI));
    else
        InI=InI(1:length(OutI));
        InQ=InQ(1:length(OutI));   
    end

    %Discard the first advNum = 100 data to remove the effects of the system initilization
        InI  = InI(advNum+1:end);
        InQ  = InQ(advNum+1:end);
        OutI = OutI(advNum+1:end);
        OutQ = OutQ(advNum+1:end);

    %take just the right amount of data that will be used in the delay estimation
    if (length(InI)-advNum) > length_of_data_used
        InI=InI(1:length_of_data_used);
        InQ=InQ(1:length_of_data_used);
        OutI=OutI(1:length_of_data_used);
        OutQ=OutQ(1:length_of_data_used);
    end

    %%upsample
    InI=resample(InI,upsamp,downsamp);
    InQ=resample(InQ,upsamp,downsamp);
    OutI=resample(OutI,upsamp,downsamp);
    OutQ=resample(OutQ,upsamp,downsamp);

    %Complex data
    Data_In  = complex(InI ,InQ );
    Data_Out = complex(OutI,OutQ);

    %convert the data to magnitude 
    mag_in  = abs(Data_In );
    mag_out = abs(Data_Out);

    %In out plot to visualise the delay
    figure();
    hold on;
    plot(1:length(Data_In),abs(Data_In));
    plot(1:length(Data_Out),abs(Data_Out), 'r');
    title('datain vs dataout in mutual info function')

    % mutual info computation
    N=length(InI);
    mutual_info_in_out=zeros(length_mutualInfo_calc+1,1);
    for i=0:length_mutualInfo_calc 
        mutual_info_in_out(i+1)=mutualinfo(mag_in(1:N-i),mag_out(1+i:N));   
    end

    %mutual info plot
    figure()
    hold on;
    plot(0:length(mutual_info_in_out)-1,mutual_info_in_out,'black');

    %Estimate the delay
    [value index]=max(mutual_info_in_out);
    timedelay=(index-1)*1/(fs*upsamp)%delay in s


%% Adjust the Estimated Delay    
    if and (timedelay ~= 0 , isnan ( timedelay ) == 0 )
        % Set parameters
            %The original signal will be reduced/augmented to UpSample/DownSample
            DownSample = 1;
            %The length of the FIR filter resample uses is proportional to n. The default for n is 10
            n = 20;
        % Import the data
        %Load the IQ files
            I_in  = In_I ; 
            Q_in  = In_Q ; 
            I_out = Out_I ; 
            Q_out = Out_Q ;
        %Remove useless part of the signal
        	L = min( [ length(I_in)  length(I_out) length(Q_in) length(Q_out) ] ) ;
            I_in = I_in ( 1 : L ) ; I_out = I_out ( 1 : L ) ; 
            Q_in = Q_in ( 1 : L ) ; Q_out = Q_out ( 1 : L ) ;
        % Upsample the Input ant Output
    	progressbar ( 1 / 10 , 0 , 0 ) ;
        Modified_I_in  = resample ( I_in , UpSample , DownSample , n ) ; 
        progressbar ( 2 / 10 , 0 , 0 ) ;
        Modified_Q_in  = resample ( Q_in , UpSample , DownSample , n ) ; 
        progressbar ( 3 / 10 , 0 , 0 ) ;
        Modified_I_out = resample ( I_out ,UpSample , DownSample , n ) ;
        progressbar ( 4 / 10 , 0 , 0 ) ;
        Modified_Q_out = resample ( Q_out , UpSample , DownSample , n ) ;
        progressbar ( 5 / 10 , 0 , 0 ) ;
        %Compute the new Sampling Frequency after UpSampling
        Modified_Fs = UpSample * ( Fs ) ;
        timestep    = 1 / Modified_Fs ;
        Modified_L  = length ( Modified_I_out ) ; 
    % Shift the Input and the Output
        shift     = abs ( round ( timedelay / timestep ) ) ;
        if timedelay < 0
            Modified_I_in  = Modified_I_in ( shift+1 : Modified_L ) ;
            Modified_Q_in  = Modified_Q_in ( shift+1 : Modified_L ) ;
            Modified_I_out = Modified_I_out ( 1:Modified_L-shift ) ;
            Modified_Q_out = Modified_Q_out ( 1:Modified_L-shift ) ;
        elseif timedelay > 0
            Modified_I_in  = Modified_I_in ( 1 : Modified_L-shift ) ;
            Modified_Q_in  = Modified_Q_in ( 1 : Modified_L-shift ) ;
            Modified_I_out = Modified_I_out( shift+1 : Modified_L ) ;
            Modified_Q_out = Modified_Q_out( shift+1 : Modified_L ) ;
        end
        % Downsample
        progressbar ( 6 / 10 , 0 , 0 ) ;
        Modified_I_in = resample ( Modified_I_in , DownSample , UpSample , n ) ;
        progressbar ( 7 / 10 , 0 , 0 ) ;
        Modified_Q_in = resample ( Modified_Q_in , DownSample , UpSample , n ) ;
        progressbar ( 8 / 10 , 0 , 0 ) ;
        Modified_I_out = resample ( Modified_I_out , DownSample , UpSample , n ) ;
        progressbar ( 9 / 10 , 0 , 0 ) ;
        Modified_Q_out = resample ( Modified_Q_out , DownSample , UpSample , n ) ;
        progressbar ( 10 / 10 , 0 , 1 ) ;
    
        %Eliminate corrupted data caused by the interpolation
        DelayAdjusted_In_I  = Modified_I_in ( 1 : length(Modified_I_in)-1 ) ; 
        DelayAdjusted_In_Q  = Modified_Q_in ( 1 : length(Modified_Q_in)-1 ) ; 
        DelayAdjusted_Out_I = Modified_I_out ( 1 : length(Modified_I_out)-1 ) ;
        DelayAdjusted_Out_Q = Modified_Q_out ( 1 : length(Modified_Q_out)-1 ) ;
    else
        L = min( [ length(I_in)  length(I_out) length(Q_in) length(Q_out) ] ) ;
        DelayAdjusted_In_I = I_in ( 1 : L ) ; DelayAdjusted_Out_I = I_out ( 1 : L ) ; 
        DelayAdjusted_In_Q = Q_in ( 1 : L ) ; DelayAdjusted_Out_Q = Q_out ( 1 : L ) ;
    end
    length(I_in)
	plot_AMAM_AMPM_PSD ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , Fs ) ;
    