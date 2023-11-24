%% This function is used to set the mean power of a signal to a desired value in dBm
function [I, Q] = setMeanPower(I, Q, meanPower)
    % Find the actual mean power
	X = complex(I, Q) ;
        Offset = abs(X) ;
        	Offset = Offset.^2 ;
            	Offset = mean(Offset) ;
                    Offset = 10 * log10(Offset/100) + 30 ;
    % Find the offset
    Offset = - Offset + meanPower ;
        Offset = 10^(Offset/20) ;
    % Adjust the power to meanPower
    I = I*Offset ;
    Q = Q*Offset ;