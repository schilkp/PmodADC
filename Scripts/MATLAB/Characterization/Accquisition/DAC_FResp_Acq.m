% Measure AC Output at different frequenciess 
% DAC Standard Config.

input_steps = 5dat:1000:30000;   % Step Size?, Min/Max?

n_steps = size(input_steps,2);

fs = 41000;
stimulus_length = 1;  % in seconds 

samples_per_step = 16000;

prog_up = ProgressUpdate(n_steps,1);

data = zeros(n_steps,samples_per_step);
set_point = zeros(n_steps,1);

% Stimulus timebase:
t = 0:(1/fs):stimulus_length;

% Open Connection:
com = serialport('COM6', 9600, 'Timeout', 0.1);

OSCI = keysight_DSOX3034('USB0::0x2A8D::0x1764::MY60103865::0::INSTR'); %find usb string with tmtool

% configure
OSCI.configure_source(1, 5, 1); 

OSCI.set_trigger(1, 1);

% set to high resolution
OSCI.set_acq_mode('HRES');

pause(4);

% Perform Measurement:
for step = 1:n_steps
   f = input_steps(step); 
   
   % Generate stimulus
   y = 0.8*sin(2*pi()*f*t);
   audio = dac_scale_audio(y');
   
   %play
   dac_play_openport(com, audio);
   
   % Data Record
   waveform = OSCI.get_measurement(1);
   data(step,:) = waveform;
   set_point(step) = f;
   
   prog_up.Update(step)
end

OSCI.disconnect();
clear com;

