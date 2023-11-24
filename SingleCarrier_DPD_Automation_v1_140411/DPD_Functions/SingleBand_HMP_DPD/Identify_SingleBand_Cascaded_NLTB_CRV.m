function [coefficients, nonlin_NMSE_tr] = Identify_SingleBand_Cascaded_NLTB_CRV(modelParam, PA_in_I, PA_in_Q, PA_out_I, PA_out_Q, NofDPDPoints, init_coef)
% global mod x_mod y_mod NPoints

DEBUG = 1;

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
[start_ind, end_ind, ind_max_x, x] = ReturnPeakRegion(all_x, NofDPDPoints, 0);
y = all_y(start_ind:end_ind);

% Validation Check

if DEBUG == 1
    [y_est_I, y_est_Q] = Apply_SingleBand_FIR_DPD(real(all_x), imag(all_x), modelParam, init_coef);
    y_est  = complex(y_est_I, y_est_Q);
    y_shift = all_y(modelParam.FIR_D+modelParam.DPD_M-1:end);
    init_NMSE_all = 10*log10( sum(abs(y_shift-y_est).^2)/sum(abs(y_shift).^2) );
    disp([ 'NMSE of all points = ' num2str(init_NMSE_all) 'dB']);

    [y_est_I, y_est_Q] = Apply_SingleBand_FIR_DPD(real(x), imag(x), modelParam, init_coef);
    y_est  = complex(y_est_I, y_est_Q);
    y_shift = y(modelParam.FIR_D+modelParam.DPD_M-1:end);
    init_NMSE_tr = 10*log10( sum(abs(y_shift-y_est).^2)/sum(abs(y_shift).^2) );
    disp([ 'NMSE of training data = ' num2str(init_NMSE_tr) 'dB']);
end

init_coeff = [real(init_coef(1:end));imag(init_coef(1:end))];
options = optimset('MaxFunEvals',40000,'MaxIter',40000,'TolFun',1e-6);
[NL_est_coeff, residue] = fminunc(@fmincon_CASCTB_CRV,init_coef,options);

coefficients = complex...
    (NL_est_coeff(1:0.5*length(NL_est_coeff)),NL_est_coeff(1+0.5*length(NL_est_coeff):end));

[PDout_I, PDout_Q] = Apply_SingleBand_FIR_DPD(real(x), imag(x), modelParam, coefficients);
PDout_model = complex(PDout_I, PDout_Q);
[PDout_Iall, PDout_Qall] = Apply_SingleBand_FIR_DPD(real(all_x), imag(all_x), modelParam, coefficients);
PDout_model_all = complex(PDout_Iall, PDout_Qall);
 
PDout = x(modelParam.FIR_D+modelParam.DPD_M-1:end);
y_shift = y(modelParam.FIR_D+modelParam.DPD_M-1:end);
nonlin_NMSE_tr = ModelCheck(PDout, y_shift, PDout_model);
disp([ 'NMSE of training data = ' num2str(nonlin_NMSE_tr) 'dB']);

    function residue = fmincon_CASCTB_CRV(coeff)
        all_coeff = complex(coeff(1:0.5*length(coeff)),coeff(1+0.5*length(coeff):end));
        [y_est_I, y_est_Q] = Apply_SingleBand_FIR_DPD(real(x), imag(x), modelParam, coeff);
        y_est = complex(y_est_I, y_est_Q);
        if DEBUG == 1
            NMSE = 10*log10( mean(abs(y-y_est).^2)/mean(abs(y).^2) )
%             disp([ 'NMSE of iteration = ' num2str(NMSE) 'dB']);
        end
        residue = ( mean(abs(y-y_est).^2)/mean(abs(y).^2) );
    end

end