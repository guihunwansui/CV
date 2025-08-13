%% input processing for M3X data
clear;
clc;
close all;

%% Load all participant data
numFiles = 17; % Total number of files
Participant_data = cell(1, numFiles);

for k = 1:numFiles
    tic
    filename = sprintf("M3X%03d_IMU_Parsed_SwappedAxes_01_WS.mat", k);
    Participant_data{k} = load(filename);
    toc
end

%% Load the Excel file
excelFile = 'M3X Weight Shifting Ratings Simplified 051525.csv';
dataTable = readtable(excelFile);

%% Training and val step-outs extraction
num_trials = 3;
participant_indices = 1:numFiles; 
exclude_indices = [6, 8]; 
filtered_indices = setdiff(participant_indices, exclude_indices);

% Initialize cell arrays to hold training and validation data and labels
training_stepout = {};
validation_stepout = {};

% Set the random seed for reproducibility
rng(666); 

% Randomly select 20% of participants for validation
num_validation = round(0.2 * length(filtered_indices));
validation_indices = filtered_indices(randperm(length(filtered_indices), num_validation));

% Iterate through each participant
for p = filtered_indices
    cell_name = sprintf("M3X%03d_IMU_Parsed_SwappedAxes_01_WS", p);
    exercise_names = fieldnames(Participant_data{1, p}.(cell_name)); 
    num_exercises = length(exercise_names);

    % Iterate through each exercise
    for e = 1:numel(exercise_names)
        exercise = exercise_names{e};

        % Iterate through each trial
        for t = 1:num_trials
            trial = sprintf('trial%d', t); 
            Trial = sprintf('Trial%dPTRating', t); 

            % Extract step-out information
            if Participant_data{1, p}.(cell_name).(exercise).(trial).stepOutBinary == 1
                stepouts = Participant_data{1, p}.(cell_name).(exercise).(trial).stepOutTimes(1);
            else
                stepouts = 0;
            end

            % Convert exercise to match ExerciseID format
            if length(exercise) == 4 % If the exercise is WS
                exerciseID = [exercise(1:2), '-', exercise(3:end)]; % Insert hyphen
            else % the exercise is WSR
                exerciseID = [exercise(1:3), '-', exercise(4:end)]; 
            end

            % Extract the label from the Excel table
            subjectID = sprintf("M3X%02d", p); 
            subjectID_matches = strcmp(dataTable.SubjectID, subjectID); 
            exerciseID_matches = strcmp(dataTable.ExerciseID, exerciseID); 
            combined_matches = subjectID_matches & exerciseID_matches; 
            labels = dataTable{combined_matches, Trial};

            % Check for missing labels and exclude NaN values
            labels = labels(~isnan(labels)); % Keep only non-NaN labels
            
            if ~isempty(labels) % Check if there are any valid labels left
                % Store step-out information and data for training or validation
                if ismember(p, validation_indices)
                    validation_stepout{end+1} = stepouts; % Add to validation set
                else
                    training_stepout{end+1} = stepouts; % Add to training set
                end
            end
        end                           
    end
end



%% visualize class imbalance for the original file
% Initialize counts for each class (1 to 5)
classCounts = zeros(5, 1);

% Loop through each trial column and count occurrences of each class
for trial = 1:3
    trialColumn = dataTable{:, sprintf('Trial%dPTRating', trial)};
    for class = 1:5
        classCounts(class) = classCounts(class) + sum(trialColumn == class);
    end
end

% Display the counts for each class
disp('Class Counts:');
disp(table((1:5)', classCounts, 'VariableNames', {'Class', 'Count'}));

%% Initialize parameters, train-val split, stack sensors
sensor_list = ["head", "uback", "lumbar", "rarm", "larm", "rwrist", "lshank", "rshank", "rfoot", "lwrist", "lfoot", "rthigh", "lthigh"];
num_trials = 3;
num_sensors = length(sensor_list);
participant_indices = 1:numFiles; 
exclude_indices = [6, 8]; 
filtered_indices = setdiff(participant_indices, exclude_indices);

% Initialize a cell array to hold training data and labels
training_data = {};
training_labels = {};
% Initialize a cell array to hold validation data and labels
validation_data = {};
validation_labels = {};

% Set the random seed for reproducibility
rng(666); 

% Randomly select 20% of participants for validation
num_validation = round(0.2 * length(filtered_indices));
validation_indices = filtered_indices(randperm(length(filtered_indices), num_validation));

% Iterate through each participant
for p = filtered_indices
    cell_name = sprintf("M3X%03d_IMU_Parsed_SwappedAxes_01_WS", p);
    exercise_names = fieldnames(Participant_data{1, p}.(cell_name)); 
    num_exercises = length(exercise_names);

    % Iterate through each exercise
    for e = 1:numel(exercise_names)
        exercise = exercise_names{e};

        % Iterate through each trial
        for t = 1:num_trials
            trial = sprintf('trial%d', t); 
            Trial = sprintf('Trial%dPTRating', t); 
            trial_data = [];

            % Iterate through each sensor
            for s = 1:num_sensors
                sensor_name = sensor_list(s);
                % Check if the sensor data exists
                if isfield(Participant_data{1, p}.(cell_name).(exercise).(trial), sensor_name)
                    a = Participant_data{1, p}.(cell_name).(exercise).(trial).(sensor_name).a;
                    w = Participant_data{1, p}.(cell_name).(exercise).(trial).(sensor_name).w;

                    % Concatenate the sensor data into the trial_data array
                    trial_data = [trial_data, a, w]; 
                else
                    % If the sensor data is missing, append NaN
                    trial_data = [trial_data, NaN(size(a, 1), 6)]; % Adjust size as needed
                end
            end         

            % Convert exercise to match ExerciseID format
            if length(exercise) == 4 % If the exercise is WS
                exerciseID = [exercise(1:2), '-', exercise(3:end)]; % Insert hyphen
            else % the exercise is WSR
                exerciseID = [exercise(1:3), '-', exercise(4:end)]; 
            end

            % Extract the label from the Excel table
            subjectID = sprintf("M3X%02d", p); 
            subjectID_matches = strcmp(dataTable.SubjectID, subjectID); 
            exerciseID_matches = strcmp(dataTable.ExerciseID, exerciseID); 
            combined_matches = subjectID_matches & exerciseID_matches; 
            labels = dataTable{combined_matches, Trial};

            % Check for missing labels and exclude NaN values
            labels = labels(~isnan(labels)); % Keep only non-NaN labels

            % Proceed with valid_labels for further processing
            if ~isempty(labels) % Check if there are any valid labels left
                % Store in validation set if participant is in validation list
                if ismember(p, validation_indices)
                    validation_data{end+1} = trial_data; % Store trial data
                    validation_labels{end+1} = labels; % Store the corresponding label
                else
                    training_data{p, e, t} = trial_data; % Store trial data
                    training_labels{p, e, t} = labels; % Save the trial label
                end
            end
        end                           
    end
end

%% Test set out-saved
test_data = {};
test_labels = {};

% Iterate through each participant
for p = exclude_indices
    cell_name = sprintf("M3X%03d_IMU_Parsed_SwappedAxes_01_WS", p);
    exercise_names = fieldnames(Participant_data{1, p}.(cell_name)); 
    num_exercises = length(exercise_names);

    % Iterate through each exercise
    for e = 1:numel(exercise_names)
        exercise = exercise_names{e};

        % Iterate through each trial
        for t = 1:num_trials
            trial = sprintf('trial%d', t); 
            trial_data = [];

            % Iterate through each sensor
            for s = 1:num_sensors
                sensor_name = sensor_list(s);
                % Check if the sensor data exists
                if isfield(Participant_data{1, p}.(cell_name).(exercise).(trial), sensor_name)
                    a = Participant_data{1, p}.(cell_name).(exercise).(trial).(sensor_name).a;
                    w = Participant_data{1, p}.(cell_name).(exercise).(trial).(sensor_name).w;

                    % Concatenate the sensor data into the trial_data array
                    trial_data = [trial_data, a, w]; 
                else
                    % If the sensor data is missing, append NaN
                    trial_data = [trial_data, NaN(size(a, 1), 6)]; % Adjust size as needed
                end
            end         

            % Extract the label from the Excel table
            subjectID = sprintf("M3X%02d", p); 
            subjectID_matches = strcmp(dataTable.SubjectID, subjectID); 
            exerciseID = sprintf('%s-%s', exercise(1:2), exercise(3:end)); % Adjust for ExerciseID format
            exerciseID_matches = strcmp(dataTable.ExerciseID, exerciseID); 
            combined_matches = subjectID_matches & exerciseID_matches; 
            labels = dataTable{combined_matches, Trial};

            % Check for missing labels and exclude NaN values
            labels = labels(~isnan(labels)); % Keep only non-hyphen labels

            % Store in test set if participant is in exclude_indices
            if ismember(p, exclude_indices)
                if ~isempty(labels) % Check if there are any valid labels left
                    test_data{end+1} = trial_data; % Store trial data
                    test_labels{end+1} = labels; % Store the corresponding label
                end
            end
        end                           
    end
end

%%
% Initialize a cell array to hold test
test_stepout = {};

% Iterate through each participant
for p =exclude_indices
    cell_name = sprintf("M3X%03d_IMU_Parsed_SwappedAxes_01_WS", p);
    exercise_names = fieldnames(Participant_data{1, p}.(cell_name)); 
    num_exercises = length(exercise_names);

    % Iterate through each exercise
    for e = 1:numel(exercise_names)
        exercise = exercise_names{e};

        % Iterate through each trial
        for t = 1:num_trials
            trial = sprintf('trial%d', t); 
            Trial = sprintf('Trial%dPTRating', t); 
            if Participant_data{1, p}.(cell_name).(exercise).(trial).stepOutBinary == 1
                stepouts = Participant_data{1, p}.(cell_name).(exercise).(trial).stepOutTimes(1);
            else
                stepouts = 0;
            end
            test_stepout{end+1} = stepouts; 

        end
    end
end

%% Save stepouts for train, val, and test
save('M3X_training_stepouts.mat', 'training_stepout');
save('M3X_validation_stepouts.mat', 'validation_stepout');
save('M3X_test_stepouts.mat', 'test_stepout');

%% Save test set into a .mat file
% Save the test data and labels into a .mat file
save('M3X_test_trials.mat', 'test_data', 'test_labels');


%% Save all trial matrices into a single .mat file
save('M3X_training_trials_All_sensors_aw', 'training_data', 'training_labels', 'validation_data', 'validation_labels');
