function [num_coeff, den_coeff, NMSE, real_zeros, imag_zeros, comp_zeros] = Identify_SingleBand_RFMP_NL(RFMP_modelParam, PA_in_I, PA_in_Q, PA_out_I, PA_out_Q, NofDPDPoints, params)
global D E Yout M_DEN N_DEN MOD_DEN max_sig
%modelParam has the following structure:
M_NUM = RFMP_modelParam.M_NUM;
M_DEN = RFMP_modelParam.M_DEN;
N_NUM = RFMP_modelParam.N_NUM;
N_DEN = RFMP_modelParam.N_DEN;
MOD_NUM = RFMP_modelParam.MOD_NUM;
MOD_DEN = RFMP_modelParam.MOD_DEN;

M_MAX = max(M_NUM, M_DEN);

% interchange x and y
all_x = complex(PA_out_I,PA_out_Q);
all_y = complex(PA_in_I, PA_in_Q);

% selecting data for DPD identification
[start_ind, end_ind, ind_max_x, x] = ReturnPeakRegion(all_x, NofDPDPoints,0);
y = all_y(start_ind:end_ind);

[B,C,X] = Generate_RFMP_Matrix(x, y, RFMP_modelParam);
[B_allpoints, C_allpoints, X_allpoints] = Generate_RFMP_Matrix(all_x, all_y, RFMP_modelParam);

y = y(M_MAX:end);
y_allpoints = all_y(M_MAX:end);

D = B;
E = X;
Yout = y;
max_sig = max(abs(all_x));

%generate initial guess for coeff
A = [B C];

% using LSE
% a_pd = pinv(A,1e-5)*Yout;

%using 10 iterations of QRRLS
[out,e,h1,a_pd] = qrrlsUsingA_modded(A,Yout,size(A,2),.999,var(x),0,'no',10);

init_coeff = [real(a_pd);imag(a_pd)];

options = optimset('MaxFunEvals', params.MaxFunEval, 'MaxIter', params.MaxIter, 'TolFun', params.TolFun);

if strcmp(RFMP_modelParam.BASIS,'RFMP_ADRF')
    NL_est_coeff = fmincon(@fmincon_RFMPfun_com,init_coeff,[],[],[],[],[],[],@root_con_sep,options);
elseif strcmp(RFMP_modelParam.BASIS,'RFMP_DRF_MFOD')
    NL_est_coeff = fminunc(@fmincon_RFMPfun_com,init_coeff,options);
end

NL_est_coeff = complex...
    (NL_est_coeff(1:0.5*length(NL_est_coeff)),NL_est_coeff(1+0.5*length(NL_est_coeff):end));

num_coeff = NL_est_coeff(1:size(B,2));
den_coeff = NL_est_coeff(size(B,2)+1:end);

if strcmp(RFMP_modelParam.BASIS,'RFMP_ADRF')
    [real_zeros, imag_zeros] = zero_finder(den_coeff, M_DEN, N_DEN, MOD_DEN)
    comp_zeros = 0;
else
    real_zeros = 0;
    imag_zeros = 0;
    comp_zeros = 0;
end

y_est = (B*num_coeff)./(1+X*den_coeff);
y_est_allpoints = (B_allpoints*num_coeff)./(1+X_allpoints*den_coeff);

NMSE = 10*log10( mean(abs(y-y_est).^2) / mean(abs(y).^2) );
NMSE_allpoints = 10*log10( mean(abs(y_allpoints-y_est_allpoints).^2) / mean(abs(y_allpoints).^2) );

disp([' *************************  ']); 
disp([' NMSE = ', num2str(NMSE), ' dB' ]);
disp([' *************************  ']);

disp([' *************************  ']); 
disp([' NMSE_ALLPOINTS = ', num2str(NMSE_allpoints), ' dB' ]);
disp([' *************************  ']);

disp([' *************************  ']); 
disp([' No. of numerator coefficients ', num2str(size(B,2)) ]);
disp([' *************************  ']);

disp([' *************************  ']); 
disp([' No. of denominator coefficients ', num2str(size(C,2)) ]);
disp([' *************************  ']);

end