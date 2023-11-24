%% This function display the mean and max power and the PAPR
function [meanPower, maxPower, PAPR] = checkPower_CCDF(I, Q, Display)
    switch nargin
        case 2
            Display = false ;
    end
	X = complex(I, Q) ;
    Power = abs(X) ;
    Power = Power.^2 ;
    meanPower = mean(Power) ;
    meanPower = 10*log10(meanPower/100)+30 ;

    Probability = 99.99; 
    
    [CDF_in X_CCDF] = ecdf(abs(X));
    X_CCDF_peak = X_CCDF( find(CDF_in > Probability/100) ) ;
    maxPower = X_CCDF_peak(1).^2 ;
    
%     maxPower = max(Power) ;
    maxPower = 10*log10(maxPower/100)+30 ;
    PAPR = maxPower - meanPower ;
    if Display
        display([ 'Average Power = ' num2str(floor(100*meanPower)/100) ' dBm' ]);
        display([ 'Max Power     = ' num2str(floor(100*maxPower)/100)  ' dBm' ]);
        display([ 'PAPR          = ' num2str(floor(100*PAPR)/100)      ' dB ' ]);
    end