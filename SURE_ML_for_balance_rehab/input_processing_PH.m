%% input processing for M3X data
clear;
clc;
close all;

%% Load all participant data
numFiles = 47; % Total number of files
Participant_data = cell(1, numFiles);

for k = 1:numFiles
    tic
    filename = sprintf("PH%03d_IMU_Parsed_SwappedAxes_01_WS.mat", k);
    Participant_data{k} = load(filename);
    toc
end

%% Load the Excel file
excelFile = "PH Weight Shifting Ratings Simplified 060225.xlsx";
dataTable = readtable(excelFile);

%% Extract step-out info
participant_indices = 1:47; 
exclude_indices = [41, 42, 43]; % test set
% exclude_indices = []; 
filtered_indices = setdiff(participant_indices, exclude_indices);
num_trials = 3;

% Initialize a cell array to hold training data and labels
training_stepout = {};
% Initialize a cell array to hold validation data and labels
validation_stepout = {};

% Set the random seed for reproducibility
rng(445); 

% Randomly select 20% of participants for validation
num_validation = round(0.2 * length(filtered_indices));
validation_indices = setdiff(randperm(length(participant_indices), num_validation), exclude_indices);


% Iterate through each participant
for p = filtered_indices
    cell_name = "IMUParsed";
    exercise_names = fieldnames(Participant_data{1, p}.(cell_name)); 
    num_exercises = length(exercise_names);

    % Iterate through each exercise
    for e = 1:numel(exercise_names)
        exercise = exercise_names{e};

        % Iterate through each trial
        for t = 1:num_trials
            trial = sprintf('trial%d', t); 
            Trial = sprintf('Trial%d', t); 
            if Participant_data{1, p}.(cell_name).(exercise).(trial).stepOutBinary == 1
                stepouts = Participant_data{1, p}.(cell_name).(exercise).(trial).stepOutTimes(1);
            else
                stepouts = 0;
            end
            % Store step-out information for training or validation
            if ismember(p, validation_indices)
                validation_stepout{end+1} = stepouts; % Add to validation set
            else
                training_stepout{end+1} = stepouts; % Add to training set
            end
        end
    end
end

%% Save the training and val step-outs
% Save training step-out information
save('PH_training_stepouts.mat', 'training_stepout');

% Save validation step-out information
save('PH_validation_stepouts.mat', 'validation_stepout');

%% check class imbalance for WSR exercises
% Initialize counts for each class (1 to 5)
classCountsWSR = zeros(5, 1);

% Loop through training labels to count occurrences of each class for 'WSR' exercises
for p = 1:47
    cell_name = "IMUParsed";
    exercise_names = fieldnames(Participant_data{1, p}.(cell_name)); 

    for e = 1:numel(exercise_names)
        exercise = exercise_names{e};

        % Check if the exercise name starts with 'WSR'
        if startsWith(exercise, 'WSR')
            for t = 1:num_trials
                labels = training_labels{p, e, t}; % Get the labels for the current trial

                % Count occurrences of each class
                for class = 1:5
                    classCountsWSR(class) = classCountsWSR(class) + sum(labels == class);
                end
            end
        end
    end
end

% Display the counts for each class for 'WSR' exercises
disp('WSR Class Counts:');
disp(table((1:5)', classCountsWSR, 'VariableNames', {'Class', 'Count'}));

% Plot WSR class counts
figure; 
bar(classCountsWSR); 
xlabel('Class');
ylabel('Count');
title('WSR Class Counts');
grid on;


%% visualize class imbalance for the original file
% Initialize counts for each class (1 to 5)
classCounts = zeros(5, 1);

% Loop through each trial column and count occurrences of each class
for trial = 1:3
    trialColumn = dataTable{:, sprintf('Trial%d', trial)};
    for class = 1:5
        classCounts(class) = classCounts(class) + sum(trialColumn == class);
    end
end

% Display the counts for each class
disp('Class Counts:');
disp(table((1:5)', classCounts, 'VariableNames', {'Class', 'Count'}));

%%
% plot train and validation class counts
figure; 
bar(classCountsTrain); 
xlabel('Class');
ylabel('Count');
title('Training Class Counts');
grid on;

% Plot validation class counts in another separate figure
figure; 
bar(classCountsValidation); 
xlabel('Class');
ylabel('Count');
title('Validation Class Counts');
grid on;

%% Initialize parameters, train-val split, stack sensors
sensor_list = ["head", "uback", "lumbar", "rarm", "larm", "rwrist", "lshank", "rshank", "rfoot", "lwrist", "lfoot", "rthigh", "lthigh"];
num_trials = 3; % Assuming each exercise has 3 trials
num_sensors = length(sensor_list);
participant_indices = 1:47; 
exclude_indices = [41, 42, 43]; % test set
filtered_indices = setdiff(participant_indices, exclude_indices);

% Initialize cell arrays to hold training and validation data and labels
training_data = {};
training_labels = {};
training_stepout = {};
validation_data = {};
validation_labels = {};
validation_stepout = {};

% Set the random seed for reproducibility
rng(445); 

% Randomly select 20% of participants for validation
num_validation = round(0.2 * length(filtered_indices));
validation_indices = setdiff(randperm(length(participant_indices), num_validation), exclude_indices);

% Iterate through each participant
for p = filtered_indices
    cell_name = "IMUParsed";
    exercise_names = fieldnames(Participant_data{1, p}.(cell_name)); 
    num_exercises = length(exercise_names);

    % Iterate through each exercise
    for e = 1:numel(exercise_names)
        exercise = exercise_names{e};

        % Iterate through each trial
        for t = 1:num_trials
            trial = sprintf('trial%d', t); 
            Trial = sprintf('Trial%d', t); 
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
            subjectID = sprintf("PH%03d", p); 
            subjectID_matches = strcmp(dataTable.SubjectID, subjectID); 
            exerciseID_matches = strcmp(dataTable.ExerciseID, exerciseID); 
            combined_matches = subjectID_matches & exerciseID_matches; 
            labels = dataTable{combined_matches, Trial};

            % Check for missing labels and exclude NaN values
            labels = labels(~isnan(labels)); % Keep only non-hyphen labels

            % Extract step-out information
            if Participant_data{1, p}.(cell_name).(exercise).(trial).stepOutBinary == 1
                stepouts = Participant_data{1, p}.(cell_name).(exercise).(trial).stepOutTimes(1);
            else
                stepouts = 0;
            end

            % Proceed with valid_labels for further processing
            if ~isempty(labels) % Check if there are any valid labels left
                % Store in validation set if participant is in validation list
                if ismember(p, validation_indices)
                    validation_data{end+1} = trial_data; % Store trial data
                    validation_labels{end+1} = labels; % Store the corresponding label
                    validation_stepout{end+1} = stepouts; % Add to validation set
                else
                    training_data{p, e, t} = trial_data; % Store trial data
                    training_labels{p, e, t} = labels; % Save the trial label
                    training_stepout{end+1} = stepouts; % Add to training set
                end
            end
        end                           
    end
end

%% visualize class imbalance for data after train-val split

% Initialize an array to hold the rounded means for training labels
roundedTrainingLabels = cell(size(training_labels));

% Loop through each cell in the training_labels array
for i = 1:size(training_labels, 1)
    for j = 1:size(training_labels, 2)
        for k = 1:size(training_labels, 3)
            % Extract the current cell's label array
            labelArray = training_labels{i, j, k};

            % Calculate the mean and round it to the nearest integer
            if ~isempty(labelArray) % Check if the cell is not empty
                roundedTrainingLabels{i, j, k} = round(mean(labelArray));
            else
                roundedTrainingLabels{i, j, k} = NaN; % Handle empty cells
            end
        end
    end
end

% For validation labels, which is a 1x58 cell array
roundedValidationLabels = cellfun(@(x) round(mean(x)), validation_labels, 'UniformOutput', false);


% Initialize counts for each class (1 to 5)
classCountsTrain = zeros(5, 1);
classCountsValidation = zeros(5, 1);
% Count occurrences of each class in validation labels
for class = 1:5
    classCountsValidation(class) = sum(cell2mat(roundedValidationLabels) == class);
end

% Count occurrences of each class in training labels
for class = 1:5
    classCountsTrain(class) = sum(cell2mat(roundedTrainingLabels) == class,"all", 'omitnan');
end
% Display the counts for each class
disp('Training Class Counts:');
disp(table((1:5)', classCountsTrain, 'VariableNames', {'Class', 'Count'}));

disp('Validation Class Counts:');
disp(table((1:5)', classCountsValidation, 'VariableNames', {'Class', 'Count'}));

%% Test set out-saved
% Initialize a cell array to hold test data and labels
test_data = {};
test_labels = {};

% Iterate through each participant
for p = exclude_indices
    cell_name = "IMUParsed";
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
            subjectID = sprintf("PH%03d", p); 
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

%% Test step-outs extract
% Iterate through each participant
test_stepout = {};
for p = exclude_indices
    cell_name = "IMUParsed";
    exercise_names = fieldnames(Participant_data{1, p}.(cell_name)); 
    num_exercises = length(exercise_names);

    % Iterate through each exercise
    for e = 1:numel(exercise_names)
        exercise = exercise_names{e};
        if p == 42 && (exercise == "WS23" || exercise == "WS19")
            continue;
        end

        % Iterate through each trial
        for t = 1:num_trials
            trial = sprintf('trial%d', t); 
            Trial = sprintf('Trial%d', t); 
            if Participant_data{1, p}.(cell_name).(exercise).(trial).stepOutBinary == 1
                stepouts = Participant_data{1, p}.(cell_name).(exercise).(trial).stepOutTimes(1);
            else
                stepouts = 0;
            end
            % Store step-out information for test
            test_stepout{end+1} = stepouts; 

        end
    end
end

%% Test step-outs save
save('PH_test_stepouts.mat', 'test_stepout');

%% Save test set into a .mat file
% Save the test data and labels into a .mat file
save('PH_test_trials.mat', 'test_data', 'test_labels');

%% Save all trial matrices into a single .mat file
save('PH_training_trials_All_sensors_aw', 'training_data', 'training_labels', 'validation_data', 'validation_labels');