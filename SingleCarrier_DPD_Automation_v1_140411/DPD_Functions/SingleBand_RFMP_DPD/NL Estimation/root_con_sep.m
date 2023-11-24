function [c,ceq] = root_con_sep(coeff)
global max_sig M_DEN N_DEN MOD_DEN D
all_coeff = complex(coeff(1:0.5*length(coeff)),coeff(1+0.5*length(coeff):end));
den_coeff = all_coeff(size(D,2)+1:end);
den_coeff = den_coeff.';
c = [];
%determine how many loops are needed
reps = length(den_coeff)/M_DEN;
den_poly = zeros(M_DEN,N_DEN+1); 

% have for loop
for mem = 1:1:M_DEN
    % distance between the zeros and boundary of input values
    % use negative epsilon in conjunction with negative mc to constrain roots
    % within span of input
    epsilon_r = 0;
    epsilon_i = 0;

    % -1 for c >= 0, +1 for c<= 0
    mc_r = 1;
    mc_i = 1;

    if MOD_DEN == 0 %even_odd
        den_poly(mem,:) = [1 den_coeff(reps*(mem-1)+1:reps*(mem))];
    elseif MOD_DEN == 1 %odd_only
        temp = den_coeff(reps*(mem-1)+1:reps*(mem));
        temp = upsample(temp,2);
        temp = temp(1:end-1);
        den_poly(mem,:) = [1 temp];
    elseif MOD_DEN == 2 %even_only
        temp = den_coeff(reps*(mem-1)+1:reps*(mem));
        temp = upsample(temp,2,1);
        den_poly(mem,:) = [1 temp]; 
    end

    den_poly(mem,:) = fliplr(den_poly(mem,:));
    real_den = real(den_poly(mem,:));
    imag_den = imag(den_poly(mem,:));

    real_roots = roots(real_den);
    imag_roots = roots(imag_den);

    % % since absx cannot be negative or complex, ignore these 
    % imag_roots(imag_roots == 0) = [];
    % 
    % real_roots(imag(real_roots) ~= 0) = [];
    % imag_roots(imag(imag_roots) ~= 0) = [];
    % 
    % real_roots(real(real_roots) < 0) = [];
    % imag_roots(real(imag_roots) < 0) = [];

    real_magroots = abs(real_roots);
    imag_magroots = abs(imag_roots);

    % max_sig + epsilon <= real_magroots
    % c <= 0
    % Therefore:
    c_r = max_sig + epsilon_r - real_magroots;
    c_r = mc_r*c_r;

    c_i = max_sig + epsilon_i - imag_magroots;
    c_i = mc_i*c_i;
    c = [c; c_r];
end

% even though constraints for both real/imag roots are created, only real
% roots are constrained
% collect entries here

% ceq is another option
ceq = [];

end
