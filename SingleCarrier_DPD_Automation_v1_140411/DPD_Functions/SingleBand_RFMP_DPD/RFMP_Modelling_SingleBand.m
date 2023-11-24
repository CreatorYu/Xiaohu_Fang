function [results_vector] = RFMP_Modelling_SingleBand(RFMP_modelParam, selectIndex)
global NofDPDPoints Fs
%% Initialization

% keeps track of simulation time
tic;
timeTaken = 0;
totalTime = 0;

% Increase upsampling to improve predistortion, but simulation takes longer
upsample_rate = 1;

% Load relevant files
addpath(genpath('C:/Users/a5islam/Dropbox/Shared_Anik/TEMP_Update'));    

% reference the signal path
addpath(genpath('C:/Users/a5islam/Dropbox/Shared_Anik/Testbench_IQ_Files'));

%% Loading Files

[InI, InQ, OutI, OutQ] = signalSelect(selectIndex);

timeTaken = toc;
totalTime = totalTime + timeTaken;
    
%% Reading Files
tic;
display(' ')
display('Loading Data Files...')

% input to PA
InI = dlmread(InI, '\t');
InI = InI(:, 1);
InQ = dlmread(InQ, '\t');
InQ = InQ(:, 1);

% Output corresponding to input    
OutI= dlmread(OutI, '\t');
OutI = OutI(:, 1);
OutQ= dlmread(OutQ, '\t');
OutQ = OutQ(:, 1);
 
timeTaken = toc
totalTime = totalTime + timeTaken;

%% Generating PD Model
tic;

display(' ')
display('Generating PD Model...')

%Set the Power to 0 dBm for both input and output
[InI, InQ] = setMeanPower(InI, InQ, 0);
[OutI, OutQ] = setMeanPower(OutI, OutQ, 0);

[InI, InQ, OutI, OutQ] = UnifyLength(InI, InQ, OutI, OutQ, max(length(InI),length(OutI)) - 200);

all_x = complex(InI, InQ);
all_y = complex(OutI, OutQ);

% Resample data to improve memory polynomial performance
all_x = resample(all_x,upsample_rate,1);
all_y = resample(all_y,upsample_rate,1);

% Synchronize and normalize the input and output signals
[da_xI, da_xQ, da_yI, da_yQ, td] = AdjustDelay(real(all_x), imag(all_x), real(all_y), imag(all_y),Fs,2000);
[da_xI, da_xQ, da_yI, da_yQ,] = AdjustPowerAndPhase(da_xI, da_xQ, da_yI, da_yQ, 0);

all_x = complex(da_xI, da_xQ);
all_y = complex(da_yI, da_yQ);

params.MaxFunEval = 40000;
params.MaxIter = 40000;
params.TolFun = 1e-6;

if RFMP_modelParam.useNL == 0
[num_coeff, den_coeff, NMSE, Cond_A, real_zeros, imag_zeros, comp_zeros] = ...
    Identify_SingleBand_RFMP(RFMP_modelParam, real(all_x), imag(all_x), real(all_y), imag(all_y), NofDPDPoints);
elseif RFMP_modelParam.useNL == 1    
[num_coeff, den_coeff, NMSE, real_zeros, imag_zeros, comp_zeros] = ...
    Identify_SingleBand_RFMP_NL(RFMP_modelParam, real(all_x), imag(all_x), real(all_y), imag(all_y), NofDPDPoints, params);
end

[PDout_Imodel, PDout_Qmodel, comp_numout, comp_denout] = Apply_SingleBand_RFMP(real(all_y), imag(all_y), RFMP_modelParam, num_coeff, den_coeff, real_zeros, imag_zeros, comp_zeros);	
coefficients = [num_coeff;den_coeff];

offset = length(all_y)-length(PDout_Imodel);
PDout_model = complex(PDout_Imodel, PDout_Qmodel);	
PDout = all_x(offset+1:end);
y_shift = all_y(offset+1:end);

timeTaken = toc;
totalTime = totalTime + timeTaken;

%% Testing PD Model

tic;
display(' ')
display('Testing PD Model...')
display(' ')
display('Modelling error: ')

I_DR = 20*log10(max(abs(real(coefficients)))/min(abs(real(coefficients))))
Q_DR = 20*log10(max(abs(imag(coefficients)))/min(abs(imag(coefficients))))
APPLIED_NMSE_ALLPOINTS = ModelCheck(y_shift, PDout, PDout_model)

timeTaken = toc;
totalTime = totalTime + timeTaken;



if strcmp(RFMP_modelParam.BASIS,'RFMP_ADRF')
    % power level for zeros
%     set(0, 'currentfigure', 8);
    pwr_rz = 10*log10(((real_zeros).^2)./100)+30;
    pwr_iz = 10*log10(((imag_zeros).^2)./100)+30;
    AMAM = subplot(3,1,1);
    hold on
        % mark real zeros on AM/AM
        for ind=1:length(pwr_rz)
            rp = pwr_rz(ind);
            line([rp rp],get(AMAM,'YLim'),'Color',[0 0 0],'LineStyle','-.');
        end
        
        % mark imag zeros on AM/AM
        for ind=1:length(pwr_iz)
            ip = pwr_iz(ind);
            line([ip ip],get(AMAM,'YLim'),'Color',[1 0 1],'LineStyle','-.');
        end

    AMPM = subplot(3,1,2);
        % mark real zeros on AM/PM
        for ind=1:length(pwr_rz)
            rp = pwr_rz(ind);
            line([rp rp],get(AMPM,'YLim'),'Color',[0 0 0],'LineStyle','-.');
        end
        
        % mark imag zeros on AM/PM
        for ind=1:length(pwr_iz)
            ip = pwr_iz(ind);
            line([ip ip],get(AMPM,'YLim'),'Color',[1 0 1],'LineStyle','-.');
        end

    hold off
end

grid on    
figure( )
hold on

% overlay the numerator and the 1/denominator to see how similar they are
plot( 10 * log10( abs(y_shift) .^ 2 / 100 ) + 30 , ...
20 * log10( abs( comp_numout ) ./ abs(y_shift))  , 'rd' );
title(  'AM/AM Distortion' , 'FontSize' , 20 ) ;
xlabel( 'Pin (dBm)'        , 'FontSize' , 15 ) ;
ylabel( 'Pout./Pin (dB)'   , 'FontSize' , 15 ) ;

plot( 10 * log10( abs(y_shift) .^ 2 / 100 ) + 30 , ...
20 * log10( abs( comp_denout ))  , 'b.' );
hold off

results_vector = [NMSE, APPLIED_NMSE_ALLPOINTS, I_DR, Q_DR, length(coefficients)];

end