% Record some audio, save it, and play it back on the computer.

% Decide how many samples to record
sample_rate = 41000;
recording_length_s = 15;
record_n_samples = sample_rate*recording_length_s;

% Record audio
disp('Recording....');
port_name = 'COM8';
[audio, fail_count] = adc_read(port_name, record_n_samples);
disp([num2str(fail_count),' packages failed to decode']);

% Process recorded audio:
audio = adc_scale_samples(audio);

% Play recorded audio:
disp('Playing....');
sound(audio, sample_rate);

% Save recorded audio to file:
audio_file_name = 'recording.wav';

% Upsample to 44100, makes file playback easier. 
audio_resample = resample(audio, 44100,41000);
if(max(abs(audio_resample))>1)
    audio_resample = audio_resample/max(abs(audio_resample));
end

audiowrite(audio_file_name, audio, sample_rate);