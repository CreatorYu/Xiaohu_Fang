 function [ In_I , In_Q , Out_I , Out_Q, Vdd_import] = VolterraDpdIdentification_ImportData_ET( InputI , InputQ , OutputI , OutputQ , Vdd, PS , CDTRFTB)

    % align the length
        I_in = InputI ; I_out = OutputI ; Q_in = InputQ ; Q_out = OutputQ ;
        L = [ length(I_in) length(I_out) length(Q_in) length(Q_out) ] ;
            L = min( L ) ;
            I_in  =  I_in( CDTRFTB : L ) ;
            Q_in  =  Q_in( CDTRFTB : L ) ;
            I_out = I_out( CDTRFTB : L ) ;
            Q_out = Q_out( CDTRFTB : L ) ;
            
            In_I = I_in;
            In_Q = Q_in;
            Out_I = I_out;
            Out_Q = Q_out;

%     % peak power = 0 dBm
%         Y = complex(I_out,Q_out);
%         ampY = abs( Y ) ;
%         MaxPowerY = max( ampY .^ 2 ) ;
%         MaxPowerdBX = 10 * log10( MaxPowerY / 100 ) + 30 ;
%         Offset_Out =  10 ^ ( - MaxPowerdBX / 20 ) ;
%             I_out = I_out * Offset_Out ; 
%             Q_out = Q_out * Offset_Out ;
%             
%             
% 	% set SSG = 0 dB
%         PowerAvgin  = mean(abs(complex(I_in ,Q_in )).^2) ;
%             PowerAvgdBin  = 10 * log10( PowerAvgin / 100 ) + 30 ;
%         PowerAvgout = mean(abs(complex(I_out,Q_out)).^2) ;
%             PowerAvgdBout = 10 * log10( PowerAvgout / 100 ) + 30 ;
%         Offset_In = PowerAvgdBout - PowerAvgdBin ;
%             Offset_In = 10 ^ ( Offset_In / 20 ) ;
%         In_I  = I_in * Offset_In ;
%         In_Q  = Q_in * Offset_In ;
%         Out_I = I_out ; 
%         Out_Q = Q_out ;
    
	% set the avg phase distortion to 0 degree
        PhaseOut = angle(complex(Out_I,Out_Q));
        PhaseIn  = angle(complex(In_I ,In_Q ));
        PhaseDistortion = (PhaseOut - PhaseIn);        
            Ind = PhaseDistortion >   pi ;
                PhaseDistortion = PhaseDistortion - 2 * Ind * pi ;
            Ind = PhaseDistortion < - pi ;
                PhaseDistortion = PhaseDistortion + 2 * Ind * pi ;
            avgPhaseDistortion = mean(PhaseDistortion);
        output = complex(Out_I,Out_Q);
        output = output * exp(-1i*avgPhaseDistortion);
            Out_I = real(output);
            Out_Q = imag(output);
        
    ampY = abs(complex(Out_I,Out_Q));
    L = length(ampY) ;
	PS0 = find( ampY==max(ampY) );

    if PS0-PS/2 < 1
        PS    = min(PS,L ) ;
        Range = 1 : PS ;
	elseif PS0+PS/2 > L
        PS    = max(1,L-PS) ;
        Range = PS : L ;
    else
        PS    = round(PS/2) ;
        Range = PS0-PS : PS0+PS ;
    end
    In_I  =  In_I( Range ) ;
    In_Q  =  In_Q( Range ) ;
    Out_I = Out_I( Range ) ;
    Out_Q = Out_Q( Range ) ;
    
    Vdd_import  =  Vdd( Range ) ;
