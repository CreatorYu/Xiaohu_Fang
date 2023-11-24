function [ VolterraParameters , VolterraCoeff , NMSE ] = VolterraDpdIdentification ( Pr_I , Pr_Q , Out_I , Out_Q , VolterraParameters , NbOfPoint , DPD)
    display( 'Import and plot data' ) ;
    tic    
    PS  = NbOfPoint ;
	CDTRFTB = 1e2 ;
    if DPD
        [ In_I , In_Q , Out_I , Out_Q ] = VolterraDpdIdentification_ImportData( Pr_I , Pr_Q , Out_I , Out_Q , PS , CDTRFTB ) ;
    else
        [ Out_I , Out_Q , In_I , In_Q ] = VolterraDpdIdentification_ImportData( Out_I , Out_Q , Pr_I , Pr_Q , PS , CDTRFTB ) ;
    end
	if DPD
        aux = In_I ;
        In_I = Out_I ;
        Out_I = aux ;
        aux = In_Q ;
        In_Q = Out_Q ;
        Out_Q = aux ;
	end
        data.In  = complex( In_I  , In_Q  ) ;
        data.Out = complex( Out_I , Out_Q ) ;

%         VolterraDpdIdentification_PlotFigures( In_I , In_Q , Out_I , Out_Q ) ;
	display( [ '  ------>  ' num2str(toc) 's' ] ) ;

 %% Volterra Series parameters and kernels generations
     display( 'Volterra kernels' ) ;
        VolterraParameters.ModifiedKernels = VolterraParameters.ModifiedKernels ;
        VolterraParameters.ModifiedFile    = VolterraParameters.ModifiedFile ;
        VolterraParameters.DDR             = VolterraParameters.DDR ;
        VolterraParameters.DDRorder        = VolterraParameters.DDRorder ;
      % VolterraParameters.Order           = [ h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 ] ;
        VolterraParameters.Order           = VolterraParameters.Order ;
        VolterraParameters.Static          = VolterraParameters.Static ;
       
    if not ( VolterraParameters.ModifiedKernels )
        [ kernel , NbCoeff ] = VolterraDpdIdentification_GenerateVolterraKernels( VolterraParameters ) ;
        VolterraParameters.Kernel   = kernel  ;
        VolterraParameters.NbCoeff  = NbCoeff ;
        if VolterraParameters.DDR
            [ kernel , NbCoeff ] = VolterraDpdIdentification_PruneVolterraKernels( VolterraParameters ) ;
            VolterraParameters.Kernel   = kernel ;
            VolterraParameters.NbCoeff  = NbCoeff ;
        end
    else
        [ kernel , NbCoeff  ] = VolterraDpdIdentification_ModifiedKernels( VolterraParameters ) ;
        VolterraParameters.Static   = VolterraParameters.Static ;
        VolterraParameters.Order    = [ 1 1 1 1 1 1 1 1 1 1 1 ] ;
        VolterraParameters.Kernel   = kernel  ;
        VolterraParameters.NbCoeff  = NbCoeff + VolterraParameters.Static ;
    end
    
%% Identify Volterra series coefficients
	display( 'Identify Volterra series coefficients' ) ;

    dataaux = data ;

	%     dataaux.In  = dataaux.In(  1 : 10000 ) ;
    %     dataaux.Out = dataaux.Out( 1 : 10000 ) ;    
    
    [ VolterraCoeff , StaticCoeff ] = VolterraDpdIdentification_IdentifyVolterraCoeff( dataaux , VolterraParameters ) ;
    
%% Apply Volterra
	display( 'Apply Volterra series coefficients' ) ;

    [ VolterraOutput , StaticOutput ] = VolterraDpdIdentification_ApplyVolterra( data , VolterraParameters , VolterraCoeff , StaticCoeff ) ;

%% Modeling Performance
	display( 'Modeling Performance' ) ;

    [ meanInput , maxInput , NMSE ] = VolterraDpdIdentification_PlotVMFigures( data.In , data.Out , VolterraOutput , VolterraCoeff , StaticOutput ) ;
	VolterraParameters.maxInput = maxInput ;
	VolterraParameters.meanInput = meanInput ;
    display(['mean of output signal = ' num2str(meanInput) ' dB']);
    display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    display(VolterraParameters.NbCoeff) ;