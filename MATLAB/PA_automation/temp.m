cwFreqArray = 55e9:1e9:66e9;
for ind = 1 : length(cwFreqArray)
    setPowerSweep(PNA_obj, cwFreqArray(ind), startPow, stopPow, numOfPoints, ifBandwidth);
    %PNA_obj.Channels.Item(1).Single
    pause(1)
    PA_Results(ind) = PA_results_capture(traceIndexArray, PNA_obj);
    pause(1)
end
