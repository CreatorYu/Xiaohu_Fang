function residue = fmincon_RFMPfun_com(coeff)
global D E Yout
    all_coeff = complex(coeff(1:0.5*length(coeff)),coeff(1+0.5*length(coeff):end));
    num_coeff = all_coeff(1:size(D,2));
    den_coeff = all_coeff(size(D,2)+1:end);
    numerator = D*num_coeff;
    denominator = E*den_coeff;
    PD_out = numerator./(1+denominator);
    NMSE = 10*log10( mean(abs(Yout-PD_out).^2)/mean(abs(Yout).^2) );
    % either choose residue as NMSE, or norm of error
    residue = NMSE;
end
