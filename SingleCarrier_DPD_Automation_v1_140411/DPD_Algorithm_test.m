clc 
clear all
close all

%% Set DPD Parameters
% DPD_type = 'Volterra_DDR_ET';
% DPD_type = 'Volterra_DDR';
% DPD_type = 'RF_Volterra';
% DPD_type = 'RF_Volterra_ET';
DPD_type = 'MP';
% DPD_type = 'Aug_MP';
% DPD_type = 'RF_MP';

if ( strcmp(DPD_type,'Volterra_DDR_ET') || strcmp(DPD_type,'Volterra_DDR') )
    %%%%% Volterra DDR ET parameters
    VolterraParameters.ModifiedKernels = false;
    VolterraParameters.ModifiedFile    = 'kernelsML.txt' ; 
    VolterraParameters.DDR             = true ;
    VolterraParameters.DDRorder        = 2 ;
%   VolterraETParameters.Order         = [ h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 ] ;
    VolterraParameters.Order           = [ 7  0  5  0  3  0  0  0  0  0   0   ] ;
    VolterraParameters.Static          = 9 ;
    if strcmp(DPD_type,'Volterra_DDR')
        VolterraParameters.NSupply = 1 ;
    elseif strcmp(DPD_type,'Volterra_DDR_ET')
        VolterraParameters.NSupply = 1 ;
    end               
end

if ( strcmp(DPD_type,'RF_Volterra') || strcmp(DPD_type,'RF_Volterra_ET') )
    RF_Volterra_Parameters.memory_lag=1; 
    RF_Volterra_Parameters.embedding_dimension=3 ;
    RF_Volterra_Parameters.M1=7;
    RF_Volterra_Parameters.M3=5;
    RF_Volterra_Parameters.M5=3;
    RF_Volterra_Parameters.NL=7 ;     
    RF_Volterra_Parameters.carrier_frequency=2*pi*Fcarrier;
    RF_Volterra_Parameters.NSupply=1 ;
end

if  ( strcmp(DPD_type,'MP') || strcmp(DPD_type,'Aug_MP') )
    MP_modelParam.N = 5;
    MP_modelParam.M = 3;
    MP_modelParam.type = 'odd'; %type = 'odd' or 'odd_even'
    sens_test = 'off'; %'on'
end

if strcmp(DPD_type,'RF_MP')
    RFMP_Param.m_num = 3;
    RFMP_Param.m_den = 0;
    RFMP_Param.n_num = 9;
    RFMP_Param.n_den = 0;
    RFMP_Param.mod_num = 0;  % 0 = odd_even; 1 = even_only; 2 = odd_only
    RFMP_Param.mod_den = 0;  % 0 = odd_even; 1 = even_only; 2 = odd_only
    Param_array = [RFMP_Param.m_num, RFMP_Param.m_den, RFMP_Param.n_num ...
        RFMP_Param.n_den, RFMP_Param.mod_num, RFMP_Param.mod_den];
end

%% Reading input files  

NofDPDPoints = 0.9e4;

input_path = 'C:\Documents\Hassan\SingleCarrier_DPD_Automation_v1_140411\Measurements\Measurement25-Apr-2014_10_21_8\';
% Measurement25-Apr-2014_15_51_1\';

In_I = load([input_path 'I_Input_NoDPD_1.txt']);
In_Q = load([input_path 'Q_Input_NoDPD_1.txt']);
Out_I = load([input_path 'I_Output_WithoutDPD.txt']);
Out_Q = load([input_path 'Q_Output_WithoutDPD.txt']);

data_length = size(Out_Q,1);

checkPower_CCDF(In_I, In_Q,1);
checkPower_CCDF(Out_I, Out_Q,1);
[In_I, In_Q, Out_I, Out_Q] = AdjustPowerAndPhase(In_I, In_Q, Out_I, Out_Q, 0) ;
[In_I, In_Q, out_I1, out_Q1] = UnifyLength(In_I, In_Q, Out_I, Out_Q, data_length - 200) ;

[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, timedelay1] = AdjustDelay(In_I, In_Q, out_I1, out_Q1,250e6,2000) ;
    
[DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q] = AdjustPowerAndPhase(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, 0) ;
PlotGain(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotAMPM(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
PlotSpectrum(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q) ;
    
[EVM_dB EVM_perc] = EVM_calculate (DelayAdjusted_In_I,DelayAdjusted_In_Q,DelayAdjusted_Out_I,DelayAdjusted_Out_Q);

BW = 20e6;
fG = 200e3;
Fs = 100e6;
[freq, spectrum] = Calculated_Spectrum(DelayAdjusted_Out_I,DelayAdjusted_Out_Q,Fs);    
[ACLR_L, ACLR_U] = Calculate_ACLR (freq, spectrum, 0, BW, fG);    
[ACPR_L, ACPR_U] = Calculate_ACPR (freq, spectrum, 0, BW, fG);

display([ 'EVM          = ' num2str(EVM_perc)      ' % ' ]);
display([ 'ACLR (L/U)   = ' num2str(ACLR_L) ' / '  num2str(ACLR_U) ' dB ' ]);    
display([ 'ACPR (L/U)   = ' num2str(ACPR_L) ' / '  num2str(ACPR_U) ' dB ' ]);    
    
%%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% DPD Identification and Validation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(DPD_type,'Volterra_DDR')        
    DPD = true ;
%         [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , VolterraParameters , NofDPDPoints , DPD ) ;                      
    VolterraParameters.NSupply = 1 ;
    DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
    [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput, NMSE_error ] = VolterraDpdIdentification_ET ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , circshift(DelayAdjusted_Vdd,0), VolterraParameters , NofDPDPoints , DPD ) ;

    Coeff_DR_real = 20*log10( (max(abs(real(VolterraCoeff))))/(min(abs(real(VolterraCoeff)))));
    Coeff_DR_imag = 20*log10( (max(abs(imag(VolterraCoeff))))/(min(abs(imag(VolterraCoeff)))));
    Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);

elseif strcmp(DPD_type,'Volterra_DDR_ET')        
    Vdd_shift = 0;
    DPD = true ;
    [ VolterraETParameters , VolterraCoeff, VolterraOutput, StaticOutput ] = VolterraDpdIdentification_ET ( DelayAdjusted_In_I , DelayAdjusted_In_Q , DelayAdjusted_Out_I , DelayAdjusted_Out_Q , circshift(DelayAdjusted_Vdd,Vdd_shift), VolterraParameters , NofDPDPoints , DPD ) ;       

elseif strcmp(DPD_type,'RF_Volterra')
%         [Coeff_RF_Volterra, NMSE_error]=Identify_RF_Volterra(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , RF_Volterra_Parameters , Fs, NofDPDPoints );
    DelayAdjusted_Vdd = abs(complex(DelayAdjusted_In_I, DelayAdjusted_In_Q));
    [Coeff_RF_Volterra, NMSE_error]=Identify_RF_Volterra_v2_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );

elseif strcmp(DPD_type,'MP')
    [MP_coefficients, NMSE_error, Cond_A] = Identify_SingleBand_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);

    Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
    Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
    Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);

elseif strcmp(DPD_type,'Aug_MP')
    [MP_coefficients, gamma, fval, exitflag, NMSE_error, Cond_A] = Identify_SingleBand_Aug_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);

    Coeff_DR_real = 20*log10( (max(abs(real(MP_coefficients))))/(min(abs(real(MP_coefficients)))));
    Coeff_DR_imag = 20*log10( (max(abs(imag(MP_coefficients))))/(min(abs(imag(MP_coefficients)))));
    Coeff_DR = max(Coeff_DR_real,Coeff_DR_imag);

elseif strcmp(DPD_type,'RF_MP')
    [num_coeff, den_coeff, NMSE_error, Cond_A] = Identify_SingleBand_RFMP(Param_array, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);

    Coeff_DR_num_real = 20*log10( (max(abs(real(num_coeff))))/(min(abs(real(num_coeff)))));
    Coeff_DR_num_imag = 20*log10( (max(abs(imag(num_coeff))))/(min(abs(imag(num_coeff)))));
    Coeff_DR_num = max(Coeff_DR_num_real,Coeff_DR_num_imag);        
    Coeff_DR_den_real = 20*log10( (max(abs(real(den_coeff))))/(min(abs(real(den_coeff)))));
    Coeff_DR_den_imag = 20*log10( (max(abs(imag(den_coeff))))/(min(abs(imag(den_coeff)))));
    Coeff_DR_den = max(Coeff_DR_den_real,Coeff_DR_den_imag);

elseif strcmp(DPD_type,'RF_Volterra_ET')
    [Coeff_RF_Volterra]=Identify_RF_Volterra_v2_ET(DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I , DelayAdjusted_Out_Q , DelayAdjusted_Vdd, RF_Volterra_Parameters , Fs, NofDPDPoints );

end


[MP_coefficients, NMSE_error, Cond_A] = Identify_TwoStep_SingleBand_MP(MP_modelParam, DelayAdjusted_In_I, DelayAdjusted_In_Q, DelayAdjusted_Out_I, DelayAdjusted_Out_Q, NofDPDPoints);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Apply DPD 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(DPD_type, 'Volterra_DDR')           
    [ Pr_I , Pr_Q ] = VolterraDpdApply_ET ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), VolterraETParameters , VolterraCoeff ) ;     
%         [ Pr_I , Pr_Q ] = VolterraDpdApply ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , VolterraETParameters , VolterraCoeff ) ; 

elseif strcmp(DPD_type, 'Volterra_DDR_ET')           
    [ Pr_I , Pr_Q ] = VolterraDpdApply_ET ( In_I_beforeDPD_EVM , In_Q_beforeDPD_EVM , DelayAdjusted_Vdd_beforeDPD, VolterraETParameters , VolterraCoeff ) ;     

elseif strcmp(DPD_type,'RF_Volterra')
    [Pr_I , Pr_Q]=Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, abs(complex(In_I_beforeDPD_EVM,In_Q_beforeDPD_EVM)), Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);
%         [Pr_I , Pr_Q]=Apply_RF_Volterra(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);

elseif strcmp(DPD_type,'MP')
    [Pr_I, Pr_Q] = Apply_SingleBand_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients);

elseif strcmp(DPD_type,'Aug_MP')
    [Pr_I, Pr_Q] = Apply_SingleBand_Aug_MP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, MP_modelParam, MP_coefficients, gamma);

elseif strcmp(DPD_type,'RF_MP')
    [Pr_I, Pr_Q] = Apply_SingleBand_RFMP(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, Param_array, num_coeff, den_coeff);

elseif strcmp(DPD_type,'RF_Volterra_ET')
    [Pr_I , Pr_Q]=Apply_RF_Volterra_v2_ET(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, DelayAdjusted_Vdd_beforeDPD, Coeff_RF_Volterra, RF_Volterra_Parameters , Fs);

end

Pr_I_up=resample(Pr_I,DownSampleTx,UpSampleTx);
Pr_Q_up=resample(Pr_Q,DownSampleTx,UpSampleTx);

avg_Pr=10*log10(mean((abs(Pr_I+1i*Pr_Q).^2))/100)+30;
peak_Pr=10*log10(max((abs(Pr_I+1i*Pr_Q).^2))/100)+30;
PAPR_Pr = peak_Pr - avg_Pr;

disp([' *************************  ']); 
disp([' PAPR_Pr ',num2str(PAPR_Pr) ]); 
disp([' *************************  ']);

Draw_spectrum (In_I_beforeDPD,In_I_beforeDPD,Pr_I_up,Pr_Q_up)

In_I = Pr_I_up;
In_Q = Pr_Q_up;     
close all;    