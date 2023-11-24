function [InI_pred1, InQ_pred1 ,InI_pred2, InQ_pred2]=Apply_dual_band_MP_ET(InI1, InQ1,InI2, InQ2, a_coef1, a_coef2, Dualband_MP_Parameters , src_srate)


%external parameters
Mk=Dualband_MP_Parameters.memory_step;%=1; 
M=Dualband_MP_Parameters.memory_depth;%=3 ; 
NL=Dualband_MP_Parameters.NL;%=7 ; 
omega0=2*pi*Dualband_MP_Parameters.carrier_frequency;%=2*pi*2.14e9;
omega=omega0;
seperation=Dualband_MP_Parameters.seperation_btwn_two_bands;
% bandwidth=Dualband_Volterra_Parameters.max_bandwidth_of_band; obselete
DPD_fs=Dualband_MP_Parameters.DPD_fs;
NSupply=Dualband_MP_Parameters.NSupply;%=5 ; 

%internal_coeff
power_backoff=0;%-0.35
Ts=1/DPD_fs;
alpha=-2*pi*seperation/2;


%% Data pretreatment
% InI1  = InI1(:,1)'      ; InQ1  = InQ1(:,1)'        ;
% InI2  = InI2(:,1)'      ; InQ2  = InQ2(:,1)'        ;
% L = min( min(length(I1_inpa),length(I2_outpa)),min(length(I2_inpa),length(I3_outpa)) ); 
% InI1  = InI1(1:L) ; InQ1  = InQ1(1:L) ;
% InI2  = InI2(1:L) ; InQ2  = InQ2(1:L) ;

%%%%%%%%%%Offset removal

avg_in1=10*log10(mean((abs(InI1+1i*InQ1).^2))/100)+30;
InI1=InI1*10^((power_backoff-avg_in1)/20);
InQ1=InQ1*10^((power_backoff-avg_in1)/20);
avg_in1=10*log10(mean((abs(InI1+1i*InQ1).^2))/100)+30
peak_in1=10*log10(max((abs(InI1+1i*InQ1).^2))/100)+30
PAPR1=peak_in1-avg_in1

avg_in2=10*log10(mean((abs(InI2+1i*InQ2).^2))/100)+30;
InI2=InI2*10^((power_backoff-avg_in2)/20);
InQ2=InQ2*10^((power_backoff-avg_in2)/20);
avg_in2=10*log10(mean((abs(InI2+1i*InQ2).^2))/100)+30
peak_in2=10*log10(max((abs(InI2+1i*InQ2).^2))/100)+30
PAPR2=peak_in2-avg_in2

%% generate predistorted signal
x_in1=InI1+1i*InQ1;
x_in2=InI2+1i*InQ2;

a=[x_in1; x_in1(1:(M-1)*Mk)];
b=[x_in2; x_in2(1:(M-1)*Mk)];
N=length(a);

for count = 1:NSupply
    for count1 = 1:NL
        for count2 = 1:1%count1        
            for countm = 0:M-1
                at = circshift(a,Mk*countm);
                bt = circshift(b,Mk*countm);
                a_dt = abs(at)+abs(bt);
                a_d = abs(a)+abs(b);
                c0 = 0.339; c1 = 0.801; c2 = 1 - c0 - c1;
%                 a_norm_fact = max(max(abs(In1_dt)),max(abs(In2_dt)));
%                 a_shaped1_dt = c0 + c1*(abs(In1_dt)/a_norm_fact).^2 + c2*(abs(In1_dt)/a_norm_fact).^4;
%                 a_shaped2_dt = c0 + c1*(abs(In2_dt)/a_norm_fact).^2 + c2*(abs(In2_dt)/a_norm_fact).^4;            
%                 a_shaped_dt = (a_shaped1_dt + a_shaped2_dt)*a_norm_fact;
%                 
%                 a_shaped1_d = c0 + c1*(abs(In1_d)/a_norm_fact).^2 + c2*(abs(In1_d)/a_norm_fact).^4;
%                 a_shaped2_d = c0 + c1*(abs(In2_d)/a_norm_fact).^2 + c2*(abs(In2_d)/a_norm_fact).^4;            
%                 a_shaped_d = (a_shaped1_d + a_shaped2_d)*a_norm_fact;

%                 A1(:,count*count1*count2*(countm + 1)) = at.*(abs(at)).^(count1 - count2 - 1).*(abs(bt)+abs(at)).^(count2 - 1).*((a_d).^((count - 1)));% + In2_dt.*(abs(In2_dt)).^(count1 - 1)./((a_dt).^((count2 - 1)));
%                 A2(:,count*count1*count2*(countm + 1)) = bt.*(abs(bt)).^(count1 - count2 - 1).*(abs(at)+abs(bt)).^(count2 - 1).*((a_d).^((count - 1)));% + In2_d.*(abs(In2_d)).^(count1 - 1).*(abs(In1_d)).^(count2 - 1);

% % % Version 1 
%                 A1(:,count*count1*count2*(countm + 1)) = at.*(abs(at)).^(count1 - count2 - 1).*(abs(bt)).^(count2 - 1).*((a_d).^((count - 1)));% + In2_dt.*(abs(In2_dt)).^(count1 - 1)./((a_dt).^((count2 - 1)));
%                 A2(:,count*count1*count2*(countm + 1)) = bt.*(abs(bt)).^(count1 - count2 - 1).*(abs(at)).^(count2 - 1).*((a_d).^((count - 1)));% + In2_d.*(abs(In2_d)).^(count1 - 1).*(abs(In1_d)).^(count2 - 1);

% % % Version 2 
                A1(:,count*count1*count2*(countm + 1)) = at.*(abs(abs(at) + abs(bt))).^(count1-1).*((a_d).^((count - 1)));
                A2(:,count*count1*count2*(countm + 1)) = bt.*(abs(abs(at) + abs(bt))).^(count1-1).*((a_d).^((count - 1)));

            end
        
        end    
    end
end
% y_predistorted_1_2 = (A * a_coef);
% file_length=length(x_in1)-(d-1)*m;
% y_predistorted1=y_predistorted_1_2(1:file_length,1);
% y_predistorted2=y_predistorted_1_2(file_length+1:2*file_length,1);

y_predistorted1=(A1 * a_coef1);
y_predistorted2=(A2 * a_coef2);

y_predistorted1 = circshift(y_predistorted1,(M-1)*Mk);
y_predistorted2 = circshift(y_predistorted2,(M-1)*Mk);

InI_pred1=real(y_predistorted1);
InQ_pred1=imag(y_predistorted1);
InI_pred2=real(y_predistorted2);
InQ_pred2=imag(y_predistorted2);

%% wirte signals to files

% fidIEH = fopen('I1_afterDPD.txt','wt');
% fprintf(fidIEH,'%12.20f\n',real(y_predistorted1));
% fclose(fidIEH);
% fidIEH = fopen('Q1_afterDPD.txt','wt');
% fprintf(fidIEH,'%12.20f\n',imag(y_predistorted1));
% fclose(fidIEH);
% fidIEH = fopen('I2_afterDPD.txt','wt');
% fprintf(fidIEH,'%12.20f\n',real(y_predistorted2));
% fclose(fidIEH);
% fidIEH = fopen('Q2_afterDPD.txt','wt');
% fprintf(fidIEH,'%12.20f\n',imag(y_predistorted2));
% fclose(fidIEH);


    
