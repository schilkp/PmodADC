% Load an audio file, and play it back via the ADC

% Load a file:
file_name = 'some_audio_file.wav';
[audio, Fs] = audioread(file_name);

% Use only one channel, if there are multiple:
audio = audio(:,1);

% Get audio ready:
audio = dac_scale_audio(audio);

% Play audio:
disp('Playing....');
port_name = 'COM8';
dac_play(port_name, audio);