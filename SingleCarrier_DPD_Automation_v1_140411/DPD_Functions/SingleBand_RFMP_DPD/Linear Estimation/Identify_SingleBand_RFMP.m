function [num_coeff, den_coeff, NMSE, Cond_A, real_zeros, imag_zeros, comp_zeros] = Identify_SingleBand_RFMP(RFMP_modelParam, PA_in_I, PA_in_Q, PA_out_I, PA_out_Q, NofDPDPoints)
global pinv_tol
%modelParam has the following structure:
M_NUM = RFMP_modelParam.M_NUM;
M_DEN = RFMP_modelParam.M_DEN;
N_NUM = RFMP_modelParam.N_NUM;
N_DEN = RFMP_modelParam.N_DEN;
MOD_NUM = RFMP_modelParam.MOD_NUM;
MOD_DEN = RFMP_modelParam.MOD_DEN;
DEN_TYP = RFMP_modelParam.DEN_TYP;

M_MAX = max(M_NUM, M_DEN);

% interchange x and y
all_x = complex(PA_out_I,PA_out_Q);
all_y = complex(PA_in_I, PA_in_Q);

% selecting data for DPD identification
[start_ind, end_ind, ind_max_x, x] = ReturnPeakRegion(all_x, NofDPDPoints,0);
y = all_y(start_ind:end_ind);

% generate A matrix
[B,C] = Generate_RFMP_Matrix(x, y, RFMP_modelParam);
[B_allpoints, C_allpoints] = Generate_RFMP_Matrix(all_x, all_y, RFMP_modelParam);

y = y(M_MAX:end);
y_allpoints = all_y(M_MAX:end);

A = [B C];
A_allpoints = [B_allpoints C_allpoints];

% use LSE to solve for coefficients
coefficients = (pinv(A,pinv_tol)*y);
Cond_A = cond(A.'*A);

num_coeff = coefficients(1:size(B,2));
den_coeff = coefficients(size(B,2)+1:end);

if strcmp(RFMP_modelParam.BASIS,'RFMP_ADRF')
    [real_zeros, imag_zeros] = zero_finder(den_coeff, M_DEN, N_DEN, MOD_DEN)
    comp_zeros = 0;
else
    real_zeros = 0;
    imag_zeros = 0;
    comp_zeros = 0;
end

y_est = A*coefficients;
y_est_allpoints = A_allpoints*coefficients;

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

disp([' *************************  ']); 
disp([' Condition Number ', num2str(Cond_A) ]);
disp([' *************************  ']);
end