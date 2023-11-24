function [a_coef1 a_coef2]=Identify_dual_band_MP_ET(I1_inpa, Q1_inpa,I2_inpa, Q2_inpa, I2_outpa , Q2_outpa ,I3_outpa , Q3_outpa , Dualband_MP_Parameters , rec_srate, NbOfPoint )

%external parameters
traning_data_length = NbOfPoint;%number of points used
Mk=Dualband_MP_Parameters.memory_step;%=1; 
M=Dualband_MP_Parameters.memory_depth;%=3 ; 
NL=Dualband_MP_Parameters.NL;%=7 ; 
omega0=2*pi*Dualband_MP_Parameters.carrier_frequency;%=2*pi*2.14e9;
seperation=Dualband_MP_Parameters.seperation_btwn_two_bands;
% bandwidth=Dualband_Volterra_Parameters.max_bandwidth_of_band; obselete
DPD_fs=Dualband_MP_Parameters.DPD_fs;
NSupply=Dualband_MP_Parameters.NSupply;%=5 ; 

%internal parameters
omega=omega0;
Ts=1/DPD_fs;
alpha=-2*pi*seperation/2;

task='DPD';
% task='Modeling';
Validation='same data';


%% PA or DPD construction : 
if strcmp(task, 'DPD')
    temp=I1_inpa; I1_inpa=I2_outpa; I2_outpa=temp;
    temp=Q1_inpa; Q1_inpa=Q2_outpa; Q2_outpa=temp;
    temp=I2_inpa; I2_inpa=I3_outpa; I3_outpa=temp;
    temp=Q2_inpa; Q2_inpa=Q3_outpa; Q3_outpa=temp;
end

%% same length of data

min_length=min(min(length(I1_inpa),length(I2_inpa)),min(length(I2_outpa),length(I3_outpa)));
I1_inpa=I1_inpa(1:min_length); Q1_inpa=Q1_inpa(1:min_length);
I2_inpa=I2_inpa(1:min_length); Q2_inpa=Q2_inpa(1:min_length); 
I2_outpa=I2_outpa(1:min_length); Q2_outpa=Q2_outpa(1:min_length);
I3_outpa=I3_outpa(1:min_length); Q3_outpa=Q3_outpa(1:min_length); 


%% Offset Removal
avg_in1=10*log10(mean((abs(I1_inpa+1i*Q1_inpa).^2))/100)+30;
avg_out1=10*log10(mean((abs(I2_outpa+1i*Q2_outpa).^2))/100)+30;
avg_in2=10*log10(mean((abs(I2_inpa+1i*Q2_inpa).^2))/100)+30;
avg_out2=10*log10(mean((abs(I3_outpa+1i*Q3_outpa).^2))/100)+30;

I1_inpa=I1_inpa*10^((0-avg_in1)/20);
Q1_inpa=Q1_inpa*10^((0-avg_in1)/20);
I2_outpa=I2_outpa*10^((0-avg_out1)/20);
Q2_outpa=Q2_outpa*10^((0-avg_out1)/20);

I2_inpa=I2_inpa*10^((0-avg_in2)/20);
Q2_inpa=Q2_inpa*10^((0-avg_in2)/20);
I3_outpa=I3_outpa*10^((0-avg_out2)/20);
Q3_outpa=Q3_outpa*10^((0-avg_out2)/20);

avg_in1=10*log10(mean((abs(I1_inpa+1i*Q1_inpa).^2))/100)+30;
peak_in1=10*log10(max((abs(I1_inpa+1i*Q1_inpa).^2))/100)+30
PAPR_in1=peak_in1-avg_in1

avg_out1=10*log10(mean((abs(I2_outpa+1i*Q2_outpa).^2))/100)+30;
peak_out1=10*log10(max((abs(I2_outpa+1i*Q2_outpa).^2))/100)+30
PAPR_out1=peak_out1-avg_out1

avg_in2=10*log10(mean((abs(I2_inpa+1i*Q2_inpa).^2))/100)+30;
peak_in2=10*log10(max((abs(I2_inpa+1i*Q2_inpa).^2))/100)+30
PAPR_in2=peak_in2-avg_in2

avg_out2=10*log10(mean((abs(I3_outpa+1i*Q3_outpa).^2))/100)+30;
peak_out2=10*log10(max((abs(I3_outpa+1i*Q3_outpa).^2))/100)+30
PAPR_out2=peak_out2-avg_out2

%% phase synchronisation
x_in1=I1_inpa+1i*Q1_inpa;
y_out2=I2_outpa+1i*Q2_outpa;
Phaseout2=angle(y_out2)-angle(x_in1);
Ind = Phaseout2 > pi;
Phaseout2 = Phaseout2 - 2*Ind*pi;
Ind = Phaseout2 < -pi;
Phaseout2 = Phaseout2 + 2*Ind*pi;

AvgPhaseout2 = mean(Phaseout2)
y_out2 = y_out2 * exp(-1i*AvgPhaseout2) ;
% err2 = y_out2 - x_in1 ;
I2_outpa=real(y_out2);
Q2_outpa=imag(y_out2);


x_in2=I2_inpa+1i*Q2_inpa;
y_out3=I3_outpa+1i*Q3_outpa;
Phaseout3=angle(y_out3)-angle(x_in2);
Ind = Phaseout3 > pi;
Phaseout3 = Phaseout3 - 2*Ind*pi;
Ind = Phaseout3 < -pi;
Phaseout3 = Phaseout3 + 2*Ind*pi;

AvgPhaseout3 = mean(Phaseout3)
y_out3 = y_out3 * exp(-1i*AvgPhaseout3) ;
% err3 = y_out2 - x_in2 ;
I3_outpa=real(y_out3);
Q3_outpa=imag(y_out3);



%% find max and choose data
Pindb = 10*log10(abs(I2_inpa+1i*Q2_inpa).^2/100+abs(I1_inpa+1i*Q1_inpa).^2/100)+30;
Max = max(Pindb)
aux = find(Pindb == Max )
Pindb1 = 10*log10(abs(I1_inpa+1i*Q1_inpa).^2/100)+30;
Max1 = max(Pindb1)
aux1 = find(Pindb1 == Max1 )
Pindb2 = 10*log10(abs(I2_inpa+1i*Q2_inpa).^2/100)+30;
Max2 = max(Pindb2)
aux2 = find(Pindb2 == Max2 )
% Traning_data = (aux2-500):(aux2+traning_data_length-500);
% Traning_data = (aux-traning_data_length/2):(aux+traning_data_length/2);
% Traning_data = (aux-traning_data_length):min_length;
% Traning_data = (aux-1000):aux+traning_data_length;
% Traning_data = (aux2-traning_data_length/2):(aux2+traning_data_length/2);

Traning_data=1:length(I1_inpa);

% maxindex_In = 6.6e4/4;
% Traning_data = (maxindex_In - traning_data_length/2):(maxindex_In + traning_data_length/2)


%% Model identification
% Data format
x_in1=(I1_inpa(Traning_data)+1i*Q1_inpa(Traning_data));
x_in2=(I2_inpa(Traning_data)+1i*Q2_inpa(Traning_data));
y_out1=(I2_outpa(Traning_data)+1i*Q2_outpa(Traning_data));
y_out2=(I3_outpa(Traning_data)+1i*Q3_outpa(Traning_data));

a=x_in1;
b=x_in2;
N=length(x_in1);

% delete all zeros
% replace all _omega() --> _omega
% replace all _n --> _(m+1:N)
% replace all _i --> _1i
% replace all _./ _../     
% replace all _.* _...*
% replace all _.^  _...^

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
                A1(:,count*count1*count2*(countm + 1)) = at.*(abs(abs(at) + abs(bt))).^(count1-1).*((a_d).^((count - 1)));% + In2_dt.*(abs(In2_dt)).^(count1 - 1)./((a_dt).^((count2 - 1)));
                A2(:,count*count1*count2*(countm + 1)) = bt.*(abs(abs(at) + abs(bt))).^(count1-1).*((a_d).^((count - 1)));% + In2_d.*(abs(In2_d)).^(count1 - 1).*(abs(In1_d)).^(count2 - 1);
            end
        
        end    
    end
end

% x_in1=x_in1(1+(d-1)*m:N);
% y_out1=y_out1(1+(d-1)*m:N);
% x_in2=x_in2(1+(d-1)*m:N);
% y_out2=y_out2(1+(d-1)*m:N);
% a_coef = (pinv(A, eps) * [y_out1; y_out2]); % Solution of matrix equation-->model
size(A1)
size(y_out1)
a_coef1 = (pinv(A1, eps) * [y_out1]); 
a_coef2 = (pinv(A2, eps) * [y_out2]); 

% size(A)
% Cond_A=cond(A)
% Cond_AA=cond(A'*A)

a_coef1
length(a_coef1)
a_coef2
length(a_coef2)


%% Validation

% maxindex_In = 6.6e4/4;
% Traning_data = (maxindex_In - traning_data_length/2):(maxindex_In + traning_data_length/2)
% 
% x_in1=(I1_inpa(Traning_data)+1i*Q1_inpa(Traning_data));
% x_in2=(I2_inpa(Traning_data)+1i*Q2_inpa(Traning_data));
% y_out1=(I2_outpa(Traning_data)+1i*Q2_outpa(Traning_data));
% y_out2=(I3_outpa(Traning_data)+1i*Q3_outpa(Traning_data));

% Data format
x_in1=(I1_inpa+1i*Q1_inpa);
x_in2=(I2_inpa+1i*Q2_inpa);
y_out1=(I2_outpa+1i*Q2_outpa);
y_out2=(I3_outpa+1i*Q3_outpa);

%% Model identification

a=x_in1;
b=x_in2;
N=length(x_in1);

% delete all zeros
% replace all _omega() --> _omega
% replace all _n --> _(m+1:N)
% replace all _i --> _1i
% replace all _./ _../     
% replace all _.* _...*
% replace all _.^  _...^

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

%                 Av1(:,count*count1*count2*(countm + 1)) = at.*(abs(at)).^(count1 - count2 - 1).*(abs(bt)+abs(at)).^(count2 - 1).*((a_d).^((count - 1)));% + In2_dt.*(abs(In2_dt)).^(count1 - 1)./((a_dt).^((count2 - 1)));
%                 Av2(:,count*count1*count2*(countm + 1)) = bt.*(abs(bt)).^(count1 - count2 - 1).*(abs(at)+abs(bt)).^(count2 - 1).*((a_d).^((count - 1)));% + In2_d.*(abs(In2_d)).^(count1 - 1).*(abs(In1_d)).^(count2 - 1);

% % % Version 1 
%                 Av1(:,count*count1*count2*(countm + 1)) = at.*(abs(at)).^(count1 - count2 - 1).*(abs(bt)).^(count2 - 1).*((a_d).^((count - 1)));% + In2_dt.*(abs(In2_dt)).^(count1 - 1)./((a_dt).^((count2 - 1)));
%                 Av2(:,count*count1*count2*(countm + 1)) = bt.*(abs(bt)).^(count1 - count2 - 1).*(abs(at)).^(count2 - 1).*((a_d).^((count - 1)));% + In2_d.*(abs(In2_d)).^(count1 - 1).*(abs(In1_d)).^(count2 - 1);

% % % Version 2 
                Av1(:,count*count1*count2*(countm + 1)) = at.*(abs(abs(at) + abs(bt))).^(count1-1).*((a_d).^((count - 1)));
                Av2(:,count*count1*count2*(countm + 1)) = bt.*(abs(abs(at) + abs(bt))).^(count1-1).*((a_d).^((count - 1)));                
            end
        
        end    
    end
end

y_model1=(Av1 * a_coef1);
y_model2=(Av2 * a_coef2);


%% Validation



V1_in    = x_in1; %(1+(d-1)*m:end)     ;
V2_in    = x_in2; %(1+(d-1)*m:end)   ;
V2_out   = y_out1; %(1+(d-1)*m:end)   ;
V3_out   = y_out2; %(1+(d-1)*m:end)    ;
V2_outNN = y_model1;
V3_outNN = y_model2;
r1_in    = abs(V1_in)   ; t1_in    = angle(V1_in)   ;
r2_in    = abs(V2_in)   ; t2_in    = angle(V2_in)   ;
r2_out   = abs(V2_out)  ; t2_out   = angle(V2_out)  ;
r3_out   = abs(V3_out)  ; t3_out   = angle(V3_out)  ;
r2_outNN = abs(V2_outNN); t2_outNN = angle(V2_outNN);
r3_outNN = abs(V3_outNN); t3_outNN = angle(V3_outNN);

figure(12)
    hold on
        Fs    = 3.87e6      ;
        h    = spectrum.welch            ;
        h.OverlapPercent = 90            ;
        h.SegmentLength  = 2048         ;
        h.windowName  = 'Flat Top'       ;
        PSDMeasurement = plot(msspectrum(h,V2_out ,'centerdc',Fs))            ;

        PSDModel = plot(msspectrum(h,V2_outNN,'centerdc',Fs))                   ;
                   set(PSDModel,'Color','red');
        legend('PSD Measurement','PSD Model',2);

	hold off

figure(13)
    hold on
        Fs    = 3.87e6      ;
        h    = spectrum.welch            ;
        h.OverlapPercent = 90            ;
        h.SegmentLength  = 2048          ;
        h.windowName  = 'Flat Top'       ;
        PSDMeasurement = plot(msspectrum(h,V3_out ,'centerdc',Fs))            ;

        PSDModel = plot(msspectrum(h,V3_outNN,'centerdc',Fs))                   ;
                   set(PSDModel,'Color','red');
        legend('PSD Measurement','PSD Model','PSD error',2);

	hold off
    
%% NMSE
NMSE_error_abs1 = 10*log10(mean(((abs(V2_out-V2_outNN).^2)/mean(abs(V2_out)).^2))) 
NMSE_pha1 = 10*log10(mean(((angle(V2_out)-angle(V2_outNN)).^2/mean(angle(V2_out).^2)))) 
% NMSE1_I_and_Q = 0.5*(                                                           ...
%                      10*log10(mean(((I2_outpa-I2_outpaNN)/mean(abs(I2_outpa))).^2)) + ...
%                      10*log10(mean(((Q2_outpa-Q2_outpaNN)/mean(abs(Q2_outpa))).^2))   ...
%                     )
                
NMSE_error_abs2 = 10*log10(mean(((abs(V3_out-V3_outNN).^2)/mean(abs(V3_out)).^2))) 
NMSE_pha2 = 10*log10(mean(((angle(V3_out)-angle(V3_outNN)).^2/mean(angle(V3_out).^2))))        
% NMSE2_I_and_Q = 0.5*(                                                           ...
%                      10*log10(mean(((I3_outpa-I3_outpaNN)/mean(abs(I3_outpa))).^2)) + ...
%                      10*log10(mean(((Q3_outpa-Q3_outpaNN)/mean(abs(Q3_outpa))).^2))   ...
%                     )

%% AM/AM
figure(22)
   Title('AM/AM Distortion');
    hold on
        plot(10*log10(r1_in.^2/100)+30,10*log10(r2_out.^2./r1_in.^2),'.' )  ;
        plot(10*log10(r1_in.^2/100)+30,10*log10(r2_outNN.^2./r1_in.^2),'ro');
        plot(10*log10(r1_in.^2/100)+30,10*log10(r1_in.^2./r1_in.^2) ,'g' )  ;
        legend('AM/AM Measurement','AM/AM Model',2)                   ;
    hold off
figure(23)
   Title('AM/AM Distortion');
    hold on
        plot(10*log10(r2_in.^2/100)+30,10*log10(r3_out.^2./r2_in.^2),'.' )  ;
        plot(10*log10(r2_in.^2/100)+30,10*log10(r3_outNN.^2./r2_in.^2),'ro');
        plot(10*log10(r2_in.^2/100)+30,10*log10(r2_in.^2./r2_in.^2) ,'g' )  ;
        legend('AM/AM Measurement','AM/AM Model',2)                   ;
    hold off
    
%% AM/PM
figure(32)
    Title('AM/PM Distortion');
    do  = t2_out-t1_in;
    dNN = t2_outNN-t1_in;
    for i=1:length(do)
        if do(i) > pi
            do(i) = do(i) - 2*pi;
        elseif do(i) < -pi
            do(i) = do(i) + 2*pi;
        end
        if dNN(i) > pi
            dNN(i) = dNN(i) - 2*pi;
        elseif dNN(i) < -pi
            dNN(i) = dNN(i) + 2*pi;
        end
    end
    hold on
        plot(10*log10(r1_in.^2/100)+30 ,do*180/pi  ,'.');
        plot(10*log10(r1_in.^2/100)+30 ,dNN*180/pi,'ro');
        legend('AM/PM Measurement','AM/PM Model',2)   ;        
    hold off
    
    figure(33)
    Title('AM/PM Distortion');
    do  = t3_out-t2_in;
    dNN = t3_outNN-t2_in;
    for i=1:length(do)
        if do(i) > pi
            do(i) = do(i) - 2*pi;
        elseif do(i) < -pi
            do(i) = do(i) + 2*pi;
        end
        if dNN(i) > pi
            dNN(i) = dNN(i) - 2*pi;
        elseif dNN(i) < -pi
            dNN(i) = dNN(i) + 2*pi;
        end
    end
    hold on
        plot(10*log10(r2_in.^2/100)+30 ,do*180/pi  ,'.');
        plot(10*log10(r2_in.^2/100)+30 ,dNN*180/pi,'ro');
        legend('AM/PM Measurement','AM/PM Model',2)   ;        
    hold off
    
%% Validation for combined signal




                  