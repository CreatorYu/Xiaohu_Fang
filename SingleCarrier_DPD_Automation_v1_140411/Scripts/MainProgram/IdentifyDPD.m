    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% DPD Identification and Validation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch DPD_type
        case 'Volterra_DDR'
            clear iqdata iqtotaldata
            DPD = true ;
            %         [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , VolterraParameters , NofDPDPoints , DPD ) ;
            VolterraParameters.NSupply = 1 ;
            DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
            [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput, NMSE_error ] = VolterraDpdIdentification_ET ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , circshift(DelayAdjusted_Vdd,0), VolterraParameters , NofDPDPoints , DPD ) ;
            Coeff_DR_real = 20*log10( (max(abs(real(VolterraCoeff))))/(min(abs(real(VolterraCoeff)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(VolterraCoeff))))/(min(abs(imag(VolterraCoeff)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
            num_of_coeff = size(VolterraCoeff,1);
        case 'Volterra_DDR_ET'
            Vdd_shift = 0;
            DPD = true ;
            [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification_ET ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , circshift(DelayAdjusted_Vdd,Vdd_shift), VolterraParameters , NofDPDPoints , DPD ) ;
        case 'Volterra_DDR_Aug'
            DPD = true ;
            [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification_Aug ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , VolterraParameters , NofDPDPoints , DPD ) ;
        case 'RF_Volterra'
            DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
            [Coeff_RF_Volterra, NMSE_error]=Identify_RF_Volterra_v2_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q ,DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
        case 'MP'
            [MP_coefficients, NMSE_error, Cond_A] = Identify_SingleBand_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'APD'
            [APD_coefficients, NMSE_error] = Identify_SingleBand_APD(APD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(APD_coefficients))))/(min(abs(real(APD_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(APD_coefficients))))/(min(abs(imag(APD_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'FIR_APD'
            [FIR_APD_coefficients, NMSE_error] = Identify_SingleBand_FIR_APD(FIR_APD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(FIR_APD_coefficients))))/(min(abs(real(FIR_APD_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(FIR_APD_coefficients))))/(min(abs(imag(FIR_APD_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
            if FIR_APD_modelParam.use_NL == 1
                NonlinearID_In_I = DelayAdjusted_In_I;
                NonlinearID_In_Q = DelayAdjusted_In_Q;
                NonlinearID_Out_I = DelayAdjusted_Out_I;
                NonlinearID_Out_Q = DelayAdjusted_Out_Q;
                %                 [NL_FIR_DPD_coefficients, NL_NMSE_error] = Identify_SingleBand_Cascaded_NLTB(FIR_DPD_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints, FIR_DPD_coefficients);
            end
        case 'TwoStep_MP'
            [MP_coefficients, NMSE_error, Cond_A] = Identify_TwoStep_SingleBand_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'Aug_MP'
            [MP_coefficients, gamma, fval, exitflag, NMSE_error, Cond_A] = Identify_SingleBand_Aug_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
            Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
            Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);
        case 'RFMP_ADRF'
            if RFMP_modelParam.useNL == 0
                [num_coeff, den_coeff, NMSE_error, Cond_A, real_zeros, imag_zeros, comp_zeros] = Identify_SingleBand_RFMP(RFMP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            elseif RFMP_modelParam.useNL == 1
                params.MaxFunEval = 40000;
                params.MaxIter = 40000;
                params.TolFun = 1e-6;
                [num_coeff, den_coeff, NMSE_error, real_zeros, imag_zeros, comp_zeros] = Identify_SingleBand_RFMP_NL(RFMP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints, params);            
            end
            Coeff_DR_num_real = 20*log10( (max(abs(real(num_coeff))))/(min(abs(real(num_coeff)))));
            Coeff_DR_num_imag = 20*log10( (max(abs(imag(num_coeff))))/(min(abs(imag(num_coeff)))));
            Coeff_DR_num = max(Coeff_DR_num_real,Coeff_DR_num_imag);
            Coeff_DR_den_real = 20*log10( (max(abs(real(den_coeff))))/(min(abs(real(den_coeff)))));
            Coeff_DR_den_imag = 20*log10( (max(abs(imag(den_coeff))))/(min(abs(imag(den_coeff)))));
            Coeff_DR_den = max(Coeff_DR_den_real,Coeff_DR_den_imag);
            Coeff_DR = max(Coeff_DR_den, Coeff_DR_num);
        case 'RFMP_DRF_MFOD'
            if RFMP_modelParam.useNL == 0
                [num_coeff, den_coeff, NMSE_error, Cond_A, real_zeros, imag_zeros, comp_zeros] = Identify_SingleBand_RFMP(RFMP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);
            elseif RFMP_modelParam.useNL == 1
                params.MaxFunEval = 40000;
                params.MaxIter = 40000;
                params.TolFun = 1e-6;
                [num_coeff, den_coeff, NMSE_error, real_zeros, imag_zeros, comp_zeros] = Identify_SingleBand_RFMP_NL(RFMP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints, params);            
            end
            Coeff_DR_num_real = 20*log10( (max(abs(real(num_coeff))))/(min(abs(real(num_coeff)))));
            Coeff_DR_num_imag = 20*log10( (max(abs(imag(num_coeff))))/(min(abs(imag(num_coeff)))));
            Coeff_DR_num = max(Coeff_DR_num_real,Coeff_DR_num_imag);
            Coeff_DR_den_real = 20*log10( (max(abs(real(den_coeff))))/(min(abs(real(den_coeff)))));
            Coeff_DR_den_imag = 20*log10( (max(abs(imag(den_coeff))))/(min(abs(imag(den_coeff)))));
            Coeff_DR_den = max(Coeff_DR_den_real,Coeff_DR_den_imag);
            Coeff_DR = max(Coeff_DR_den, Coeff_DR_num);
        case 'RF_Volterra_ET'
            DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
            [Coeff_RF_Volterra]=Identify_RF_Volterra_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
            %         [Coeff_RF_Volterra]=Identify_RF_Volterra_v2_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );
    end