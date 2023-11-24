function [ VolterraCoeff , StaticCoeff ] = VolterraDpdIdentification_IdentifyVolterraCoeff( data , VolterraParameters )
    Vin  = data.In  ;
    Vout = data.Out ;
    kernel = VolterraParameters.Kernel ;
    order  = VolterraParameters.Order  ;
    
%% Static gain expansion
	PolyOrder = VolterraParameters.Static ;
    
%% Used in solving using Newtons Method
    display( 'Create Static Matrix' ) ;
    U = VolterraDpdIdentification_GenerateMatrixMemoryless( Vin , 0 , PolyOrder ) ;
    display( [ '  ------>  ' num2str(toc) 's' ] ) ;
%% Dynamic components
%% 1st Kernal
    if order( 1 ) > 0
        display( 'Add 1st Kernal Matrix' ) ;
        A         = kernel{ 1 } ;
        [ L , auxaux ] = size( A )   ;
        for k = 1 : L
            i1 = A( k , 1 ) ;
            Lag          = circshift( Vin , i1 ) ; 
            Lag( 1 : i1 ) = 0                    ;
            U            = [ U , Lag ]           ;
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    end
%% 2nd Kernal
    if order( 2 ) > 0
        display( 'Add 2nd Kernal Matrix' ) ;    
        A         = kernel{ 2 } ;
        [ L , auxaux ] = size( A )   ;
        for k = 1 : L
            i1 = A( k , 1 ) ; Lag1 = circshift( Vin , i1 ) ; Lag1( 1 : i1 ) = 0 ;
            i2 = A( k , 2 ) ; Lag2 = circshift( Vin , i2 ) ; Lag2( 1 : i2 ) = 0 ;
            Kernel = abs(Lag1) .* (Lag2) ; 
            U = [ U , Kernel ] ;
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    end
%% 3rd Kernal
    if order( 3 ) > 0
        display( 'Add 3rd Kernal Matrix' ) ;
        A         = kernel{ 3 } ;
        [ L , auxaux ] = size( A )   ;
        for k = 1 : L
            i1 = A( k , 1 ) ; Lag1 = circshift( Vin , i1 ) ; Lag1( 1 : i1 ) = 0 ;
            i2 = A( k , 2 ) ; Lag2 = circshift( Vin , i2 ) ; Lag2( 1 : i2 ) = 0 ;
            i3 = A( k , 3 ) ; Lag3 = circshift( Vin , i3 ) ; Lag3( 1 : i3 ) = 0 ;
            Kernel = Lag1 .* Lag2 .* ( conj(Lag3) ) ; 
            U = [ U , Kernel ] ;
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    end    
%% 4th Kernal
    if order( 4 ) > 0
        display( 'Add 4th Kernal Matrix' ) ;
        A         = kernel{ 4 } ;
        [ L , auxaux ] = size( A )   ;
        for k = 1 : L
            i1 = A( k , 1 ) ; Lag1 = circshift( Vin , i1 ) ; Lag1( 1 : i1 ) = 0 ;
            i2 = A( k , 2 ) ; Lag2 = circshift( Vin , i2 ) ; Lag2( 1 : i2 ) = 0 ;
            i3 = A( k , 3 ) ; Lag3 = circshift( Vin , i3 ) ; Lag3( 1 : i3 ) = 0 ;
            i4 = A( k , 4 ) ; Lag4 = circshift( Vin , i4 ) ; Lag4( 1 : i4 ) = 0 ;
            Kernel = abs(Lag1) .* Lag2 .* (Lag3) .* conj(Lag4) ;
            U = [ U , Kernel ] ;
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    end
%% 5th Kernal
    if order( 5 ) > 0
        display( 'Add 5th Kernal Matrix' ) ;
        A         = kernel{ 5 } ;
        [ L , auxaux ] = size( A )   ;
        for k = 1 : L
            i1 = A( k , 1 ) ; Lag1 = circshift( Vin , i1 ) ; Lag1( 1 : i1 ) = 0 ;
            i2 = A( k , 2 ) ; Lag2 = circshift( Vin , i2 ) ; Lag2( 1 : i2 ) = 0 ;
            i3 = A( k , 3 ) ; Lag3 = circshift( Vin , i3 ) ; Lag3( 1 : i3 ) = 0 ;
            i4 = A( k , 4 ) ; Lag4 = circshift( Vin , i4 ) ; Lag4( 1 : i4 ) = 0 ;
            i5 = A( k , 5 ) ; Lag5 = circshift( Vin , i5 ) ; Lag5( 1 : i5 ) = 0 ;
            Kernel = Lag1 .* Lag2 .* Lag3 .* conj(Lag4) .* conj(Lag5) ;
            U = [ U , Kernel ] ;
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    end
%% 6th Kernal
    if order( 6 ) > 0
        display( 'Add 6th Kernal Matrix' ) ;        
        A         = kernel{ 6 } ;
        [ L , auxaux ] = size( A )   ;
        for k = 1 : L
            i1 = A( k , 1 ) ; Lag1 = circshift( Vin , i1 ) ; Lag1( 1 : i1 ) = 0 ;
            i2 = A( k , 2 ) ; Lag2 = circshift( Vin , i2 ) ; Lag2( 1 : i2 ) = 0 ;
            i3 = A( k , 3 ) ; Lag3 = circshift( Vin , i3 ) ; Lag3( 1 : i3 ) = 0 ;
            i4 = A( k , 4 ) ; Lag4 = circshift( Vin , i4 ) ; Lag4( 1 : i4 ) = 0 ;
            i5 = A( k , 5 ) ; Lag5 = circshift( Vin , i5 ) ; Lag5( 1 : i5 ) = 0 ;
            i6 = A( k , 6 ) ; Lag6 = circshift( Vin , i6 ) ; Lag6( 1 : i6 ) = 0 ;
            Kernel = abs(Lag1) .* Lag2 .* Lag3 .* (Lag4) .* conj(Lag5) .* conj(Lag6) ;
            U = [ U , Kernel ] ;                
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;        
    end
%% 7th Kernal
    if order( 7 ) > 0
        display( 'Add 7th Kernal Matrix' ) ;        
        A         = kernel{ 7 } ;
        [ L , auxaux ] = size( A )   ;
        for k = 1 : L
            i1 = A( k , 1 ) ; Lag1 = circshift( Vin , i1 ) ; Lag1( 1 : i1 ) = 0 ;
            i2 = A( k , 2 ) ; Lag2 = circshift( Vin , i2 ) ; Lag2( 1 : i2 ) = 0 ;
            i3 = A( k , 3 ) ; Lag3 = circshift( Vin , i3 ) ; Lag3( 1 : i3 ) = 0 ;
            i4 = A( k , 4 ) ; Lag4 = circshift( Vin , i4 ) ; Lag4( 1 : i4 ) = 0 ;
            i5 = A( k , 5 ) ; Lag5 = circshift( Vin , i5 ) ; Lag5( 1 : i5 ) = 0 ;
            i6 = A( k , 6 ) ; Lag6 = circshift( Vin , i6 ) ; Lag6( 1 : i6 ) = 0 ;
            i7 = A( k , 7 ) ; Lag7 = circshift( Vin , i7 ) ; Lag7( 1 : i7 ) = 0 ;
            Kernel = Lag1 .* Lag2 .* Lag3 .* Lag4 .* conj(Lag5) .* conj(Lag6) .* conj(Lag7) ;
            U = [ U , Kernel ] ;                
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;        
    end
%% 8th Kernal
    if order( 8 ) > 0
        display( 'Add 8th Kernal Matrix' ) ;
        A         = kernel{ 8 } ;
        [ L , auxaux ] = size( A )   ;
        for k = 1 : L
            i1 = A( k , 1 ) ; Lag1 = circshift( Vin , i1 ) ; Lag1( 1 : i1 ) = 0 ;
            i2 = A( k , 2 ) ; Lag2 = circshift( Vin , i2 ) ; Lag2( 1 : i2 ) = 0 ;
            i3 = A( k , 3 ) ; Lag3 = circshift( Vin , i3 ) ; Lag3( 1 : i3 ) = 0 ;
            i4 = A( k , 4 ) ; Lag4 = circshift( Vin , i4 ) ; Lag4( 1 : i4 ) = 0 ;
            i5 = A( k , 5 ) ; Lag5 = circshift( Vin , i5 ) ; Lag5( 1 : i5 ) = 0 ;
            i6 = A( k , 6 ) ; Lag6 = circshift( Vin , i6 ) ; Lag6( 1 : i6 ) = 0 ;
            i7 = A( k , 7 ) ; Lag7 = circshift( Vin , i7 ) ; Lag7( 1 : i7 ) = 0 ;
            i8 = A( k , 8 ) ; Lag8 = circshift( Vin , i8 ) ; Lag8( 1 : i8 ) = 0 ;
            Kernel = abs(Lag1) .* Lag2 .* Lag3 .* Lag4 .* (Lag5) .* conj(Lag6) .* conj(Lag7) .* conj(Lag8) ;
            U = [U,Kernel];                
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    end
%% 9th Kernal
    if order( 9 ) > 0
        display( 'Add 9th Kernal Matrix' ) ;
        A         = kernel{ 9 } ;
        [ L , auxaux ] = size( A )   ;
        for k = 1 : L
            i1 = A( k , 1 ) ; Lag1 = circshift( Vin , i1 ) ; Lag1( 1 : i1 ) = 0 ;
            i2 = A( k , 2 ) ; Lag2 = circshift( Vin , i2 ) ; Lag2( 1 : i2 ) = 0 ;
            i3 = A( k , 3 ) ; Lag3 = circshift( Vin , i3 ) ; Lag3( 1 : i3 ) = 0 ;
            i4 = A( k , 4 ) ; Lag4 = circshift( Vin , i4 ) ; Lag4( 1 : i4 ) = 0 ;
            i5 = A( k , 5 ) ; Lag5 = circshift( Vin , i5 ) ; Lag5( 1 : i5 ) = 0 ;
            i6 = A( k , 6 ) ; Lag6 = circshift( Vin , i6 ) ; Lag6( 1 : i6 ) = 0 ;
            i7 = A( k , 7 ) ; Lag7 = circshift( Vin , i7 ) ; Lag7( 1 : i7 ) = 0 ;
            i8 = A( k , 8 ) ; Lag8 = circshift( Vin , i8 ) ; Lag8( 1 : i8 ) = 0 ;
            i9 = A( k , 9 ) ; Lag9 = circshift( Vin , i9 ) ; Lag9( 1 : i9 ) = 0 ;
            Kernel = Lag1 .* Lag2 .* Lag3 .* Lag4 .* Lag5 .* conj(Lag6) .* conj(Lag7) .* conj(Lag8) .* conj(Lag9) ;
            U = [U,Kernel];                
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    end
%% 10th Kernal
    if order(10) > 0
        display( 'Add 10th Kernal Matrix' ) ;
        A         = kernel{10} ;
        [ L , auxaux ] = size( A )  ;
        for k = 1 : L
            i1  = A( k , 1  ) ; Lag1  = circshift( Vin , i1  ) ;  Lag1( 1 : i1  ) = 0 ;
            i2  = A( k , 2  ) ; Lag2  = circshift( Vin , i2  ) ;  Lag2( 1 : i2  ) = 0 ;
            i3  = A( k , 3  ) ; Lag3  = circshift( Vin , i3  ) ;  Lag3( 1 : i3  ) = 0 ;
            i4  = A( k , 4  ) ; Lag4  = circshift( Vin , i4  ) ;  Lag4( 1 : i4  ) = 0 ;
            i5  = A( k , 5  ) ; Lag5  = circshift( Vin , i5  ) ;  Lag5( 1 : i5  ) = 0 ;
            i6  = A( k , 6  ) ; Lag6  = circshift( Vin , i6  ) ;  Lag6( 1 : i6  ) = 0 ;
            i7  = A( k , 7  ) ; Lag7  = circshift( Vin , i7  ) ;  Lag7( 1 : i7  ) = 0 ;
            i8  = A( k , 8  ) ; Lag8  = circshift( Vin , i8  ) ;  Lag8( 1 : i8  ) = 0 ;
            i9  = A( k , 9  ) ; Lag9  = circshift( Vin , i9  ) ;  Lag9( 1 : i9  ) = 0 ;
            i10 = A( k , 10 ) ; Lag10 = circshift( Vin , i10 ) ; Lag10( 1 : i10 ) = 0 ;
            Kernel = Lag1 .* Lag2 .* Lag3 .* Lag4 .* Lag5 .* conj(Lag6) .* conj(Lag7) .* conj(Lag8) .* conj(Lag9) .* conj(Lag10) ; %%
            U = [U,Kernel];                
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    end
%% 11th Kernal
    if order(11) > 0
        display( 'Add 11th Kernal Matrix' ) ;
        A         = kernel{11} ;
        [ L , auxaux ] = size( A )  ;
        for k = 1 : L
            i1  = A( k , 1  ) ; Lag1  = circshift( Vin , i1  ) ;  Lag1( 1 : i1  ) = 0 ;
            i2  = A( k , 2  ) ; Lag2  = circshift( Vin , i2  ) ;  Lag2( 1 : i2  ) = 0 ;
            i3  = A( k , 3  ) ; Lag3  = circshift( Vin , i3  ) ;  Lag3( 1 : i3  ) = 0 ;
            i4  = A( k , 4  ) ; Lag4  = circshift( Vin , i4  ) ;  Lag4( 1 : i4  ) = 0 ;
            i5  = A( k , 5  ) ; Lag5  = circshift( Vin , i5  ) ;  Lag5( 1 : i5  ) = 0 ;
            i6  = A( k , 6  ) ; Lag6  = circshift( Vin , i6  ) ;  Lag6( 1 : i6  ) = 0 ;
            i7  = A( k , 7  ) ; Lag7  = circshift( Vin , i7  ) ;  Lag7( 1 : i7  ) = 0 ;
            i8  = A( k , 8  ) ; Lag8  = circshift( Vin , i8  ) ;  Lag8( 1 : i8  ) = 0 ;
            i9  = A( k , 9  ) ; Lag9  = circshift( Vin , i9  ) ;  Lag9( 1 : i9  ) = 0 ;
            i10 = A( k , 10 ) ; Lag10 = circshift( Vin , i10 ) ; Lag10( 1 : i10 ) = 0 ;
            i11 = A( k , 11 ) ; Lag11 = circshift( Vin , i11 ) ; Lag11( 1 : i11 ) = 0 ;
            Kernel = Lag1 .* Lag2 .* Lag3 .* Lag4 .* Lag5 .* Lag6 .* conj(Lag7) .* conj(Lag8) .* conj(Lag9) .* conj(Lag10) .* conj(Lag11) ; %%
            U = [U,Kernel];                
        end
        display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    end
    display(['Conditioning number ' num2str(cond(U))]);
   
%% Compute the Volterra Coefficients
    display( 'Identify Volterra coefficients' ) ;
    U             = double( U )         ;    
    [ Q , R ]     = qr( U , 0 )         ;
    VolterraCoeff =  R  \ ( Q' * Vout ) ;
% 	VolterraCoeff =  pinv(U) * Vout ;
    display( [ '  ------>  ' num2str(toc) 's' ] ) ;
        
%% Compute the Static Model Coefficients        
	%Compute the static & dynamic aspects of the measured data,
    display( 'Identify static coeffifients' ) ;
    U = VolterraDpdIdentification_GenerateMatrixMemoryless( Vin , 0 , PolyOrder ) ;
    U           = double( U )      ;
    [ Q , R ]   = qr( U , 0 )      ;
    StaticCoeff = R \ (Q' * Vout ) ; 
	display( [ '  ------>  ' num2str(toc) 's' ] ) ;