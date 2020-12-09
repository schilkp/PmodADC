% Load an audio file, and play it back via the ADC

% Load a file:
file_name = 'some_audio_file.wav';
[audio, Fs] = audioread(file_name);

% Use only one channel, if there are multiple:
audio = audio(:,1);

% Resample audio to 41000
if(Fs ~= 41000)
    audio = resample(audio,41000,44100);
    if(max(abs(audio))>1)
        audio = audio/max(abs(audio));
    end
end

% Get audio ready:
audio = dac_scale_audio(audio);

% Play audio:
disp('Playing....');
port_name = 'COM8';
dac_play(port_name, audio);