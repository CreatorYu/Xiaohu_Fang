%% This function is used to set the maximum power of a signal to a desired value in dBm
function [ I , Q ] = setMaxPower( I , Q , maxPower )
% Find the actual mean power
	X = complex(I, Q) ;
        Offset = abs(X) ;
        	Offset = Offset.^2 ;
            	Offset = max(Offset) ;
                    Offset = 10 * log10(Offset/100) + 30 ;
    % Find the offset
    Offset = - Offset + maxPower ;
        Offset = 10^(Offset/20) ;
    % Adjust the power to meanPower
    I = I*Offset ;
    Q = Q*Offset ;