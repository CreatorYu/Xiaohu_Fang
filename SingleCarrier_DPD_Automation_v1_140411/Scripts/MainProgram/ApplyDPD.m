    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Apply DPD
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch DPD_type
        case 'Volterra_DDR'
            [Pr_I, Pr_Q] = VolterraDpdApply_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), VolterraETParameters, VolterraCoeff) ;
        case 'Volterra_DDR_ET'
            [Pr_I, Pr_Q] = VolterraDpdApply_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, Vdd_beforeDPD, VolterraETParameters, VolterraCoeff) ;
        case 'RF_Volterra'
            [Pr_I, Pr_Q] = Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), Coeff_RF_Volterra, RF_Volterra_Parameters, Fs);
        case 'MP'
            [Pr_I, Pr_Q] = Apply_SingleBand_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients);
        case 'APD'
            [Pr_I, Pr_Q] = Apply_SingleBand_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, APD_modelParam, APD_coefficients);
        case 'FIR_APD'
            [Pr_I, Pr_Q] = Apply_SingleBand_FIR_APD(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, FIR_APD_modelParam, FIR_APD_coefficients);
        case 'Aug_MP'
            [Pr_I, Pr_Q] = Apply_SingleBand_Aug_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients, gamma);
        case 'RFMP_ADRF'
            [Pr_I, Pr_Q] = Apply_SingleBand_RFMP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, RFMP_modelParam, num_coeff, den_coeff, real_zeros, imag_zeros, comp_zeros);
        case 'RFMP_DRF_MFOD'
            [Pr_I, Pr_Q] = Apply_SingleBand_RFMP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, RFMP_modelParam, num_coeff, den_coeff, real_zeros, imag_zeros, comp_zeros);
        case 'RF_Volterra_ET'
            [Pr_I, Pr_Q] = Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, DelayAdjusted_Vdd_beforeDPD, Coeff_RF_Volterra, RF_Volterra_Parameters, Fs);
    end