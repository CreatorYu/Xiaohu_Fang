 function [ In_I , In_Q , Out_I , Out_Q ] = VolterraDpdIdentification_ImportData( InputI , InputQ , OutputI , OutputQ , PS , CDTRFTB)

    % align the length
        I_in = InputI ; I_out = OutputI ; Q_in = InputQ ; Q_out = OutputQ ;
        L = [ length(I_in) length(I_out) length(Q_in) length(Q_out) ] ;
            L = min( L ) ;
            I_in  =  I_in( CDTRFTB : L ) ;
            Q_in  =  Q_in( CDTRFTB : L ) ;
            I_out = I_out( CDTRFTB : L ) ;
            Q_out = Q_out( CDTRFTB : L ) ;

        In_I  = I_in ;
        In_Q  = Q_in ;
        Out_I = I_out ; 
        Out_Q = Q_out ;
    
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
    Range = 1 : L ;
    In_I  =  In_I( Range ) ;
    In_Q  =  In_Q( Range ) ;
    Out_I = Out_I( Range ) ;
    Out_Q = Out_Q( Range ) ;