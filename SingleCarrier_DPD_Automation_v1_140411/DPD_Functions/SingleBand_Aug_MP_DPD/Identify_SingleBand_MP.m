function [coefficients, NMSE, Cond_A] = Identify_SingleBand_MP(modelParam, PA_in_I, PA_in_Q, PA_out_I, PA_out_Q, NofDPDPoints)
%coefficients = 'aij' for base memory polynomial

%modelParam has the following structure:
N = modelParam.N;
M = modelParam.M;
model = modelParam.type; %type = 'odd' or 'odd_even'

global A y

% interchange x and y
x = complex(PA_out_I(1:NofDPDPoints),PA_out_Q(1:NofDPDPoints));
PA_in = complex(PA_in_I(1:NofDPDPoints), PA_in_Q(1:NofDPDPoints));
y = PA_in(M:length(PA_in));

% normalization
[norm_yI, norm_yQ] = setMeanPower(real(y), imag(y), 0); 
[norm_xI, norm_xQ] = setMeanPower(real(x), imag(x), 0); 

y = complex(norm_yI, norm_yQ);
x = complex(norm_xI, norm_xQ);

% generate A matrix
    A = Generate_MP_Matrix(x, M, N, 'TRUEMP', model);

% use LSE to solve for coefficients
coefficients = (pinv(A,1e-5)*y);

Cond_A = cond(A);

y_est = A*coefficients;
NMSE = 10*log10(mean(((abs(y-y_est).^2)/mean(abs(y)).^2)))

PlotGain_WithWithout(real(x(M:length(x))),imag(x(M:length(x))),real(y),imag(y),real(y_est),imag(y_est)) ;
PlotAMPM_WithWithout(real(x(M:length(x))),imag(x(M:length(x))),real(y),imag(y),real(y_est),imag(y_est)) ;

disp([' *************************  ']); 
disp([' NMSE = ', num2str(NMSE), ' dB' ]);
disp([' *************************  ']);

disp([' *************************  ']); 
disp([' No. of coefficients ', num2str(size(coefficients,1)) ]);
disp([' *************************  ']);

end