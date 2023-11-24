%% This function is used to make the average phase between the output and the input to zero
function [In_I, In_Q, Out_I, Out_Q] = AdjustPhase(In_I, In_Q, Out_I, Out_Q)
	In  = complex(In_I, In_Q) ;
	Out = complex(Out_I, Out_Q) ;
    Phase = angle(In)-angle(Out) ;
        Ind = Phase>pi ;
            Phase = Phase-2*Ind*pi ;
        Ind = Phase<-pi ;
            Phase = Phase+2*Ind*pi ;
        Phase = mean(Phase) ;
            Out = Out*exp(1i*Phase) ;
                Out_I = real(Out) ;
                Out_Q = imag(Out) ;