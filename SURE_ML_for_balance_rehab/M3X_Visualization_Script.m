%% Script to visualize parsed WS IMU data
clear;
clc;
close all;

%% Load all participant data & sanity check by plotting each sensor for each trial
% close the figure display to show the next figure
numFiles = 17; % Total number of files
sensor_list = ["head", "uback", "lumbar", "rarm", "larm", "rwrist", "lwrist", "lshank", "rshank", "rfoot", "lfoot", "lthigh", "rthigh"];
num_trials = 3; % Each exercise has 3 trials
num_sensors = length(sensor_list);

for k = 1:numFiles
    filename = sprintf("M3X%03d_IMU_Parsed_SwappedAxes_01_WS.mat", k);
    cellname = sprintf("M3X%03d_IMU_Parsed_SwappedAxes_01_WS", k);
    Participant_data = load(filename);
    exercise_names = fieldnames(Participant_data.(cellname)); 
    num_exercises = length(exercise_names);

    % Iterate through each exercise
    for e = 1:numel(exercise_names)
        exercise = exercise_names{e};
        % Iterate through each trial
        for t = 1:num_trials
            trial = sprintf('trial%d', t);
            % Iterate through each sensor
            for s = 1:num_sensors
                sensor_name = sensor_list(s);
                a = Participant_data.(cellname).(exercise).(trial).(sensor_name).a;
                w = Participant_data.(cellname).(exercise).(trial).(sensor_name).w;

                fig1 = figure();
                hold on
                plot(Participant_data.(cellname).(exercise).(trial).time, a)
                yline(9.8, 'r', "LineWidth", 2)
                xlabel("time (s)")
                ylabel("accel (m/s^2)")
                title(["M3X"+k "acceleration" exercise sensor_name])
                legend({"x", "y", "z"})
                waitfor(fig1);
                
                fig2 = figure();
                plot(Participant_data.(cellname).(exercise).(trial).time, w)
                xlabel("time (s)")
                ylabel("ang vel")
                title(["M3X"+k "angular velocity" exercise sensor_name])
                legend({"x", "y", "z"})
                waitfor(fig2);
            end
        end
    end
end


%% Create plots to check
% axes are defined such that x points to the left, y points backward, and z
% points up

struct_name = M3X011_IMU_Parsed_SwappedAxes_01_WS;

exercise = "WS14"; % options: WS01, WS06, WS19, WS32, WSR26, WSR31
trial = "trial2";
plot_imu = "uback"; % options: head, uback, lumbar, rarm, larm, lwrist, rwrist, lthigh, rthigh, lshank, rshank, lfoot, rfoot

%%
figure()
hold on
plot(struct_name.(exercise).(trial).time, struct_name.(exercise).(trial).(plot_imu).a)
yline(9.8, 'r', "LineWidth", 2)
xlabel("time (s)")
ylabel("accel (m/s^2)")
title(["acceleration" exercise plot_imu])
legend({"x", "y", "z"})

figure()
plot(struct_name.(exercise).(trial).time, struct_name.(exercise).(trial).(plot_imu).w)
xlabel("time (s)")
ylabel("ang vel")
title(["angular velocity" exercise plot_imu])
legend({"x", "y", "z"})

%% spectrogram
% Parameters for spectrogram
window = hamming(256); % Window function
noverlap = 128; % Number of overlapping samples
nfft = 512; % Number of FFT points
fs = 128; % Sampling frequency

% Extract acceleration data for the specified IMU part
accelData = struct_name.(exercise).(trial).(plot_imu).w(:,1);

% Compute the spectrogram
[s, f, t] = spectrogram(accelData, window, noverlap, nfft, fs);

% Plot the spectrogram
figure;
imagesc(t, f, 10*log10(abs(s).^2)); % Convert to dB
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title(['Spectrogram of ', exercise, ' ', trial, ' ', plot_imu]);
colorbar;
% Set color bar limits
clim([-70 30]); % Set the color bar range from -70 to 30 dB