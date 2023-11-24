function [disgamma] = Distort_Gamma(gamma)

    max_realdis = 0.25;
    step_realdis = 0.125;
    max_imagdis = 0.25;
    step_imagdis = 0.125;
    
    real_disvec = -max_realdis:step_realdis:max_realdis;
    imag_disvec = -max_imagdis:step_imagdis:max_imagdis;
    
    
    real_gamma = real(gamma);
    imag_gamma = imag(gamma);
    
    real_disgamma = real_gamma.*(1+real_disvec);
    imag_disgamma = imag_gamma.*(1+imag_disvec);

    disgamma = zeros(length(real_disgamma)*length(imag_disgamma),1);
    
    disgamma_ind = 0;
    
    for ind1 = 1:length(real_disgamma)
        for ind2 = 1:length(imag_disgamma)
            disgamma_ind = disgamma_ind+1;
            disgamma(disgamma_ind,:) = complex(real_disgamma(ind1),imag_disgamma(ind2));
        end
    end
      
end