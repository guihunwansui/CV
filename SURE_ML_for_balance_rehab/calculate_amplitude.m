function amplitude = calculate_amplitude(participant, exercise, trial, sensor)
    % Load participant data
    filename = sprintf("PH%03d_IMU_Parsed_SwappedAxes_01_WS.mat", participant);
    Participant_data = load(filename);

    % Check if the exercise number is odd or even
    exercise_digits = exercise(end-1:end); % Get the last two characters
    exercise_index = str2double(exercise_digits); % Convert to number

    % Extract acceleration data for the specified sensor
    a = Participant_data.IMUParsed.(exercise).(trial).(sensor).a;

    % Denoising using a low-pass filter for acceleration
    fs = 128; % Sample rate
    fc = 0.3;  % Cut-off frequency
    [b, a0] = butter(4, fc/(fs/2)); % 4th order Butterworth filter
    denoised_a = filtfilt(b, a0, a); % Apply filter to acceleration

    % Find local maxima and minima
    [maxima, ~] = findpeaks(denoised_a(:,3));
    [minima, ~] = findpeaks(-denoised_a(:,3)); % Find peaks of the negative signal to get minimums

    % Find the continuous increasing sequence in local maxima
    [~, increasing_end] = find_continuous_increasing_sequence(maxima);

    % Find the continuous decreasing sequence in local minimums
    [~, decreasing_end] = find_continuous_decreasing_sequence(-minima);

    % Calculate amplitude
    z_amplitude = (increasing_end - decreasing_end) / 2;

    if mod(exercise_index,2)==0 % AP exercise, looking for y
        denoised_a = denoised_a(:,2);
    else % ML exercise, looking for x
        denoised_a = denoised_a(:,1);
    end

    % Find local maxima and minima
    [maxima, ~] = findpeaks(denoised_a);
    [minima, ~] = findpeaks(-denoised_a); % Find peaks of the negative signal to get minimums

    % Find the continuous increasing sequence in local maxima
    [~, increasing_end] = find_continuous_increasing_sequence(maxima);

    % Find the continuous decreasing sequence in local minimums
    [~, decreasing_end] = find_continuous_decreasing_sequence(-minima);

    % Calculate amplitude
    amplitude = (increasing_end - decreasing_end) / 2;

    fprintf("The amplitude for %s is estimated to be %.*g; z_component is %.*g\n", sensor, 3, amplitude, 3, z_amplitude);

    tilt_angle = atan2(amplitude,z_amplitude)*180/pi;
    fprintf("The tilt angle is estimated to be %.*g\n", 2, tilt_angle);
end

function [seq, endpoint] = find_continuous_increasing_sequence(data)
    % Initialize variables
    seq = data(1);
    endpoint = data(1);

    % Loop through data to find continuous increasing sequence
    for i = 2:length(data)
        if data(i) > data(i-1)
            seq = [seq, data(i)];
            endpoint = data(i);
        else
            break;
        end
    end
end

function [seq, endpoint] = find_continuous_decreasing_sequence(data)
    % Initialize variables
    seq = data(1);
    endpoint = data(1);

    % Loop through data to find continuous decreasing sequence
    for i = 2:length(data)
        if data(i) < data(i-1)
            seq = [seq, data(i)];
            endpoint = data(i);
        else
            break;
        end
    end
end
