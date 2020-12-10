% Measure ADC Output amplitude over a range frequencies
% ADC Standard Config.

% Store all? 
% Calibrate offset?

input_steps = 5:10:30000;   % Step Size?, Min/Max?

n_steps = size(input_steps,2);
samples_per_step = 41000/4;  % ? Constant? Reduce for higher f's?

data = uint16(zeros(n_steps,samples_per_step));

prog_up = ProgressUpdate(n_steps,5);

% Open Connection:
com = serialport('COM8', 9600, 'Timeout', 0.1);

% Perform Measurement:
for step = 1:n_steps
   freq = input_steps(step); 
   
   % Set Freq.
   % $$$$$$$$$$$$$$$$$$$$
   
   % Read from ADC
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
   
   prog_up.Update(step)
end

clear com;

% Look at: 
%   Amplitude vs f  (look at rms?)