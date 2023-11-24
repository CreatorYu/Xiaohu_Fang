function [In_I_finetimedelay, In_Q_finetimedelay] = FineTimeDelay_Adjust(In_I, In_Q, FsampleTx, FineTimedelay)

%% Time delay resolution is 0.1 ns
Fsample_target = FsampleTx*100;

[DownSample, UpSample] = rat(FsampleTx/Fsample_target);

In_I_resmaple = resample(In_I,UpSample,DownSample);
In_Q_resmaple = resample(In_Q,UpSample,DownSample);

nr_shift = round(FineTimedelay*Fsample_target);

In_I_resmaple = circshift(In_I_resmaple, nr_shift);
In_Q_resmaple = circshift(In_Q_resmaple, nr_shift);

In_I_finetimedelay = resample(In_I_resmaple,DownSample,UpSample);
In_Q_finetimedelay = resample(In_Q_resmaple,DownSample,UpSample);

end    