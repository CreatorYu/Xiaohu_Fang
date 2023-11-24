function [DelayAdjusted_In, DelayAdjusted_Out, timedelay] = ...
    AdjustDelay(In, Out, Fs, BlockSize, InterpolationRate, InterpolationOrder)
%% Estimate the Delay
length_of_data_used_for_the_correlation = 46080;
advNum = 1000;
UpSample = InterpolationRate ;
%Elimintate excedent data if they exist
if length ( In ) ~= length ( Out )
    N1 = length ( In  );
    N2 = length ( Out );
    if N1 > N2
        In = In(1:N2);
    elseif N1 < N2
        Out = Out(1:N1);
    end
end
if size ( In ) ~= size ( Out )
    Out = transpose ( In );
end
N = length ( In );
%take just the right amount of data that will be used in the delay estimation
if  N > length_of_data_used_for_the_correlation
    N = length_of_data_used_for_the_correlation;
    In = In ( 1 : N );
    Out = Out ( 1 : N );
end

%Discard the first advNum = 1000 data to remove the effects of the system
%initilization
In  = In ( advNum + 1 : N );
Out  = Out ( advNum + 1 : N );

%convert the data to magnitude
mag_in  = abs ( In  );
mag_out = abs ( Out );

orignalDataBlock_x2 = 2 * ( BlockSize + InterpolationOrder );
mag_in_block_x2  = mag_in (  1 : orignalDataBlock_x2 );
mag_out_block_x2 = mag_out ( 1 : orignalDataBlock_x2 );

%Lagrange interpolation
%For the Output Signal
[time_out_Lagrange, mag_out_Lagrange] = LagrangeInterpolation(mag_out_block_x2,UpSample,InterpolationOrder);
%For the Input Signal
[time_in_Lagrange , mag_in_Lagrange]  = LagrangeInterpolation(mag_in_block_x2,UpSample,InterpolationOrder);

maxlags = floor ( length ( mag_in_Lagrange ) / 2 );
option = 'coeff' ; %, to normalize the sequence so the auto-covariances at zero lag are identically 1.0
[Cxy,lags] = xcov(mag_out_Lagrange,mag_in_Lagrange,maxlags,option); %option: 'coeff', 'unbiased', 'biased'
[ maxCxy , maxCxyIndex ] = max ( Cxy );
maxCxyLag = lags ( maxCxyIndex );
timedelay = ( maxCxyLag / ( ( UpSample + 1 ) * Fs ) ) * 1000.0;
disp(['time delay is ',num2str(timedelay), ' msec' ]);

%plot the corelation results
figure(100);
plot( lags , Cxy , '.r' ) ;
grid off ;
xlabel ( 'Lags' , 'FontSize' , 12 ) ;
ylabel ( 'Cross-Correlation' , 'FontSize' , 12 ) ;
legend ( '\fontsize{12}Cross-Correlation' , 4 ) ;
% adjust the axis properties for IEEE publication
set( gca , 'LineWidth' , 2  ) ;
set( gca , 'FontSize'  , 12 ) ;
%% Adjust the Estimated Delay
if (timedelay ~= 0) && (isnan ( timedelay ) == 0)
    % Set parameters
    %The original signal will be reduced/augmented to UpSample/DownSample
    DownSample = 1;
    %The length of the FIR filter resample uses is proportional to n. The default for n is 10
    n = 20;
    % Upsample the Input ant Output
    Modified_In  = resample ( In , UpSample , DownSample , n ) ;
    Modified_Out  = resample ( Out , UpSample , DownSample , n ) ;
    %Compute the new Sampling Frequency after UpSampling
    Modified_Fs = UpSample * ( Fs ) ;
    timestep    = 1 / Modified_Fs ;
    Modified_L  = length ( Modified_In ) ;
    % Shift the Input and the Output
    shift     = abs ( round ( timedelay * 1e-03 / timestep ) ) ;
    if timedelay < 0
        Modified_In  = Modified_In ( shift+1 : Modified_L ) ;
        Modified_Out = Modified_Out ( 1:Modified_L-shift ) ;
    elseif timedelay > 0
        Modified_In  = Modified_In ( 1 : Modified_L-shift ) ;
        Modified_Out = Modified_Out( shift+1 : Modified_L ) ;
    end
    % Downsample
    Modified_In = resample ( Modified_In , DownSample , UpSample , n ) ;
    Modified_Out = resample ( Modified_Out , DownSample , UpSample , n ) ;
    
    %Eliminate corrupted data caused by the interpolation
    DelayAdjusted_In  = Modified_In ( 1 : length(Modified_In)-1 ) ;
    DelayAdjusted_Out = Modified_Out ( 1 : length(Modified_Out)-1 ) ;
else
    DelayAdjusted_In = In;
    DelayAdjusted_Out = Out;
end

end

