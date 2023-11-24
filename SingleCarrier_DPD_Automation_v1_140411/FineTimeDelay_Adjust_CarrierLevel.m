function [y] = FineTimeDelay_Adjust_CarrierLevel(x, FsampleTx, FineTimedelay)

%% Time delay resolution is 10 ps

Fsample_target = FsampleTx*25; % Fsample = 200 G, 5 ps resolution
[DownSample, UpSample] = rat(FsampleTx/Fsample_target);
x = resample(x,UpSample,DownSample);
nr_shift = round(FineTimedelay*Fsample_target);
x = circshift(x, nr_shift);
y = resample(x,DownSample,UpSample);


end    