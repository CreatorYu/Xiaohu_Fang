function [results] = PA_results_capture_no_PAE(traceIndexArray, PNA_obj)
    results.Pin        = PNA_read_trace(traceIndexArray(1), PNA_obj, 'dBm');
    results.Pout       = PNA_read_trace(traceIndexArray(2), PNA_obj, 'dBm');
    results.AMAM       = PNA_read_trace(traceIndexArray(3), PNA_obj, 'dBm');
    results.AMPM       = PNA_read_trace(traceIndexArray(4), PNA_obj, 'dBm');
  
    results.Pin        = double(results.Pin(2:end));
    results.Pout       = double(results.Pout(2:end));
    results.AMAM       = double(results.AMAM(2:end));
    results.AMPM       = double(results.AMPM(2:end));
    
end