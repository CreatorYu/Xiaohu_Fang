function [PD_outI, PD_outQ, comp_numout, comp_denout] = Apply_SingleBand_RFMP(in_I, in_Q, RFMP_modelParam, num_coeff, den_coeff, real_zeros, imag_zeros, comp_zeros)

%extract the model parameters
    M_NUM = RFMP_modelParam.M_NUM;
    M_DEN = RFMP_modelParam.M_DEN;
    N_NUM = RFMP_modelParam.N_NUM;
    N_DEN = RFMP_modelParam.N_DEN;
    MOD_NUM = RFMP_modelParam.MOD_NUM;
    MOD_DEN = RFMP_modelParam.MOD_DEN;
    DEN_TYP = RFMP_modelParam.DEN_TYP;
    
M_MAX = max(M_NUM, M_DEN);

B = [];
C = [];    

x = complex(in_I, in_Q);

% normalization
[norm_xI, norm_xQ] = setMeanPower(real(x), imag(x), 0); 
x = complex(norm_xI, norm_xQ);

if strcmp(RFMP_modelParam.BASIS,'RFMP_ADRF')
   check_for_zeros(x, real_zeros, imag_zeros);
end

[B,C,X] = Generate_RFMP_Matrix(x, zeros(size(x)), RFMP_modelParam);

numerator = B*num_coeff;

if M_DEN ~=0
	denominator = X*den_coeff;
	PD_out = numerator./(1+denominator);
    comp_numout = numerator;
    comp_denout = 1 + denominator;
else
	PD_out = numerator;
end

PD_outI = real(PD_out);
PD_outQ = imag(PD_out);

end

