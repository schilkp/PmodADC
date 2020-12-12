% Measure ADC Output amplitude over a range frequencies
% ADC Standard Config.

% Store all? 
% Calibrate offset?

%input_steps = logspace(0,4,20*5);   % Step Size?, Min/Max?
input_steps = logspace(0,4,10);

n_steps = size(input_steps,2);
samples_per_step = 41000;  % ? Constant? Reduce for higher f's?

data = uint16(zeros(n_steps,samples_per_step));
set_point = zeros(n_steps);

prog_up = ProgressUpdate(n_steps,5);

% Open Connection:
com = serialport('COM6', 9600, 'Timeout', 0.1);

% Instrument Connection
FGEN = keysight_33612A('USB0::0x0957::0x4B07::MY59000369::0::INSTR'); %find usb string with tmtool

% configure
FGEN.configure_waveform(1, 'SIN','INF'); 
FGEN.set_amplitude_value(1,4,0);
FGEN.set_output(1,'ON');
pause(4);

% Perform Measurement:
for step = 1:n_steps
   freq = input_steps(step); 
   
   % Set Freq.
   FGEN.set_frequency_value(1,freq);
   
   % Read from ADC
   adc_read_openport(com, 2100);
   [reading, fail_count] = adc_read_openport(com,samples_per_step+4);
   
   % Stop if there was a problem with package decoding:
   if fail_count > 2
      disp('Package decode error!');
      disp(['Failcount: ',str(fail_count)]);
      clear com;
      break;
   end
   
   % Get rid of extra readings:
   reading = reading(1:samples_per_step,:);
   
   % Save
   data(step,:) = reading.';
   set_point(step) = freq;
   
   prog_up.Update(step)
end

FGEN.set_output(1,'OFF');
FGEN.disconnect();
clear com;

save ADC_FResp.mat;

% Look at: 
%   Amplitude vs f  (look at rms?)