%% This fucntion is used to adjust the SSG and the phase of two signals to 0
function [In, Out] = AdjustPowerAndPhase(In, Out, PowerInputdB)
[In, Out] = UnifyLength(In, Out) ;
% In case the input power is given
if nargin == 3
    [In_I, In_Q] = setMeanPower(In_I, In_Q, PowerInputdB) ;
end
% set the smal signal gain to 0
[Offset_in, ~, ~] = CheckPower(In);
[Offset_out, ~, ~] = CheckPower(Out);

Offset_out = Offset_in - Offset_out ;
Offset_out = 10^( Offset_out/20 ) ;
Out = Out * Offset_out ;

[In, Out] = AdjustPhase(In, Out) ;

end
