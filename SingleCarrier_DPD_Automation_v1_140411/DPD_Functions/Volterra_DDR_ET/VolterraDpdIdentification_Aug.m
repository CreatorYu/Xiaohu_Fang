function [ VolterraParameters , VolterraCoeff, VolterraOutput , StaticOutput , NMSE ] = VolterraDpdIdentification_Aug ( Pr_I , Pr_Q , Out_I , Out_Q , VolterraParameters , NbOfPoint , DPD)

%         VolterraParameters.ModifiedKernels = false ;
%         VolterraParameters.ModifiedFile    = '.\kernels2consider\withDelayedInput\5_5_EOConj.txt' ; 
%         VolterraParameters.DDR             = true ;
%         VolterraParameters.DDRorder        = 2 ;
%       % VolterraParameters.Order           = [ h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 ] ;
%         VolterraParameters.Order           = [ 5  0  3  0  3  0  0  0  0  0   0   ] ;
%         VolterraParameters.Static          = 7 ;
    display( 'Import and plot data' ) ;
    tic    
%     DPD = false ;
    PS  = NbOfPoint ;
	CDTRFTB = 1+0*1e2 ;
	[ In_I , In_Q , Out_I , Out_Q ] = VolterraDpdIdentification_ImportData( Pr_I , Pr_Q , Out_I , Out_Q , PS , CDTRFTB ) ;
    
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
        data.Vdd =  abs(data.Out);        
        VolterraDpdIdentification_PlotFigures( In_I , In_Q , Out_I , Out_Q ) ;
% adsfasfds
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
        VolterraParameters.NbCoeff  = NbCoeff*VolterraParameters.NSupply;
        if VolterraParameters.DDR
            [ kernel , NbCoeff ] = VolterraDpdIdentification_PruneVolterraKernels( VolterraParameters ) ;
            VolterraParameters.Kernel   = kernel ;
            VolterraParameters.NbCoeff  = NbCoeff*VolterraParameters.NSupply;
        end
    else
        [ kernel , NbCoeff  ] = VolterraDpdIdentification_ModifiedKernels( VolterraParameters ) ;
        VolterraParameters.Static   = VolterraParameters.Static ;
        VolterraParameters.Order    = [ 1 1 1 1 1 1 1 1 1 1 1 ] ;
        VolterraParameters.Kernel   = kernel  ;
        VolterraParameters.NbCoeff  = (NbCoeff + VolterraParameters.Static)*VolterraParameters.NSupply ;
    end
    
%% Identify Volterra series coefficients
	display( 'Identify Volterra series coefficients' ) ;

    dataaux = data ;

	%     dataaux.In  = dataaux.In(  1 : 10000 ) ;
    %     dataaux.Out = dataaux.Out( 1 : 10000 ) ;    
    
    [ VolterraCoeff , StaticCoeff ] = VolterraDpdIdentification_IdentifyVolterraCoeff_ET ( dataaux , VolterraParameters ) ;    
    
%% Apply Volterra
	display( 'Apply Volterra series coefficients' ) ;

    [ VolterraOutput , StaticOutput ] = VolterraDpdIdentification_ApplyVolterra_ET( data , VolterraParameters , VolterraCoeff , StaticCoeff ) ;
    
%% Modeling Performance
	display( 'Modeling Performance' ) ;

    [ meanInput , maxInput, NMSE ] = VolterraDpdIdentification_PlotVMFigures( data.In , data.Out , VolterraOutput , VolterraCoeff , StaticOutput ) ;
    VolterraParameters.maxInput = maxInput ;
	VolterraParameters.meanInput = meanInput ;
    display(['mean of output signal = ' num2str(meanInput) ' dB']);
    display( [ '  ------>  ' num2str(toc) 's' ] ) ;
    display(VolterraParameters.NbCoeff) ;
    
%     VolterraParameters.NbCoeff