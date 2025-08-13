function calculate_amplitude_ginput(participant, exercise, trial, sensor)
    % Load participant data
    filename = sprintf("PH%03d_IMU_Parsed_SwappedAxes_01_WS.mat", participant);
    Participant_data = load(filename);

    % Extract acceleration data for the specified sensor
    a = Participant_data.IMUParsed.(exercise).(trial).(sensor).a;

    % Denoising using a low-pass filter for acceleration
    fs = 128; % Sample rate
    fc = 0.3;  % Cut-off frequency
    [b, a0] = butter(4, fc/(fs/2)); % 4th order Butterworth filter
    denoised_a = filtfilt(b, a0, a); % Apply filter to acceleration

    % Plot the denoised signal for user input
    plot(a, 'LineWidth', 0.1, 'Color', [0.9, 0.9, 0.3, 0.3]);
    hold on;    
    plot(denoised_a, 'LineWidth', 1);
    title('Select Maxima and Minima');
    xlabel('Samples');
    ylabel('Acceleration');
    grid on;
    hold off;

    % Get user input for [x/y] and z component of acceleration. If AP
    % exercise, should be atan(y/z); if ML exercise, should be atan(x/z)
    fprintf('Select the first point for [x/y] component (press Enter when done):\n');
    [x0, y0] = ginput; % User selects maxima
    y0 = mean(y0);
    x0 = round(mean(x0));
    z0 = denoised_a(x0, 3);

    tilt_angle1 = atan2(y0, z0)*180/pi;
    fprintf("The tilt angle1 is estimated to be %.*g degrees\n", 2, tilt_angle1);

    fprintf('Select the second point for [x/y] component (press Enter when done):\n');
    [x1, y1] = ginput; % User selects maxima
    y1 = mean(y1);
    x1 = round(mean(x1));
    z1 = denoised_a(x1, 3);

    % Calculate the tilt angle for the second component
    tilt_angle2 = atan2(y1, z1)*180/pi;
    fprintf("The tilt angle2 is estimated to be %.*g degrees\n", 2, tilt_angle2);

    % fprintf("The ROM is %.*g degrees\n", 2, abs(tilt_angle2-tilt_angle1));


end