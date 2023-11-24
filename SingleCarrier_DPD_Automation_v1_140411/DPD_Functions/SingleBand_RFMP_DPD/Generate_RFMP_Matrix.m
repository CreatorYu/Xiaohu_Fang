function [RFMPNum_Matrix, RFMPDen_Matrix, RFMPAlt_Matrix] = Generate_RFMP_Matrix(x, y, RFMP_modelParam)
    M_NUM = RFMP_modelParam.M_NUM;
    M_DEN = RFMP_modelParam.M_DEN;
    N_NUM = RFMP_modelParam.N_NUM;
    N_DEN = RFMP_modelParam.N_DEN;
    MOD_NUM = RFMP_modelParam.MOD_NUM;
    MOD_DEN = RFMP_modelParam.MOD_DEN;
    DEN_TYP = RFMP_modelParam.DEN_TYP;
    
    
	M_MAX = max(M_NUM, M_DEN);
    
    B = [];
    C = [];
    X = [];
    if MOD_NUM == 0
        strt = 0;
        incr = 1;
    elseif MOD_NUM == 1
        strt = 1;
        incr = 2;
    elseif MOD_NUM == 2
        strt = 0;
        incr = 2;        
    end
    
    for t=1:M_NUM
        for Expon = strt:incr:N_NUM
            B = [B x(M_MAX-t+1:end-t+1).*(abs(x(M_MAX-t+1:end-t+1)).^ Expon)];
        end
    end  
    
    if M_DEN ~= 0
        if MOD_DEN == 0
            strt = 0;
            incr = 1;
        elseif MOD_DEN == 1
            strt = 1;
            incr = 2;
        elseif MOD_DEN == 2
            strt = 2;
            incr = 2;        
        end    
        % x appears in denominator
        if (DEN_TYP == 0)
            for t=1:M_DEN
                for Expon = strt:incr:N_DEN
                    C = [C -1*y(M_MAX:end).*x(M_MAX-t+1:end-t+1).*(abs(x(M_MAX-t+1:end-t+1)).^ Expon)];
                    X = [X x(M_MAX-t+1:end-t+1).*abs(x(M_MAX-t+1:end-t+1)).^ Expon];
                end
            end 
        % abs(x) appears in denominator    
        elseif (DEN_TYP == 1)        
            for t=1:M_DEN
                for Expon = strt:incr:N_DEN
                    C = [C -1*y(M_MAX:end).*(abs(x(M_MAX-t+1:end-t+1)).^ Expon)];
                    X = [X (abs(x(M_MAX-t+1:end-t+1)).^ Expon)];
                end
            end 
        end        
    end

    RFMPNum_Matrix = B;
    RFMPDen_Matrix = C;
    RFMPAlt_Matrix = X;
end