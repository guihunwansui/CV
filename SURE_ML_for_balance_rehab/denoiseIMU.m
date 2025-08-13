function denoiseIMU(participant, exercise, trial)
    % Load participant data
    filename = sprintf("PH%03d_IMU_Parsed_SwappedAxes_01_WS.mat", participant);
    Participant_data = load(filename);
    structname = "IMUParsed";

    % Get the list of sensors
    sensors = fieldnames(Participant_data.IMUParsed.(exercise).(trial));

    % Loop through each sensor and create separate figures
    for i = 3:length(sensors)-1
        sensor = sensors{i};

        % Extract acceleration and angular velocity data
        a = Participant_data.IMUParsed.(exercise).(trial).(sensor).a; % Acceleration
        w = Participant_data.IMUParsed.(exercise).(trial).(sensor).w; % Angular velocity
        time = Participant_data.IMUParsed.(exercise).(trial).time;

        % Denoising using a low-pass filter for acceleration
        fs = 128; % Sample rate
        fc = 0.3;  % Cut-off frequency
        [b, a0] = butter(4, fc/(fs/2)); % 4th order Butterworth filter
        denoised_a = filtfilt(b, a0, a); % Apply filter to acceleration
        denoised_w = filtfilt(b, a0, w); % Apply filter to angular velocity

        % Create a figure for the sensor
        figure;
        % Define colors based on the "gem" palette
        gem_colors = [
            0.0, 0.4470, 0.7410; % Default color 1 (blue)
            0.8500, 0.3250, 0.0980; % Default color 2 (red)
            0.9290, 0.6940, 0.1250; % Default color 3 (yellow)
            0.4940, 0.1840, 0.5560; % Default color 4 (purple)
            0.4660, 0.6740, 0.1880; % Default color 5 (green)
            0.3010, 0.7450, 0.9330  % Default color 6 (cyan)
        ];
        
        % Plot acceleration for each axis
        subplot(2, 1, 1); % Subplot for acceleration
        hold on;
        plot(a(:, 1), 'LineWidth', 0.1, 'Color', [gem_colors(1, :), 0.2]); % Original X-axis
        plot(a(:, 2), 'LineWidth', 0.1, 'Color', [gem_colors(2, :), 0.2]); % Original Y-axis
        plot(a(:, 3), 'LineWidth', 0.1, 'Color', [gem_colors(3, :), 0.2]); % Original Z-axis
        plot(denoised_a(:, 1), 'LineWidth', 1.5, 'Color', gem_colors(1, :)); % Denoised X-axis
        plot(denoised_a(:, 2), 'LineWidth', 1.5, 'Color', gem_colors(2, :)); % Denoised Y-axis
        plot(denoised_a(:, 3), 'LineWidth', 1.5, 'Color', gem_colors(3, :)); % Denoised Z-axis
        title(sprintf('Sensor: %s - Original vs Denoised Acceleration', sensor));
        xlabel('Timesteps');
        ylabel('Acceleration');
        grid on;
        legend({'Original X', 'Original Y', 'Original Z', 'Denoised X', 'Denoised Y', 'Denoised Z'}, 'Location', 'northeast');
        hold off;
        
        % Plot angular velocity for each axis
        subplot(2, 1, 2); % Subplot for angular velocity
        hold on;
        plot(w(:, 1), 'LineWidth', 0.1, 'Color', [gem_colors(1, :),0.2]); % Original X-axis
        plot(w(:, 2), 'LineWidth', 0.1, 'Color', [gem_colors(2, :),0.2]); % Original Y-axis
        plot(w(:, 3), 'LineWidth', 0.1, 'Color', [gem_colors(3, :),0.2]); % Original Z-axis
        plot(denoised_w(:, 1), 'LineWidth', 1.5, 'Color', gem_colors(1, :)); % Denoised X-axis
        plot(denoised_w(:, 2), 'LineWidth', 1.5, 'Color', gem_colors(2, :)); % Denoised Y-axis
        plot(denoised_w(:, 3), 'LineWidth', 1.5, 'Color', gem_colors(3, :)); % Denoised Z-axis
        title(sprintf('Sensor: %s - Original vs Denoised Angular Velocity', sensor));
        xlabel('Timesteps');
        ylabel('Angular Velocity');
        grid on;
        hold off;

    end
end
