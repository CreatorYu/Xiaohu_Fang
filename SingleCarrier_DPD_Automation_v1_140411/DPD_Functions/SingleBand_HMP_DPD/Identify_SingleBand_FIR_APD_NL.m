function [NL_coeff, NMSE_ALL_NL] = Identify_SingleBand_FIR_APD_NL(modelParam, PA_in_I, PA_in_Q, PA_out_I, PA_out_Q, NofDPDPoints, init_coeff, params)

% Interchange input and output to model reverse PA
y_ori = complex(PA_in_I, PA_in_Q);
x_ori = complex(PA_out_I,PA_out_Q);

[x, y] = Extract_Signal_Peak(x_ori, y_ori, NofDPDPoints, 0);

% Validation Check
if params.DEBUG == 1
    [y_estI, y_estQ, y_offset] = Apply_SingleBand_FIR_APD(real(x), imag(x), modelParam, init_coeff);
    y_est = complex(y_estI, y_estQ);
    y_dis = y(y_offset:end);

    NMSE_TR = CalculateNMSE(y_dis, y_est);
    disp([' *************************  ']);
    disp([' NMSE_TR = ', num2str(NMSE_TR), ' dB' ]);
    disp([' *************************  ']);
    
    [y_estI_all, y_estQ_all, y_offset] = Apply_SingleBand_FIR_APD(real(x_ori), imag(x_ori), modelParam, init_coeff);
    y_est_all = complex(y_estI_all, y_estQ_all);
    y_dis_all = y_ori(y_offset:end);
    
    NMSE_ALL = CalculateNMSE(y_dis_all, y_est_all);
    disp([' *************************  ']);
    disp([' NMSE_ALL = ', num2str(NMSE_ALL), ' dB' ]);
    disp([' *************************  ']);    
end

% HAI, you can replace this with your function to split the coefficients,
% if you want
split_coeff = [real(init_coeff(1:end));imag(init_coeff(1:end))];
options = optimset('MaxFunEvals', params.MaxFunEval, 'MaxIter', params.MaxIter, 'TolFun', params.TolFun);
[NL_coeff, residue] = fminunc(@fmincon_CASCTB, split_coeff, options);

NL_coeff = complex...
    (NL_coeff(1:0.5*length(NL_coeff)),NL_coeff(1+0.5*length(NL_coeff):end));


if params.DEBUG == 1
    [y_estI, y_estQ, y_offset] = Apply_SingleBand_FIR_APD(real(x), imag(x), modelParam, NL_coeff);
    y_est = complex(y_estI, y_estQ);
    y_dis = y(y_offset:end);

    NMSE_TR_NL = CalculateNMSE(y_dis, y_est);
    disp([' *************************  ']);
    disp([' NMSE_TR_NL = ', num2str(NMSE_TR_NL), ' dB' ]);
    disp([' *************************  ']);
end

[y_estI_all, y_estQ_all, y_offset] = Apply_SingleBand_FIR_APD(real(x_ori), imag(x_ori), modelParam, NL_coeff);
y_est_all = complex(y_estI_all, y_estQ_all);
y_dis_all = y_ori(y_offset:end);
x_dis_all = x_ori(y_offset:end);
NMSE_ALL_NL = ModelCheck(x_dis_all, y_dis_all, y_est_all);


    function residue = fmincon_CASCTB(coeff)
        
        coeff = complex(coeff(1:0.5*length(coeff)),coeff(1+0.5*length(coeff):end));
        
        [ytmp_I, ytmp_Q, offset] = Apply_SingleBand_FIR_APD(real(x), imag(x), modelParam, coeff);
        ytmp = complex(ytmp_I, ytmp_Q);
        yref = y(offset:end);
        if params.DEBUG == 1
            NMSE = CalculateNMSE(yref, ytmp)
        end
        residue = ( mean(abs(yref-ytmp).^2)/mean(abs(yref).^2) );
    end

end
