function [coefficients, gamma, fval, exitflag, NMSE, Cond_A] = Identify_SingleBand_Aug_MP(modelParam, gamma, PA_in_I, PA_in_Q, PA_out_I, PA_out_Q, NofDPDPoints)

%coefficients = 'aij' for base memory polynomial
%gamma_fin = value of gamma that minimizes the NMSE
%fval = value of NMSE achieved with gamma_fin 
%exitflag = 1 is good. Any other value may indicate convergence problem. 

%modelParam has the following structure:
N = modelParam.N;
M = modelParam.M;
model = modelParam.type; %type = 'odd' or 'odd_even'

global C_Aug_MP y

% interchange x and y
x_temp = complex(PA_out_I,PA_out_Q);
PA_in = complex(PA_in_I, PA_in_Q);
y_temp = PA_in;

% normalization
[norm_yI, norm_yQ] = setMeanPower(real(y_temp), imag(y_temp), 0); 
[norm_xI, norm_xQ] = setMeanPower(real(x_temp), imag(x_temp), 0); 

all_y = complex(norm_yI, norm_yQ);
all_x = complex(norm_xI, norm_xQ);

% selecting data for DPD identification
[start_ind, end_ind, ind_max_x, x] = ReturnPeakRegion(all_x, NofDPDPoints);

y = all_y(start_ind+M-1:end_ind);

% [start_ind, end_ind, ind_max_y, y] = ReturnPeakRegion(all_y, training_length);

% generate A matrix
    A = Generate_MP_Matrix(x, M, N, 'TRUEMP', model);

    % generate B matrix
    for ind=1:1:size(A,2)
        B(:,ind) = A(:,ind).*abs(x(M:end));
    end
       
% pass it to fminsearch
C_Aug_MP = [A B];

%%

if (gamma == 0)
    % finding the right gamma

    vec = -2:1:2;

    gamma_init = zeros((length(vec))^2,2);

    gamma_ind = 0;

    for ind1=1:1:length(vec)
        for ind2=1:1:length(vec)
            gamma_ind = gamma_ind+1;
            gamma_init(gamma_ind,:) = [vec(ind1) vec(ind2)];
        end
    end

    % gamma_init = [0 0];
    % gamma_init = [-1 -0.5];
    % gamma_init = [1 1];

    results = zeros(size(gamma_init,1),4);

    for index = 1:1:size(gamma_init,1)    
        [gamma_fin, fval, exitflag] = fminsearch(@evaluate_gamma, gamma_init(index,:));
        results(index,:) = [gamma_fin, fval, exitflag];
    end
    %%

    results

    [minval, minind] = min(results(:,3));
    real_gamma = results(minind,1);
    imag_gamma = results(minind,2);
    gamma = (complex(real_gamma, imag_gamma));
    % use gamma to sum A and B

end

A = A+gamma*B;

% use LSE to solve for coefficients
coefficients = (pinv(A,eps)*y);

Cond_A = cond(A);

y_est = A*coefficients;
NMSE = 10*log10( mean(abs(y-y_est).^2) / mean(abs(y).^2) );

disp([' *************************  ']); 
disp([' NMSE = ', num2str(NMSE), ' dB' ]);
disp([' *************************  ']);

disp([' *************************  ']); 
disp([' Gamma = ', num2str(gamma) ]);
disp([' *************************  ']);

disp([' *************************  ']); 
disp([' No. of coefficients ', num2str(size(coefficients,1)) ]);
disp([' *************************  ']);

end