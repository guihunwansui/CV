%spectrogram generation
%% Script to visualize parsed WS IMU data
clear;
clc;
close all;

%% Load parsed data
load M3X001_IMU_Parsed_SwappedAxes_01_WS.mat

%%
% Define exercise names
exerciseNames = fieldnames(M3X001_IMU_Parsed_SwappedAxes_01_WS);

% Spectrogram parameters
window = hamming(256); % Window function
noverlap = 128; % Number of overlapping samples
nfft = 512; % Number of FFT points
fs = 128; % Sampling frequency

% Determine the maximum length of the acceleration data
maxLength = 0;
for i = 1:length(exerciseNames)
    for j = 1:3
        trial = sprintf('trial%d', j); 
        x = M3X001_IMU_Parsed_SwappedAxes_01_WS.(exerciseNames{i}).(trial).head.a(:, 1);
        maxLength = max(maxLength, length(x)); % Update maxLength
    end
end

% Loop through each exercise and plot the spectrogram
for i = 1:length(exerciseNames)
    % Extract acceleration data for the current exercise
    for j = 1:3
        trial = sprintf('trial%d', j); 
        x = M3X001_IMU_Parsed_SwappedAxes_01_WS.(exerciseNames{i}).(trial).head.a(:, 1);  

        % Zero-pad the signal to the maximum length
        xPadded = [x; zeros(maxLength - length(x), 1)];
    
        % Compute the spectrogram
        [s, f, t] = spectrogram(xPadded, window, noverlap, nfft, fs);
    
        % Plot the spectrogram
        figure;
        imagesc(t, f, 10*log10(abs(s).^2)); % Convert to dB
        axis xy;
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        title(['Spectrogram of ', exerciseNames{i}, trial]);
        colorbar;
    end
end