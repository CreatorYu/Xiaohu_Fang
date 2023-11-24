function setPowerSweep(PNA_obj, cwFreq, startPow, stopPow, numOfPoints, ifBandwidth)

if stopPow >20  % for pre-caution
    return;
end

PNA_obj.Channels.Item(1).SweepType        = 2; % power sweep
PNA_obj.Channels.Item(1).CWFrequency      = cwFreq;
PNA_obj.Channels.Item(1).StartPower       = startPow;
PNA_obj.Channels.Item(1).StopPower        = stopPow;
PNA_obj.Channels.Item(1).NumberOfPoints   = numOfPoints;
PNA_obj.Channels.Item(1).IFBandwidth      = ifBandwidth;

end