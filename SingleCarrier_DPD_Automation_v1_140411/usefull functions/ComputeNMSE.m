%% This function calculate the Normalized mean square error between two signals
function NMSE = ComputeNMSE(In_I, In_Q, Out_I, Out_Q, Display)
    switch nargin
        case 4
            Display = false ;
    end
%     [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q);
        xin = complex(In_I, In_Q) ;
        xout = complex(Out_I, Out_Q) ; 
	NMSE = 10*log10(sum(abs(xin-xout).^2)/sum(abs(xin).^2)) ;
    if Display
        display(['NMSE = ' num2str(NMSE)]) ;
    end
