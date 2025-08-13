function plotIMUData(participant, exercise, trial)
    % Load participant data
    filename = sprintf("M3X%03d_IMU_Parsed_SwappedAxes_01_WS.mat", participant);
    structname = "IMUParsed";
    Participant_data = load(filename);

    % Get the list of sensors
    sensors = fieldnames(Participant_data.(structname).(exercise).(trial));
    % Check for stepOutBinary and stepOutTimes
    stepOutBinary = Participant_data.(structname).(exercise).(trial).stepOutBinary;
    stepOutTimes = Participant_data.(structname).(exercise).(trial).stepOutTimes;

    % Loop through each sensor and create separate figures
    for i = 3:length(sensors)-1
        sensor = sensors{i};

        % Extract acceleration and angular velocity data
        a = Participant_data.(structname).(exercise).(trial).(sensor).a;
        w = Participant_data.(structname).(exercise).(trial).(sensor).w;
        time = Participant_data.(structname).(exercise).(trial).time;
        
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
                % Get current axes limits
                ylim = get(gca, 'YLim'); 
                % Draw a vertical line at stepOutTimes with specified color and length
                xline(t, 'r--', "LineWidth", 1, 'Label', 'Step Out', 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom', 'Color', 'red');
                % Extend the line to the limits of the y-axis
                line([t t], ylim, 'Color', 'red', 'LineStyle', '--', 'LineWidth', 1);
            end
        end

        % Second subplot for angular velocity
        subplot(2, 1, 2); % 2 rows, 1 column, second subplot
        plot(time, w);
        xlabel("Time (s)");
        ylabel("Angular Velocity (rad/s)");
        title("Angular Velocity (" + sensor + ")");
        legend({"x", "y", "z"});
        grid on; 
    end
end