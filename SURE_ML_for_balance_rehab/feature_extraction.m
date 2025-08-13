function feature_extraction(participant, exercise, trial)
    % Load participant data
    filename = sprintf("PH%03d_IMU_Parsed_SwappedAxes_01_WS.mat", participant);
    Participant_data = load(filename);
    structname = "IMUParsed";

    % Get the list of sensors
    sensors = fieldnames(Participant_data.IMUParsed.(exercise).(trial));

    % Check if the exercise number is odd or even
    exercise_digits = exercise(end-1:end); % Get the last two characters
    exercise_index = str2double(exercise_digits); % Convert to number

    fs = 128; % Sample rate
    fc = 0.3;  % Cut-off frequency
    [b, a0] = butter(4, fc/(fs/2)); % 4th order Butterworth filter

    % Check for stepOutBinary and stepOutTimes
    stepOutBinary = Participant_data.(structname).(exercise).(trial).stepOutBinary;
    stepOutTimes = Participant_data.(structname).(exercise).(trial).stepOutTimes;

    % Loop through each sensor and create separate figures
    for i = 3:length(sensors)-1
        sensor = sensors{i};

        % Extract acceleration and angular velocity data
        a = Participant_data.IMUParsed.(exercise).(trial).(sensor).a;
        w = Participant_data.IMUParsed.(exercise).(trial).(sensor).w;
        time = Participant_data.IMUParsed.(exercise).(trial).time;

        % Create a new figure for each sensor
        fig = figure('Name', sprintf("Participant %d - %s %s (%s)", participant, exercise, trial, sensor));

        % First subplot for acceleration
        subplot(2, 1, 1); % 2 rows, 1 column, first subplot
        hold on;
        plot(time, a);
        yline(9.8, 'r', "LineWidth", 2); % Reference line for gravity
        xlabel("Time (s)");
        ylabel("Acceleration (m/s^2)");
        title("Acceleration (" + sensor + ")");
        legend({"x", "y", "z"});
        grid on; 

        % Draw vertical lines if conditions are met
        if stepOutBinary == 1 && ~isempty(stepOutTimes)
            for t = stepOutTimes
                xline(t, 'k--', "LineWidth", 1); % Vertical line at stepOutTimes
            end
        end

        % draw the denoised angular velocity for uback 


        % Second subplot for angular velocity
        subplot(2, 1, 2); % 2 rows, 1 column, second subplot
        plot(time, w);
        xlabel("Time (s)");
        ylabel("Angular Velocity (rad/s)");
        title("Angular Velocity (" + sensor + ")");
        legend({"x", "y", "z"});
        grid on; 
        hold off;

        % if sensor == "uback"
        %      fc1 = 1.5;  % Cut-off frequency
        %      [b1, a1] = butter(4, fc1/(fs/2)); % 4th order Butterworth filter
        %      if mod(exercise_index,2)==0 % AP exercise
        %         denoised_w = filtfilt(b1, a1, w(:,1)); % Apply filter to angular velocity
        %      else
        %         denoised_w = filtfilt(b1, a1, w(:,2)); % Apply filter to angular velocity
        %      end
        % 
        %      plot(time, denoised_w, 'Color', [1, 0.5, 0.8], 'LineWidth', 1);
        % end

        % checking stepouts by comparing the original signal and the
        % denoised signal; if the denoised signal is much smaller than the
        % orginal one, then there is a spike, or potential step-out; then
        % check the stepOutTimes to see whether there is a marked step-out
        % within 2s window; if not, print (missing marker for step-out at (timestep))
        if sensor == "lfoot" || sensor == "rfoot"
            % Define a threshold for detecting spikes
            threshold = 0.08; % Adjust this threshold as needed

            % Denoising using a low-pass filter for acceleration
            denoised_a = filtfilt(b, a0, a); % Apply filter to acceleration
            denoised_w = filtfilt(b, a0, w); % Apply filter to angular velocity

            % Loop through each time step
            for t = 1:length(time)
                % Check if the denoised signal is much smaller than the original signal
                if ((abs(denoised_a(t)) < threshold * abs(a(t)) || abs(denoised_w(t)) < threshold * abs(w(t))) && (abs(a(t))>7 || abs(w(t))>1.2)) || (abs(a(t)) > 20 || abs(w(t)) > 3)
                    % Potential step-out detected
                    fprintf("Step-out at %.*g\n", 3, t/fs);
                    % Check if there is a marked step-out within 2s window
                    window_start = max(0, t/fs-2);
                    window_end = min(time(end), t/fs+2);
                    if ~any(stepOutTimes((stepOutTimes>window_start) & (stepOutTimes <window_end)))
                        % No marked step-out within 2s window
                        fprintf('Missing marker at time step %.*g\n', 3, t/fs);
                    end
                end
            end
        end
    end

        % calculate the amplitude for acceleration (tilt info)
        % extract the local maximums and minimums of denoised_a for sensor
        % 'uback', find the continuous increasing sequence of the maxima 
        % and find the endpoint, instead of the longest increasing sequence, 
        % also find the counterpart in the minima, subtract the two endpoints and /2
        % amplitude_uback = calculate_amplitude(participant, exercise, trial, 'uback');

        calculate_amplitude_ginput(participant, exercise, trial, 'uback');


        % tell whether Hip or ankle driven 
        % by evaluating the denoised signal of sensors 'rshank' and 'lshank', 'rthigh', and 'lthigh'. 
        % If both shanks or both thighs have the amplitude near zero, print the results indicating Hip driven. 
        % Otherwise, further check the proportion of the amplitudes of shanks, and thighs, compared to the amplitude of uback. 
        % If they are proportional, print the results ankle driven; 
        % if the shanks and thighs have unproportional small amplitudes, print the results hip driven

        % Calculate amplitudes for each sensor
        % amplitude_rshank = calculate_amplitude(participant, exercise, trial, 'rshank');
        % calculate_amplitude_ginput(participant, exercise, trial, 'rshank');
        % amplitude_lshank = calculate_amplitude(participant, exercise, trial, 'lshank');
        % calculate_amplitude_ginput(participant, exercise, trial, 'lshank');
        % amplitude_rthigh = calculate_amplitude(participant, exercise, trial, 'rthigh');
        % calculate_amplitude_ginput(participant, exercise, trial, 'rthigh');
        % amplitude_lthigh = calculate_amplitude(participant, exercise, trial, 'lthigh');  
        % calculate_amplitude_ginput(participant, exercise, trial, 'lthigh');
        % 
        % % Check for near zero amplitude in shanks or thighs
        % if (amplitude_rshank < 0.1 && amplitude_lshank < 0.1) || (amplitude_rthigh < 0.5 && amplitude_lthigh < 0.5)
        %     fprintf('The exercise is hip driven.\n');
        % else
        %     % Check proportionality of amplitudes
        %     if (amplitude_rshank / amplitude_uback > 0.35 && amplitude_lshank / amplitude_uback > 0.35) || (amplitude_rthigh / amplitude_uback > 0.45 && amplitude_lthigh / amplitude_uback > 0.45)
        %         fprintf('The exercise is ankle driven.\n');
        %     elseif (amplitude_rshank / amplitude_uback < 0.2 && amplitude_lshank / amplitude_uback < 0.2) || (amplitude_rthigh / amplitude_uback < 0.3 && amplitude_lthigh / amplitude_uback < 0.3)
        %         fprintf('The exercise is hip driven.\n');
        %     else
        %         fprintf('Not sure driving joint.\n')
        %     end
        %     if amplitude_uback < amplitude_rshank || amplitude_uback < amplitude_lshank
        %         fprintf('The trunk may not move properly.\n');
        %     end
        % end
end