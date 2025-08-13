%% Script to visualize parsed WS IMU data
clear;
clc;
close all;

%% Load parsed data
load M3X001_IMU_Parsed_SwappedAxes_01_WS.mat

%% Define exercise names
exerciseNames = fieldnames(M3X001_IMU_Parsed_SwappedAxes_01_WS);

% Spectrogram parameters
noverlap = 128; % Number of overlapping samples
nfft = 512; % Number of FFT points
fs = 128; % Sampling frequency

% Loop through each exercise and plot the spectrogram
for i = 1:length(exerciseNames)
    % Extract acceleration data for the current exercise
    for j = 1:3
        trial = sprintf('trial%d', j); 
        x = M3X001_IMU_Parsed_SwappedAxes_01_WS.(exerciseNames{i}).(trial).head.a(:, 1);  

        % Determine window length based on the signal length
        windowLength = min(256, length(x)); % Use a maximum window length of 256
        window = hamming(windowLength); % Create Hamming window of the determined length

        % Compute the spectrogram
        [s, f, t] = spectrogram(x, window, noverlap, nfft, fs);

        % Plot the spectrogram
        figure;
        imagesc(t, f, 10*log10(abs(s).^2)); % Convert to dB
        axis xy;
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        title(['Spectrogram of ', exerciseNames{i}, ' ', trial]);
        colorbar;
    end
end
