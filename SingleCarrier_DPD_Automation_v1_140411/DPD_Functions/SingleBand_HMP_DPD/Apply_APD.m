function [output, offset] = Apply_APD(input, model, params)

N = model.N;
M = model.M;

if strcmp(model.engine, 'ZC')
    % For phase/imag
    if isfield(model, 'PN')
        PN = model.PN;
        PM = model.PM;
    else
        PN = N;
        PM = M;
    end
    Zre = real(model.coef);
    Zim = imag(model.coef);
    if M > 1
        deriv = diff(abs(input))*params.Fs*params.upsample_rate;
        input = input(2:end);
    end
    
    z_out_re = ones(length(input), 1);
    z_out_re=z_out_re.*Zre(1);
    for n=1:N
        z_out_re=z_out_re.*(abs(input)-Zre(n+1));
    end
    
    z_out_im = ones(length(input), 1);
    z_out_im = z_out_im.*Zim(1);
    for n=1:PN
        z_out_im=z_out_im.*(abs(input)-Zim(n+1));
    end
    offset = 1;
    
    if M > 1
        M_start = max(N,PN)+2;
        z_m_re = deriv;
        z_m_re = z_m_re.*Zre(M_start);
        for n=1:M
            z_m_re=z_m_re.*(abs(input)-Zre(n+M_start));
        end
        z_out_re = z_out_re + z_m_re;
        
        z_m_im = deriv;
        z_m_im = z_m_im.*Zim(M_start);
        for n=1:PM
            z_m_im=z_m_im.*(abs(input)-Zim(n+M_start));
        end
        z_out_im = z_out_im + z_m_im;
        offset = 2;
    end
    
    if strcmp(model.architecture, 'multiply')
        output = complex(z_out_re, z_out_im).*input;
    elseif strcmp(model.architecture,'add')
        output = complex(z_out_re, z_out_im).*input + input;
    end
    
else
    if length(model.engine)>=4 && strcmp(model.engine(1:4), 'Mod_')
        A = Generate_MemPoly_Matrix(input, model.M, model.N, model.engine, model.polyorder, model.FIR_M);
        offset = max(model.M, model.FIR_M);
    else
        A = Generate_MemPoly_Matrix(input, model.M, model.N, model.engine, model.polyorder);
        offset = model.M;
    end
    if strcmp(model.architecture, 'multiply')
        output = A*model.coef;
    elseif strcmp(model.architecture, 'add')
        output = A*model.coef + input(offset:end);
    end
end

end
