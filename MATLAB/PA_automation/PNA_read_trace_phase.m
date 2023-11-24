function PNA_data = PNA_read_trace_phase(traceID,  PNA_obj)

if nargin == 2
    data_type = 'others';
end

switch data_type
    case {'dBm' 'dB'}
      tmpData = PNA_obj.Measurements.Item(traceID).Trace.Measurement.getData(2,2);
      tmpData = cell2mat(tmpData);
      PNA_data= 20 * log10(tmpData);
    case ('others')
      tmpData = PNA_obj.Measurements.Item(traceID).Trace.Measurement.getData(2,2);
      PNA_data = cell2mat(tmpData);
end
        
      
end