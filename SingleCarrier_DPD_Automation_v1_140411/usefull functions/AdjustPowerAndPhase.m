%% This fucntion is used to adjust the SSG and the phase of two signals to 0
function [In_I, In_Q, Out_I, Out_Q] = AdjustPowerAndPhase(In_I, In_Q, Out_I, Out_Q, PowerInputdB)
    [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q) ;
    % In case the input power is given
    switch nargin
        case 5
            [In_I, In_Q] = setMeanPower(In_I, In_Q, PowerInputdB) ;
    end
    % set the smal signal gain to 0
        [Offset_in, NotUsed, NotUsed] = checkPower(In_I, In_Q);
        [Offset_out, NotUsed, NotUsed] = checkPower(Out_I, Out_Q);

        Offset_out = Offset_in - Offset_out ;
            Offset_out = 10^( Offset_out/20 ) ;
        Out_I = Out_I * Offset_out ;
        Out_Q = Out_Q * Offset_out ;
        
    [In_I, In_Q, Out_I, Out_Q] = AdjustPhase(In_I, In_Q, Out_I, Out_Q) ;    