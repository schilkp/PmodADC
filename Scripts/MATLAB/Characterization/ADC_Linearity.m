% Measure ADC Output over a range of DC inputs
% Input Preamp/Filter/AC Coupling *bypassed*.

% Calibrate offset?

input_steps = 0:0.0003:5;
n_steps = size(input_steps,2);
samples_per_step = 10;

data = uint16(zeros(n_steps,samples_per_step));

prog_up = ProgressUpdate(n_steps,5);

% Open Connection:
com = serialport('COM8', 9600, 'Timeout', 0.1);

% Perform Measurement:
for step = 1:n_steps
   voltage = input_steps(step); 
   
   % Set Voltage
   % $$$$$$$$$$$$$$$$$$$$
   
   % Read from ADC
   [reading, fail_count] = adc_read_openport(com,samples_per_step+4);
   
   % Stop if there was a problem with package decoding:
   if fail_count > 2
      disp('Package decode error!');
      disp(['Failcount: ',num2str(fail_count)]);
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
%   INL, DNL
%   Monotonicity
%   Noise at different inputs?
