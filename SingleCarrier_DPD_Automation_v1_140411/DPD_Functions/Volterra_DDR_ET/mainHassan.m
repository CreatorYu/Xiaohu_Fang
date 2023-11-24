clc
close all


%% Hassan Volterra

        VolterraParameters.ModifiedKernels = false;
        VolterraParameters.ModifiedFile    = 'kernelsML.txt' ; 
        VolterraParameters.DDR             = true ;
        VolterraParameters.DDRorder        = 2 ;
      % VolterraParameters.Order           = [ h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 ] ;
        VolterraParameters.Order           = [ 7  0  5  0  3  0  0  0  0  0   0   ] ;
%         VolterraParameters.Order           = [ 0  0  0  0  0  0  0  0  0  0   0   ] ;        
        VolterraParameters.Static          = 9 ;

           
        In_I = load('WCDMA3G_101_In_I_100r0_PAPR_8r3_Version1200_1ms.txt');
        In_Q = load('WCDMA3G_101_In_Q_100r0_PAPR_8r3_Version1200_1ms.txt');
        Out_I = load('ET_WCDMA_101_no_DPD_I.txt');
        Out_Q = load('ET_WCDMA_101_no_DPD_Q.txt');


        
        %%%%%%%% PA modeling %%%%%%%%%%%%%%%%%           
%         
%         [ VolterraParameters , VolterraCoeff, VolterraOutput ] = VolterraDpdIdentification ( In_I , In_Q , Out_I , Out_Q , VolterraParameters , 20e3 ) ;       
        
        DPD = true ;
%         DPD = false ;
        [ VolterraParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification ( In_I , In_Q , Out_I , Out_Q , VolterraParameters , 20e3 , DPD ) ;       
               
        [ Pr_I , Pr_Q ] = VolterraDpdApply ( In_I , In_Q , VolterraParameters , VolterraCoeff ) ;       



%         dlmwrite('PreDist_I.txt', Pr_I)
%         dlmwrite('PreDist_Q.txt', Pr_Q)    
        
        
%         dlmwrite('C:\Users\h2sarbis\MyWorks\Matlab_Projects\Volterra series EmRg\Newer version\Toward_100MHz_Inst_BW\Wideband_PreDist_I.txt', Pr_I)
%         dlmwrite('C:\Users\h2sarbis\MyWorks\Matlab_Projects\Volterra series EmRg\Newer version\Toward_100MHz_Inst_BW\Wideband_PreDist_Q.txt', Pr_Q)    
       
%         dlmwrite('C:\Users\h2sarbis\MyWorks\Matlab_Projects\Volterra series EmRg\Newer version\MyPA_new_sim_ET\WCDMA3G_2C_PreDist_I_35M_Volterra.txt', Pr_I)
%         dlmwrite('C:\Users\h2sarbis\MyWorks\Matlab_Projects\Volterra series EmRg\Newer version\MyPA_new_sim_ET\WCDMA3G_2C_PreDist_Q_35M_Volterra.txt', Pr_Q)    
%         
%         dlmwrite('C:\Users\h2sarbis\MyWorks\Matlab_Projects\Volterra series EmRg\Newer version\MyPA_new_sim_ET\WCDMA3G_2C_PreDist_I.txt', Pr_I)
%         dlmwrite('C:\Users\h2sarbis\MyWorks\Matlab_Projects\Volterra series EmRg\Newer version\MyPA_new_sim_ET\WCDMA3G_2C_PreDist_Q.txt', Pr_Q)    
        
%         dlmwrite('C:\Users\h2sarbis\MyWorks\Matlab_Projects\Volterra series EmRg\Newer version\MyPA_new_sim_ET\WCDMA3G_2C_PreDist_I_ET_conv.txt', Pr_I)
%         dlmwrite('C:\Users\h2sarbis\MyWorks\Matlab_Projects\Volterra series EmRg\Newer version\MyPA_new_sim_ET\WCDMA3G_2C_PreDist_Q_ET_conv.txt', Pr_Q)    

        
        
        %%%%%%%% AM-AM %%%%%%%%%%%%%%%%%                   
        figure,
        plot(20*log10(abs(complex(In_I,In_Q))), 20*log10(abs(complex(Out_I,Out_Q)))-20*log10(abs(complex(In_I,In_Q))) , 'r+')

        %%%%%%%% AM-PM %%%%%%%%%%%%%%%%%                   
        figure,
        plot( 20*log10(abs(complex(In_I,In_Q))), 180/pi*phase(complex(Out_I,Out_Q)./complex(In_I,In_Q)) , 'r+')

%         %%%%%%%% PM-PM %%%%%%%%%%%%%%%%%                   
%         figure,
%         plot( phase(complex(In_I,In_Q)), phase(complex(Out_I,Out_Q)) - phase(complex(In_I,In_Q)) , 'r+')
%         
%         %%%%%%%% PM-AM %%%%%%%%%%%%%%%%%                   
%         figure,
%         plot( phase(complex(In_I,In_Q)), 20*log10(abs(complex(Out_I,Out_Q)))-20*log10(abs(complex(In_I,In_Q))) , 'r+')        
    
        