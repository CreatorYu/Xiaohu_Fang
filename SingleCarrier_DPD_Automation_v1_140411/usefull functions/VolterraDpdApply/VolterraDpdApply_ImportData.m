 function [ In_I , In_Q ] = VolterraDpdApply_ImportData( InputI , InputQ , maxInput )
%% import files
        I_in  = InputI ;
        Q_in  = InputQ ;
        
        L = [ length( I_in ) length( Q_in ) ];
        L = min( L ) ;
            
        I_in  =  I_in( 1:L ) ;
        Q_in  =  Q_in( 1:L ) ;
        
%         X = complex( I_in , Q_in ) ;
%         meanPowerX = max(abs( X ).^2) ;
%         meanPowerX = 10 * log10( meanPowerX / 100 ) + 30  ;
%         Offset_In =  10 ^ ( (maxInput- meanPowerX) / 20 ) ;
%         I_in = I_in * Offset_In ;
%         Q_in = Q_in * Offset_In ;
        
        In_I  = I_in ;
        In_Q  = Q_in ;