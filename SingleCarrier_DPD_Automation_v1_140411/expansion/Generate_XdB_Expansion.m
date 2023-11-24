function [ Pr_I , Pr_Q ] = Generate_XdB_Expansion ( In_I , In_Q , GainExpansion , InflectionPoint)

%     NoOfEntries = str2double(get(handles.Tag_Update_Generic_DPD_NoOfEntries,'String'));
%     NoOfBits = str2double(get(handles.Tag_Update_Generic_DPD_NoOfBits,'String'));

    NoOfEntries     = length ( In_I ) ;
    LinearGain      = sqrt ( 2 ) / 2 - InflectionPoint ^ 2 * GainExpansion ;
    GainExpansion   = 1 / sqrt( 2 ) * 10 ^ ( GainExpansion / 20 ) ;
    InflectionPoint = floor ( InflectionPoint * NoOfEntries ) ;
    
    
%     pathI = [pathnameIin filenameIin];
%     pathQ = [pathnameQin filenameQin];
%     I_in  = dlmread(pathI) ; Q_in  = dlmread(pathQ) ; 
%     I_in  = I_in(:,1).' ; Q_in  = Q_in(:,1).' ;
    
    
    norm = max ( sqrt ( In_I .^ 2 + In_Q .^ 2 ) ) ;
    In_I = In_I / norm ;    
    In_Q = In_Q / norm ;
    

    
    IQ_addr  = In_I .* In_I + In_Q .* In_Q ;
    LUT_addr = floor ( IQ_addr * ( NoOfEntries - 1 ) ) + 1 ;	
	
    %Generate Ic and Qc
    CoeffIc = zeros( NoOfEntries , 1 ) ;
    CoeffQc = zeros( NoOfEntries , 1 ) ;

    % 0 Gain
    CoeffIc ( 1 : InflectionPoint ) = LinearGain ;
    CoeffQc ( 1 : InflectionPoint ) = LinearGain ;
    
    % Gain Expansion
    x  = [ 1          InflectionPoint:(NoOfEntries-InflectionPoint)/2:NoOfEntries ] ;
    y  = [ LinearGain LinearGain (GainExpansion+LinearGain)/2 GainExpansion ] ;
    
    p = polyfit( x , y , 3 ) ;
    X = [ ] ;
    for  k = 0 : 3
        X = [ ( 1 : NoOfEntries ) .^ k ; X ] ;
    end  
    
	CoeffIc ( 1 : NoOfEntries ) = p * X ;
    CoeffQc ( 1 : NoOfEntries ) = p * X ;
    
    Ic = transpose ( CoeffIc( LUT_addr ) ).' ;
    Qc = transpose ( CoeffQc( LUT_addr ) ).' ;
          
%     size(In_I)
%     size(In_Q)
%     size(Ic)
%     size(Qc)
    Pr_I = ( In_I .* Ic ) - ( In_Q .* Qc ) ;
    Pr_Q = ( In_I .* Qc ) + ( In_Q .* Ic ) ;