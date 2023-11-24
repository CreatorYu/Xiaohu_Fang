function [errorcode, errorcode_description] = agt_awg_setstate(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% function [errorcode, errorcode_description] = agt_awg_setstate(handle,attrib,value,option)
%
% This function sets or updates the attributes.
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   handle                  integer     a handle to the instrument (see agt_awg_open)
%   'attrib'                string      selects the attribute to set
%   'value'                 varies      specifies the value to set
%   option                  integer     specifies one of the following.
%                                       - channel : 1 or 2.  If not specified, 
%                                                   both channels will be effected.   
%                                       - marker  : from 1 to 6.  If not
%                                                   specified, 1 will be used.
%													(5 and 6 are LXI only markers)
%                                       - trigger : 1 to 5.  If not
%                                                   specified, 1 will be used.
%													(5 is LXI only trigger)
%                                       
%
% Supported Attributes:
%   'opmode'
%       Allows user to toggle between continuous and burst mode.
%       Valid values are:
%           'cont' - enables the continuous mode.
%           'burst' - enables burst mode (external trigger required.)
%       
%
%   'burstcount'
%       Once in burst mode (see: 'opmode' attribute), allows user to enter
%       an integer number of bursts for the waveform.
%       Valid values are:
%           1 < X < ((2^20)-1)
%           where X is the integer number of bursts
%
%	'lxitrigsrc'
%		Set Lxi Trigger Source
%       Valid values are:
%				'LAN0'
%				'LAN1'
%				'LAN2'
%				'LAN3'
%				'LAN4'
%				'LAN5'
%				'LAN6'
%				'LAN7'
%				'LXI0'
%				'LXI1'
%				'LXI2'
%				'LXI3'
%				'LXI4'
%				'LXI5'
%				'LXI6'
%				'LXI7'
%				'EXT'
%
%   'outputmode'
%       Enables or disables the sequencer mode.  Default choice should be 'arb'.
%       Valid values are:
%           'arb' - waveform output in normal mode.
%           'seq' - enables the sequencer mode.
%           'adv_seq' - enables the advance sequencer mode.           
%                   Note:  Waveforms must be stored (see: agt_awg_storewaveform) 
%                          prior to enabling this mode.  Once enabled, 
%                          sequence may be:  created, stored, and played,
%                          (see: agt_awg_storesequence,
%                          agt_awg_playsequence).
%           
%   'start'
%       Set the Start trigger source.
%       Valid values are:
%           'none' -  do nothing, ignore a trigger
%           'sw1' - software trigger 1
%           'sw2' - software trigger 2
%           'sw3' - software trigger 3
%           'ext1' - external trigger 1 
%           'ext2' - external trigger 2
%           'ext3' - external trigger 3
%           'ext4' - external trigger 4
%           'mkr1' - marker trigger 1
%           'mkr2' - marker trigger 2
%           'mkr3' - marker trigger 3
%           'mkr4' - marker trigger 4
%           'aux'   - aux port trigger
%           'lxi1'  - lxi trigger
%           Users can set more than one source by using a string in which 
%           sources are separated by a comma.  No space allowed.
%       Example: atg_awg_setstate(1,'start','sw1,ext1');
%
%   'stop'
%       Set Stop trigger source
%       Valid values: see 'start' attribute.
%       
%   'hold'
%       Set Hold trigger source
%       Valid values: see 'start' attribute.
%      
%   'resume'
%       Set Resume trigger source
%       Valid values: see 'start' attribute.
%       
%   'wfmadv'
%       Set Waveform Advance trigger source.  Must set 'outputmode' to
%       adv_seq first.
%       Valid values: see 'start' attribute.
%       
%   'wfmjump'
%       Set Waveform Jump trigger source.  Must set 'outputmode' to
%       adv_seq first.
%       Valid values: see 'start' attribute.
%       
%   'scenariojump'
%       Set Scenario Jump trigger source.  Must set 'outputmode' to adv_seq
%       first.
%       Valid values: see 'start' attribute.
%       
%   'scenarioadv'
%       Set Scenario Advance trigger source.  Must set 'outputmode' to
%       adv_seq first.
%       Valid values: see 'start' attribute.
%
%   'syncenabled'
%       Enables or Disables the SYNC clock operation
%       Valid values are:
%           'true' - to enable the SYNC clock operation
%           'false'- to disable the SYNC clock operation
%
%   'syncoutenabled'
%       Enables or Disables the SYNC clock output
%       Valid values are:
%           'true' - to enable the SYNC clock output
%           'false'- to disable the SYNC clock output
%
%   'syncmode'
%       Selects the mode of operation, when the SYNC clock is enabled
%           'master' - sets the unit to be the master SYNC clock source.
%           'slave'  - sets the unit to be the slave SYNC clock sink.
%
%
%   'trigthresholdA'
%       Set threshold voltage for external trigger 1 and 2
%   
%   'trigthresholdB'
%       Set threshold voltage for external trigger 3 and 4
%
%   'trigpolarity'
%       Set polarity for an external trigger
%       Valid values are 'true' or 'false'.
%       Please use the option parameter for trigger id.  
%           For example: agt_awg_setstate(1,'trigpolarity','true',1);
%                        This statement will set external trigger 1 to true. 
%
%   'trigdelay'
%       Sets delay value for a trigger
%       Please use option input to specify the effected trigger (from 1 to 4).
%  
%   'arbscenhandle'
%       Set handle for arb scenario.
%       Valid value is an integer.
%
%   'mkrsource'
%       Selects a source for a marker.
%       Valid values are:
%           "off" : maker off
%           "sw"  : software marker
%           "ch1_wfm_mkr1" : channel 1 waveform marker 1
%           "ch1_wfm_mkr2" : channel 1 waveform marker 2
%           "ch2_wfm_mkr1" : channel 2 waveform marker 1
%           "ch2_wfm_mkr2" : channel 2 waveform marker 2
%           "seq_start"    : sequence start
%           "seq_rep"      : sequence repeat
%           "seq_gate"     : sequence gate
%           "wfm_start"    : waveform start
%           "wfm_rep"      : waveform repeat
%           "wfm_gate"     : waveform gate
%           "scen_rep"     : scenario repeat
%           "dds_wfm_start": DDS waveform start
%           "sw_mkr1"      : software marker 1
%           "sw_mkr2"      : software marker 2
%           "sw_mkr3"      : software marker 3
%           "sw_mkr4"      : software marker 4
%           "hw_trig1"     : hardware trigger 1
%           "hw_trig2"     : hardware trigger 2
%           "hw_trig3"     : hardware trigger 3
%           "hw_trig4"     : hardware trigger 4
%           "hw_aux_trig"  : hardware aux trigger
%           
%       Please use option input to specify the effected marker (from 1 to 4).
%       Example: agt_awg_setstate(1,'mkrsource','seq_start',2);
%
%   'mkrdelay'
%       Sets delay value for a marker
%       Please use option input to specify the effected marker (from 1 to 4).
%       
%
%   'mkrpulsewidth'
%       Sets pulse width for a marker
%       Please use option input to specify the effected marker (1 to 4).
%
%   'mkrpolarity'
%       Sets polarity for a marker
%       Valid values : 'true' or 'false'
%       Please use option input to specify the effected marker (1 to 4).
%
%   'predistortenabled'
%       Enables or disables the predistortion
%       Valid values are:
%           'true' - to enable the predistortion
%           'false' - to disable the predistortion
%       
%   'outputenabled'
%       Enables or disables the output 
%       Valid values are:
%           'true' - to enable the output.
%           'false' - to disable the output.
%       If chan is specified, only that channel is effected.
%       If chan is not specified, both channels will be effected.
%   'outputconfig'
%       Configures the output
%       Valid values are:
%           'diff' - selects passive differential output configuration.
%           'se' - selects passive single-ended output configuration.
%           'amp' - selects amplified (active) single-ended output configuration.
%       If chan is specified, only that channel is effected.
%       If chan is not specified, both channels will be effected.
%   'outputfilterenabled'
%       Enables or disables the output (reconstruction) filter
%       Valid values are:
%           'true' - to enable the output filter.
%           'false' - to disable the outputs filter.
%       If chan is specified, only that channel is effected.
%       If chan is not specified, both channel will be effected.
%   'outputbw'
%       Sets the output (reconstruction) filter bandwidth if enabled ...
%           (see: 'outputfilterenabled').
%       Valid values are:
%           250e6 - selects the 250 MHz output (reconstruction) filter.
%           500e6 - selects the 500 MHz output (reconstruction) filter.
%       If chan is specified, only that channel will be effected.
%       If chan is not specified, both channel will be effected.
%   'outputgain'
%       Sets the DAC output voltage 
%       Valid values are:
%           diff: 0.340 < X < 0.500
%           se: 0.170 < X < 0.250
%           amp: 0.340 < X < 0.500
%           where X is units of Volts
%       If chan is specified, only that channel will be effected.
%       If chan is not specified, both channel will be effected.
%   'outputoffset'
%       Sets the output voltage offset (DAC output dependent -- see: 'outputgain')
%       Valid values are:
%           diff ('outputgain' = 0.340): -0.038 < X < 0.038
%           diff ('outputgain' = 0.500): -0.020 < X < 0.020
%           se ('outputgain' = 0.170): -0.038 < X < 0.104
%           se ('outputgain' = 0.250): -0.110 < X < 0.020
%           amp: -0.200 < X < 0.200
%           Y < X < Z
%           where X is units of Volts
%       If chan is specified, only that channel will be effected.
%       If chan is not specified, both channel will be effected.
%   'refclksrc'
%       Sets the reference clock source. This is the 10 MHz reference clock.
%       Valid values are:
%           'ext' - Use front panel external refernce labled: "AUX 10 Mhz REF IN" on LXI model, or "10 Mhz REF IN" on PXI
%           'int' - Use internal reference clock source. (ie both 'ext' and 'int' are switched off)
%			'pxi' - Use Onboard PXI clock or (LXI VERSION ONLY) the autosensing front panel "10 MHz REF". This is the defualt setting
%       chan is N/A.
%
%   'clksrc'
%       Sets the sampling clock source.
%       Valid values are:
%           'ext' - to specify an external clock source.  To switch from 'int' to 
%                   'ext', the 'extclkrate' must already be set.
%                   (See 'extclkrate'). 
%           'int' - to specify the internal clock source of 1.25GHz.
%               Note:  when 'clksrc' is set to 'int', the user may specifiy
%               an 'ext' or 'int' 10MHz reference (see: 'refclksrc' in the 
%               agt_awg_setstate attribute). 
%       chan is N/A
%       
%   'extclkrate'
%       Sets the external sample clock rate.  To switch the clock source 
%       from internal to external, one must first set the external clock rate,
%       then set the clock source to 'ext'.  (See 'clksrc').  
%       Valid values are:
%           f - 100e6 < X < 1.25e9
%           where f is the sample rate in samples/second.
%       chan is N/A
%   'samplerate'
%       The arb's sample rate may be set equal to the sample clock frequency, 
%       or reduced from there by factors of exactly two. 
%           When the sample clock source is internal, the clock frequency is 
%       fixed at 1250MHz.  Normally, the valid range for the sample rate in
%       this case is from 1.22 MHz to 1250 MHz.  However, the range can be 
%       changed depending on the hardware configuration.
%           When the sample clock is externally supplied, the user MUST 
%       accurately communicate the clock frequency for the arb to operate properly. 
%       Changing the clock frequency generates a new list of legal values for 
%       the sample rate. For example, with a clock frequency of 1000MHz, 
%       legal sample rates include 1000, 500, 250, 125 MHz, etc. 
%   'interpolationratio'
%       The DDS interpolation ratio.  It can be set to 2^n where n is an
%       unsigned integer from 0 to 10.  That means interpolation ratio's
%       value can be 1,2,4,8,...,512,1024.
%   'scenarioplaymode'
%       Only available in advanced sequence mode
%       Valid values are: 
%           'single' - play scenario in only one time and wait for a
%                      trigger
%           'cont'   - play scenario continuously until receiving a
%                      jump or stop trigger
%   'scenariojumpmode'
%       Only available in advanced sequence mode
%       Valid values are: 
%           'immediate' - jump to the next scenario immediately when receiving a
%                         jump trigger
%           'end_wfm'   - jump to the next scenario when finishing the
%                         current waveform
%           'end_scenario' - jump to the next scenario when finishing the current scenario 
%   'scenariosource'
%       Only available in advanced sequence mode
%       The default value is 'sw'
%       Valid values are: 
%           'sw'    - the scenario source id is provided by the software.
%           'aux'   - the scenario source id is provided by the aux port.
%                     'aux' is used in dynamic sequencing.
%
%   'lxidomain'
%       Set the LXI domain
%       Valid integer values are: 0 to 255
%
%   See Also: agt_awg_browse.m, agt_awg_getstate.m
%

if ((nargin == 3) && ischar(varargin{2}))
    [errorcode, errorcode_description] = agt_awg_setall(varargin{1},varargin{2},varargin{3});
elseif ((nargin == 4) && ischar(varargin{2}))
    [errorcode, errorcode_description] = agt_awg_setone(varargin{1},varargin{2},varargin{3},varargin{4});
else
    error('Invalid input parameters. See help for details.');
end


function [errorcode, errorcode_description] = agt_awg_setall(handle,attrib,value)
handle = handle(1);
[errorcode, errorcode_description] = N6030MEX('setstate',handle,attrib,value,0);

function [errorcode, errorcode_description] = agt_awg_setone(handle,attrib,value,chan)
handle = handle(1);
[errorcode, errorcode_description] = N6030MEX('setstate',handle,attrib,value,chan);


% function [errorcode, errorcode_description] = agt_awg_setall(handle,awg_statevar)
% % update all statevars as per awg_statevar
