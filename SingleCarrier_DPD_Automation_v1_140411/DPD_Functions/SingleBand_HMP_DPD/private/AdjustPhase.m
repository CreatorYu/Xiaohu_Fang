%% This function is used to make the average phase between the output and the input to zero
function [In, Out] = AdjustPhase(In, Out)
Phase = angle(In)-angle(Out) ;
Ind = Phase>pi ;
Phase = Phase-2*Ind*pi ;
Ind = Phase<-pi ;
Phase = Phase+2*Ind*pi ;
Phase = mean(Phase) ;
Out = Out*exp(1i*Phase) ;

end
