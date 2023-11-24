function [a, NMSE_error_abs]=Identify_RF_Volterra_ET(UinI0, UinQ0, UoutI0 , UoutQ0 , Vdd, RF_Volterra_Parameters , rec_srate, NbOfPoint )

% InI = 'I_in_Delay_Adjust_In_I_1001.txt';
% InQ = 'Q_in_Delay_Adjust_In_Q_1001.txt';
% OutI = 'I_out_Delay_Adjust_I_out_Delay_Adjust_Out_I_24output.txt';
% OutQ = 'Q_out_Delay_Adjust_Q_out_Delay_Adjust_Out_Q_24output.txt';

%external parameters
traning_data_length = NbOfPoint;%number of points used
m=RF_Volterra_Parameters.memory_lag;%=1; 
d=RF_Volterra_Parameters.embedding_dimension;%=3 ; 
M1=RF_Volterra_Parameters.M1;
M3=RF_Volterra_Parameters.M3;
M5=RF_Volterra_Parameters.M5;
NL=RF_Volterra_Parameters.NL;%=7 ; 
omega0=0; %RF_Volterra_Parameters.carrier_frequency;%=2*pi*2.14e9;

Ns = RF_Volterra_Parameters.NSupply;%=3 ; 

%internal parameters
upsamp=1;
downsamp=1;
% fs=168.96e6*upsamp/downsamp;
%N_after_DPD=5.5*30720-100;%length of the predistorted signal to be generated
fs=rec_srate;
Ts=1/fs;
% model='MP';
% model='SysVolterra';
% model='RecursiveVolterra';
model='NonRecursiveVolterra';
Validation= 'same data';
% Validation= 'another data';
% task = 'modeling';%uncomment this line if modeling
task = 'DPD';%comment this line if modeling

%% Process  data

%invert input and ouptut as we are shearching DPD nonlinear order
if strcmp(task, 'DPD')
    temp=UoutI0;
    UoutI0=UinI0;
    UinI0=temp;
    temp=UoutQ0;
    UoutQ0=UinQ0;
    UinQ0=temp;
end

avg_in=10*log10(mean((abs(UinI0 + 1j * UinQ0)).^2)/100)+30;
avg_out=10*log10(mean((abs(UoutI0 + 1j * UoutQ0)).^2)/100)+30;
Offset_in=10^((-avg_in)/20); 
Offset_out=10^((-avg_out)/20); 

UinI0=UinI0*Offset_in;
UinQ0=UinQ0*Offset_in;
UoutI0=UoutI0*Offset_out;
UoutQ0=UoutQ0*Offset_out;


% peak_out=10*log10(max((abs(OutIf + 1j * OutQf)).^2)/100)+30;
% Offset_out=10^((-peak_out)/20); %Peak out is 0 dBm
% Offset_in=10^((-avg_in+avg_out-peak_out)/20); % in avg is the same now as
% out avg

Mag_in=abs(UinI0 + 1j * UinQ0);
Mag_out=abs(UoutI0 + 1j * UoutQ0);
avg_in=10*log10((mean(Mag_in).^2)/100)+30
peak_in=10*log10((max(Mag_in).^2)/100)+30
PAPR_in=peak_in-avg_in
avg_out=10*log10((mean(Mag_out).^2)/100)+30
peak_out=10*log10((max(Mag_out).^2)/100)+30
PAPR_out=peak_out-avg_out

Mag_in_dBm=10*log10(((Mag_in).^2)/100)+30;
Mag_out_dBm=10*log10(((Mag_out).^2)/100)+30;


maxindex=find(abs(complex(UinI0,UinQ0))>=max(abs(complex(UinI0,UinQ0))))
if maxindex <(length(UinI0)-traning_data_length/2) && maxindex >(traning_data_length/2)
    UinI0 = UinI0(maxindex-traning_data_length/2:maxindex+traning_data_length/2);
    UinQ0 = UinQ0(maxindex-traning_data_length/2:maxindex+traning_data_length/2);
    UoutI0 = UoutI0(maxindex-traning_data_length/2:maxindex+traning_data_length/2);
    UoutQ0 = UoutQ0(maxindex-traning_data_length/2:maxindex+traning_data_length/2);
    
    Vdd = Vdd(maxindex-traning_data_length/2:maxindex+traning_data_length/2);
    
elseif maxindex < traning_data_length/2
    UinI0 = UinI0(10:traning_data_length+10);
    UinQ0 = UinQ0(10:traning_data_length+10);
    UoutI0 = UoutI0(10:traning_data_length+10);
    UoutQ0 = UoutQ0(10:traning_data_length+10);

    Vdd = Vdd(10:traning_data_length+10);
        
else 
    UinI0 = UinI0(length(UinI0)-traning_data_length:length(UinI0));
    UinQ0 = UinQ0(length(UinI0)-traning_data_length:length(UinI0));
    UoutI0 = UoutI0(length(UinI0)-traning_data_length:length(UinI0));
    UoutQ0 = UoutQ0(length(UinI0)-traning_data_length:length(UinI0));

    Vdd = Vdd(length(UinI0)-traning_data_length:length(UinI0));
    
end


UinI0=resample(UinI0,upsamp,downsamp);
UinQ0=resample(UinQ0,upsamp,downsamp);
UoutI0=resample(UoutI0,upsamp,downsamp);
UoutQ0=resample(UoutQ0,upsamp,downsamp);

Vdd=resample(Vdd,upsamp,downsamp);

x_in=UinI0+1i*(UinQ0);
y_out=UoutI0+1i*(UoutQ0);

%phase synchronisation
Phaseout=angle(y_out)-angle(x_in);
Ind = Phaseout > pi;
Phaseout = Phaseout - 2*Ind*pi;
Ind = Phaseout < -pi;
Phaseout = Phaseout + 2*Ind*pi;

AvgPhaseout = mean(Phaseout);
y_out = y_out * exp(-1i*AvgPhaseout) ;
err = y_out - x_in ;
UoutI0=real(y_out); 
UoutQ0=imag(y_out);

N=length(x_in);

%% Non recursive Volterra
if strcmp(model, 'NonRecursiveVolterra')
    x=x_in;
    y=y_out;
    N=length(x);
    
%     M1 = 3;
%     M3 = 3;
%     M5 = 0;
    M = max(M1, max(M3,M5));
    start=1+M*m;

    
%     env = Vdd((M*m + 1 ): N);
    env = abs(x((M*m + 1 ): N));
    Ns = 1;

    % delete all 0
    % replace all _omega(0) --> _omega0
    % replace all _n --> _(m+1:N)
    % replace all _i --> _1i
    % replace all _/ _../     
    % replace all _* _...*
    % replace all _^  _...^    
    
    for count = 1:Ns    
        
    At= Construct_Volterra_SISO_model_matrix (x,start,m,N,M1,M3,M5);
   
    size_At = size(At)
    size(env) ;
    
    A(:,1+(count-1)*size(At,2):count*size(At,2))=At.*repmat(((env).^(1*(count-1))),1,size(At,2));

    end
    
    size_A=size(A)
    Cond_A=cond(A)
    Cond_AA=cond(A'*A)

    x_in=x_in(1+M*m:N);
    y_out=y_out(1+M*m:N);
    size(x_in)
    size(y_out)
    
    
%        eps=1e-026
    a = (pinv(A, eps) * y_out); 
%     a = (pinv(A) * y_out);
%     a = (pinv(A, TOL) * y_out);
    eps_value=eps

%     a
    
%     figure();
%     plot(1:length(a), angle(a)/pi*180);
%     title('Phase of the model coeff in degree')

    if strcmp(Validation, 'same data') %Validation with the same data set
    y_model = (A * a).';      % Calculation of modelled values
    y_model=y_model.';
    elseif strcmp(model, 'another data')%Validation with different set of data
    end

end



%% RecursiveVolterra
if strcmp(model, 'RecursiveVolterra')
    x=x_in;
    y=y_out;

    % delete all 0
    % replace all _omega(0) --> _omega0
    % replace all _n --> _(m+1:N)
    % replace all _i --> _1i
    % replace all _/ _../     
    % replace all _* _...*
    % replace all _^  _...^

    %d=2 recursive till order 3  Volterra order 5 --> 
%     A = [x((m+1:N)) ./ 0.2e1 x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 0.2e1 y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 0.2e1 (0.3e1 ./ 0.8e1) .* conj(x((m+1:N))) .* (x((m+1:N)) .^ 2) (x((m+1:N)) .^ 2) .* conj(x((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 + conj(x((m+1:N))) .* x((m+1:N)) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 conj(x((m+1:N))) .* (x((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) ./ 8 + x((m+1:N)) .* conj(x((m+1:N) - m)) .* x((m+1:N) - m) ./ 4 (0.3e1 ./ 0.8e1) .* conj(x((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (x((m+1:N) - m) .^ 2) (x((m+1:N)) .^ 2) .* conj(y((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 + conj(x((m+1:N))) .* x((m+1:N)) .* y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 x((m+1:N)) .* x((m+1:N) - m) .* conj(y((m+1:N) - m)) ./ 8 + conj(x((m+1:N))) .* x((m+1:N) - m) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* y((m+1:N) - m) ./ 8 + x((m+1:N)) .* conj(x((m+1:N) - m)) .* y((m+1:N) - m) ./ 8 (x((m+1:N) - m) .^ 2) .* exp(1i .* omega0 .* Ts .* m) .* conj(y((m+1:N) - m)) ./ 8 + conj(x((m+1:N) - m)) .* x((m+1:N) - m) .* y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 conj(y((m+1:N) - m)) .* y((m+1:N) - m) .* x((m+1:N)) ./ 4 + (y((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* conj(x((m+1:N))) ./ 8 conj(y((m+1:N) - m)) .* y((m+1:N) - m) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 + (y((m+1:N) - m) .^ 2) .* exp(1i .* omega0 .* Ts .* m) .* conj(x((m+1:N) - m)) ./ 8 (0.3e1 ./ 0.8e1) .* conj(y((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (y((m+1:N) - m) .^ 2) (0.5e1 ./ 0.16e2) .* conj(x((m+1:N))) .^ 2 .* (x((m+1:N)) .^ 3) (0.3e1 ./ 0.16e2) .* conj(x((m+1:N))) .^ 2 .* (x((m+1:N)) .^ 2) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) + conj(x((m+1:N))) .* (x((m+1:N)) .^ 3) .* conj(x((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 (x((m+1:N)) .^ 3) .* conj(x((m+1:N) - m)) .^ 2 ./ (exp(1i .* omega0 .* Ts .* m) .^ 2) ./ 32 + (0.3e1 ./ 0.32e2) .* conj(x((m+1:N))) .^ 2 .* x((m+1:N)) .* (x((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) + (0.3e1 ./ 0.16e2) .* conj(x((m+1:N))) .* (x((m+1:N)) .^ 2) .* conj(x((m+1:N) - m)) .* x((m+1:N) - m) conj(x((m+1:N))) .^ 2 .* (x((m+1:N) - m) .^ 3) .* (exp(1i .* omega0 .* Ts .* m) .^ 3) ./ 32 + (0.3e1 ./ 0.16e2) .* conj(x((m+1:N))) .* x((m+1:N)) .* conj(x((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (x((m+1:N) - m) .^ 2) + (0.3e1 ./ 0.32e2) .* (x((m+1:N)) .^ 2) .* conj(x((m+1:N) - m)) .^ 2 ./ exp(1i .* omega0 .* Ts .* m) .* x((m+1:N) - m) conj(x((m+1:N))) .* conj(x((m+1:N) - m)) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* (x((m+1:N) - m) .^ 3) ./ 8 + (0.3e1 ./ 0.16e2) .* x((m+1:N)) .* conj(x((m+1:N) - m)) .^ 2 .* (x((m+1:N) - m) .^ 2) (0.5e1 ./ 0.16e2) .* conj(x((m+1:N) - m)) .^ 2 .* exp(1i .* omega0 .* Ts .* m) .* (x((m+1:N) - m) .^ 3)];

    %d=2 recursive till order 3  Volterra order 3  
%     A = [x((m+1:N)) ./ 0.2e1 x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 0.2e1 y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 0.2e1 (0.3e1 ./ 0.8e1) .* conj(x((m+1:N))) .* (x((m+1:N)) .^ 2) (x((m+1:N)) .^ 2) .* conj(x((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 + conj(x((m+1:N))) .* x((m+1:N)) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 conj(x((m+1:N))) .* (x((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) ./ 8 + x((m+1:N)) .* conj(x((m+1:N) - m)) .* x((m+1:N) - m) ./ 4 (0.3e1 ./ 0.8e1) .* conj(x((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (x((m+1:N) - m) .^ 2) (x((m+1:N)) .^ 2) .* conj(y((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 + conj(x((m+1:N))) .* x((m+1:N)) .* y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 x((m+1:N)) .* conj(x((m+1:N) - m)) .* y((m+1:N) - m) ./ 8 + x((m+1:N)) .* x((m+1:N) - m) .* conj(y((m+1:N) - m)) ./ 8 + conj(x((m+1:N))) .* x((m+1:N) - m) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* y((m+1:N) - m) ./ 8 (x((m+1:N) - m) .^ 2) .* exp(1i .* omega0 .* Ts .* m) .* conj(y((m+1:N) - m)) ./ 8 + conj(x((m+1:N) - m)) .* x((m+1:N) - m) .* y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 conj(y((m+1:N) - m)) .* y((m+1:N) - m) .* x((m+1:N)) ./ 4 + (y((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* conj(x((m+1:N))) ./ 8 (y((m+1:N) - m) .^ 2) .* exp(1i .* omega0 .* Ts .* m) .* conj(x((m+1:N) - m)) ./ 8 + conj(y((m+1:N) - m)) .* y((m+1:N) - m) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 (0.3e1 ./ 0.8e1) .* conj(y((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (y((m+1:N) - m) .^ 2)];
    
    % m=2 d=3 recursive till order 3  Volterra order 5
%     A = [x((m+1:N)) ./ .2e1 x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ .2e1 y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ .2e1 (.3e1 ./ .8e1) .* conj(x((m+1:N))) .* (x((m+1:N)) .^ 2) (x((m+1:N)) .^ 2) .* conj(x((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 + conj(x((m+1:N))) .* x((m+1:N)) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 conj(x((m+1:N))) .* (x((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) ./ 8 + x((m+1:N)) .* conj(x((m+1:N) - m)) .* x((m+1:N) - m) ./ 4 (.3e1 ./ .8e1) .* conj(x((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (x((m+1:N) - m) .^ 2) (x((m+1:N)) .^ 2) .* conj(y((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 + conj(x((m+1:N))) .* x((m+1:N)) .* y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 x((m+1:N)) .* conj(x((m+1:N) - m)) .* y((m+1:N) - m) ./ 8 + x((m+1:N)) .* x((m+1:N) - m) .* conj(y((m+1:N) - m)) ./ 8 + conj(x((m+1:N))) .* x((m+1:N) - m) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* y((m+1:N) - m) ./ 8 (x((m+1:N) - m) .^ 2) .* exp(1i .* omega0 .* Ts .* m) .* conj(y((m+1:N) - m)) ./ 8 + conj(x((m+1:N) - m)) .* x((m+1:N) - m) .* y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 conj(y((m+1:N) - m)) .* y((m+1:N) - m) .* x((m+1:N)) ./ 4 + (y((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* conj(x((m+1:N))) ./ 8 (y((m+1:N) - m) .^ 2) .* exp(1i .* omega0 .* Ts .* m) .* conj(x((m+1:N) - m)) ./ 8 + conj(y((m+1:N) - m)) .* y((m+1:N) - m) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 (.3e1 ./ .8e1) .* conj(y((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (y((m+1:N) - m) .^ 2) (.5e1 ./ .16e2) .* conj(x((m+1:N))) .^ 2 .* (x((m+1:N)) .^ 3) (.3e1 ./ .16e2) .* conj(x((m+1:N))) .^ 2 .* (x((m+1:N)) .^ 2) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) + conj(x((m+1:N))) .* (x((m+1:N)) .^ 3) .* conj(x((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 (x((m+1:N)) .^ 3) .* conj(x((m+1:N) - m)) .^ 2 ./ (exp(1i .* omega0 .* Ts .* m) .^ 2) ./ 32 + (.3e1 ./ .16e2) .* conj(x((m+1:N))) .* (x((m+1:N)) .^ 2) .* conj(x((m+1:N) - m)) .* x((m+1:N) - m) + (.3e1 ./ .32e2) .* conj(x((m+1:N))) .^ 2 .* x((m+1:N)) .* (x((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) conj(x((m+1:N))) .^ 2 .* (x((m+1:N) - m) .^ 3) .* (exp(1i .* omega0 .* Ts .* m) .^ 3) ./ 32 + (.3e1 ./ .16e2) .* conj(x((m+1:N))) .* x((m+1:N)) .* conj(x((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (x((m+1:N) - m) .^ 2) + (.3e1 ./ .32e2) .* (x((m+1:N)) .^ 2) .* conj(x((m+1:N) - m)) .^ 2 ./ exp(1i .* omega0 .* Ts .* m) .* x((m+1:N) - m) (.3e1 ./ .16e2) .* x((m+1:N)) .* conj(x((m+1:N) - m)) .^ 2 .* (x((m+1:N) - m) .^ 2) + conj(x((m+1:N))) .* conj(x((m+1:N) - m)) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* (x((m+1:N) - m) .^ 3) ./ 8 (.5e1 ./ .16e2) .* conj(x((m+1:N) - m)) .^ 2 .* exp(1i .* omega0 .* Ts .* m) .* (x((m+1:N) - m) .^ 3)];
    
    % d=3 recursive till order 3  Volterra order 5
%     A = [x((m+1:N)) ./ .2e1 x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ .2e1 y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ .2e1 (.3e1 ./ .8e1) .* conj(x((m+1:N))) .* (x((m+1:N)) .^ 2) (x((m+1:N)) .^ 2) .* conj(x((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 + conj(x((m+1:N))) .* x((m+1:N)) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 conj(x((m+1:N))) .* (x((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) ./ 8 + x((m+1:N)) .* conj(x((m+1:N) - m)) .* x((m+1:N) - m) ./ 4 (.3e1 ./ .8e1) .* conj(x((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (x((m+1:N) - m) .^ 2) (x((m+1:N)) .^ 2) .* conj(y((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 + conj(x((m+1:N))) .* x((m+1:N)) .* y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 x((m+1:N)) .* conj(x((m+1:N) - m)) .* y((m+1:N) - m) ./ 8 + x((m+1:N)) .* x((m+1:N) - m) .* conj(y((m+1:N) - m)) ./ 8 + conj(x((m+1:N))) .* x((m+1:N) - m) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* y((m+1:N) - m) ./ 8 (x((m+1:N) - m) .^ 2) .* exp(1i .* omega0 .* Ts .* m) .* conj(y((m+1:N) - m)) ./ 8 + conj(x((m+1:N) - m)) .* x((m+1:N) - m) .* y((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 conj(y((m+1:N) - m)) .* y((m+1:N) - m) .* x((m+1:N)) ./ 4 + (y((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* conj(x((m+1:N))) ./ 8 (y((m+1:N) - m) .^ 2) .* exp(1i .* omega0 .* Ts .* m) .* conj(x((m+1:N) - m)) ./ 8 + conj(y((m+1:N) - m)) .* y((m+1:N) - m) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) ./ 4 (.3e1 ./ .8e1) .* conj(y((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (y((m+1:N) - m) .^ 2) (.5e1 ./ .16e2) .* conj(x((m+1:N))) .^ 2 .* (x((m+1:N)) .^ 3) (.3e1 ./ .16e2) .* conj(x((m+1:N))) .^ 2 .* (x((m+1:N)) .^ 2) .* x((m+1:N) - m) .* exp(1i .* omega0 .* Ts .* m) + conj(x((m+1:N))) .* (x((m+1:N)) .^ 3) .* conj(x((m+1:N) - m)) ./ exp(1i .* omega0 .* Ts .* m) ./ 8 (x((m+1:N)) .^ 3) .* conj(x((m+1:N) - m)) .^ 2 ./ (exp(1i .* omega0 .* Ts .* m) .^ 2) ./ 32 + (.3e1 ./ .16e2) .* conj(x((m+1:N))) .* (x((m+1:N)) .^ 2) .* conj(x((m+1:N) - m)) .* x((m+1:N) - m) + (.3e1 ./ .32e2) .* conj(x((m+1:N))) .^ 2 .* x((m+1:N)) .* (x((m+1:N) - m) .^ 2) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) conj(x((m+1:N))) .^ 2 .* (x((m+1:N) - m) .^ 3) .* (exp(1i .* omega0 .* Ts .* m) .^ 3) ./ 32 + (.3e1 ./ .16e2) .* conj(x((m+1:N))) .* x((m+1:N)) .* conj(x((m+1:N) - m)) .* exp(1i .* omega0 .* Ts .* m) .* (x((m+1:N) - m) .^ 2) + (.3e1 ./ .32e2) .* (x((m+1:N)) .^ 2) .* conj(x((m+1:N) - m)) .^ 2 ./ exp(1i .* omega0 .* Ts .* m) .* x((m+1:N) - m) (.3e1 ./ .16e2) .* x((m+1:N)) .* conj(x((m+1:N) - m)) .^ 2 .* (x((m+1:N) - m) .^ 2) + conj(x((m+1:N))) .* conj(x((m+1:N) - m)) .* (exp(1i .* omega0 .* Ts .* m) .^ 2) .* (x((m+1:N) - m) .^ 3) ./ 8 (.5e1 ./ .16e2) .* conj(x((m+1:N) - m)) .^ 2 .* exp(1i .* omega0 .* Ts .* m) .* (x((m+1:N) - m) .^ 3)];
    
    size(A)
    cond(A)
    cond(A'*A)

    x_in=x_in(1+m:N);
    y_out=y_out(1+m:N);
    a = (pinv(A, eps) * y_out); % Solution of matrix equation-->model
    
    if strcmp(Validation, 'same data') %Validation with the same data set
    y_model = (A * a).';      % Calculation of modelled values
    y_model=y_model.';
    elseif strcmp(model, 'another data')%Validation with different set of data
    end

end


%% Plot figures

%NMSE
y_out=y_out(1:length(y_model));
x_in=x_in(1:length(y_model));

I_out_meas=real(y_out);
I_out_mod=real(y_model);
Q_out_meas=imag(y_out);
Q_out_mod=imag(y_model);

%NMSE_real = (
%10*log10(mean(((I_out_meas-I_out_mod).^2)/mean(abs(I_out_meas)))) )

NMSE_error_abs = 10*log10(mean(((abs(y_out-y_model).^2)/mean(abs(y_out)).^2))) 

NMSE_real = ( 10*log10(mean(((I_out_meas-I_out_mod).^2/mean(abs(I_out_meas))))) );

NMSE_imag = 10*log10(mean(((Q_out_meas-Q_out_mod).^2/mean(abs(Q_out_meas)))));

NMSE_mag = 10*log10(mean(((abs(y_out)-abs(y_model)).^2/mean(abs(I_out_meas).^2)))) 

NMSE_pha = 10*log10(mean(((angle(y_out)-angle(y_model)).^2/mean(angle(I_out_meas).^2)))) 
                  


%%%%%


% copy output signal based on Matlab Coefficients.
Uoutbar = y_model;
Uin = x_in(1:length(Uoutbar));
Uout = y_out(1:length(Uoutbar));

% figure(); plot(real(Uout),'.-'); hold on; grid on; plot(real(Uoutbar),'o-r'); hold on;
% t_title=title('real');
% set(t_title,'FontSize',14);
% h_legend=legend('Measured output','Modeled output');
% set(h_legend,'FontSize',14);

% figure();plot(imag(Uout),'.-'); hold on; grid on; plot(imag(Uoutbar),'o-r'); hold on;
% t_title=title('imag');
% set(t_title,'FontSize',14);
% h_legend=legend('Measured output','Modeled output');
% set(h_legend,'FontSize',14);

figure(103);plot(10*log10(abs(Uin).^2/100)+30, 20*log10(abs(Uout) ./ abs(Uin)),'.'); hold on; grid on; 
plot(10*log10(abs(Uin).^2/100)+30, 20*log10(abs(Uoutbar) ./ abs(Uin)),'or'); hold on; 
t_title=title('AMAM');
set(t_title,'FontSize',14);
h_legend=legend('Measured ','Modeled ');
set(h_legend,'FontSize',14);

% Phaseout = atan2(imag(Uout), real(Uout)) - atan2(imag(Uin), real(Uin));
% Ind = Phaseout > pi-pi/2;
% Phaseout = Phaseout - 2*Ind*pi;
% Ind = Phaseout < -pi-pi/2;
% Phaseout = Phaseout + 2*Ind*pi;
% PhasePl0 = atan2(imag(Uoutbar), real(Uoutbar)) - atan2(imag(Uin), real(Uin));
% Ind = PhasePl0 > pi-pi/2;
% PhasePl0 = PhasePl0 - 2*Ind*pi;
% Ind = PhasePl0 < -pi-pi/2;
% PhasePl0 = PhasePl0 + 2*Ind*pi;
% figure();
% plot(10*log10(abs(Uin).^2/100)+30, Phaseout .* (180/pi),'.'); hold on; grid on; plot(10*log10(abs(Uin).^2/100)+30, PhasePl0 .* (180/pi), 'or'); hold on;
% t_title=title('AMPM');
% set(t_title,'FontSize',14);
% h_legend=legend('Measured ','Modeled ');
% set(h_legend,'FontSize',14);


%%%%%%%%%%Spectrum

figure(104) 

hold on
    Fs    = fs             ;
    h     = spectrum.welch       ;
    h.OverlapPercent = 90        ;
    h.SegmentLength  = 4096      ;
    h.windowName     = 'Flat Top';
    PSD_Meas =plot(msspectrum(h,x_in,'centerdc',Fs));
    PSD_out=plot(msspectrum(h,y_out,'centerdc',Fs));
    PSD_mod=plot(msspectrum(h,y_model,'centerdc',Fs));
    set(PSD_out,'color','red');
    set(PSD_mod,'color','green');
    h_legend=legend('Measured input','Measured output','Modeled output');
    set(h_legend,'FontSize',14);

    h=title('Welch Mean-Square Spectrum Estimate');
    set(h, 'FontName', 'Helvetica','FontSize',14)

hold off
