import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Bidirectional, LSTM, Dense, Dropout, Masking
from tensorflow.keras.preprocessing.sequence import pad_sequences
from tensorflow.keras.mixed_precision import Policy, set_global_policy
from tensorflow.keras.callbacks import EarlyStopping
from tensorflow.keras.callbacks import ModelCheckpoint, Callback, TensorBoard
import matplotlib.pyplot as plt
import scipy.io
import random
import os

seed = 42 

# Set Python random seed
random.seed(seed)
# Set NumPy random seed
np.random.seed(seed)
# Set TensorFlow random seed
tf.random.set_seed(seed)
# (Optional) Set PYTHONHASHSEED environment variable for reproducibility in hashing
os.environ['PYTHONHASHSEED'] = str(seed)

# Set the mixed precision policy
policy = Policy('mixed_float16')
set_global_policy(policy)

# Load the .mat file
mat_file_path = r'/home/liuxt/M3X_PH_WS/M3X_training_trials_All_sensors_aw.mat'
M3X_data = scipy.io.loadmat(mat_file_path)

PH_mat_file_path = r"/home/liuxt/M3X_PH_WS/PH_training_trials_All_sensors_aw.mat"
PH_data = scipy.io.loadmat(PH_mat_file_path)
# Print the keys to see what variables are in the file
print(M3X_data.keys())
print(PH_data.keys())

# Access the data and labels
all_trial_matrices = M3X_data['training_data']
trial_labels = M3X_data['training_labels']

ph_trial_matrices = PH_data['training_data']
ph_trial_labels = PH_data['training_labels']

# Access the validation sets
M3X_val_matrices = M3X_data['validation_data']
M3X_val_labels = M3X_data['validation_labels']
PH_val_matrices = PH_data['validation_data']
PH_val_labels = PH_data['validation_labels']

# Print shapes for confirmation
print("M3X data shape:", all_trial_matrices.shape)
print("PH data shape:", ph_trial_matrices.shape)
print("M3X labels shape:", trial_labels.shape)
print("PH labels shape:", ph_trial_labels.shape)
print("M3X validation data shape:", M3X_val_matrices.shape)
print("M3X validation labels shape:", M3X_val_labels.shape)
print("PH validation data shape:", PH_val_matrices.shape)
print("PH validation labels shape:", PH_val_labels.shape)

# Concatenate along the first axis (subjects)
training_data_combined = np.concatenate((all_trial_matrices, ph_trial_matrices), axis=0)
training_labels_combined = np.concatenate((trial_labels, ph_trial_labels), axis=0)

# Combine validation sets
val_matrices_combined = np.concatenate((M3X_val_matrices, PH_val_matrices), axis=1)
val_labels_combined = np.concatenate((M3X_val_labels, PH_val_labels), axis=1)

print("Combined data shape:", training_data_combined.shape)
print("Combined labels shape:", training_labels_combined.shape)
print("Combined validation data shape:", val_matrices_combined.shape)
print("Combined validation labels shape:", val_labels_combined.shape)

# add a new feature (the timestamp of the first stepout) to the last linear layer 

# import the step-outs for training and validation sets
M3X_training_stepouts_file_path = r'/home/liuxt/M3X_PH_WS/M3X_training_stepouts.mat'
M3X_training_stepouts = scipy.io.loadmat(M3X_training_stepouts_file_path)['training_stepout']
PH_training_stepouts_file_path = r"/home/liuxt/M3X_PH_WS/PH_training_stepouts.mat"
PH_training_stepouts = scipy.io.loadmat(PH_training_stepouts_file_path)['training_stepout']
# Combine stepouts
training_stepouts_combined = np.concatenate((M3X_training_stepouts, PH_training_stepouts), axis=1)
# Combine validation stepouts
M3X_val_stepouts_file_path = r'/home/liuxt/M3X_PH_WS/M3X_validation_stepouts.mat'
M3X_val_stepouts = scipy.io.loadmat(M3X_val_stepouts_file_path)['validation_stepout']
PH_val_stepouts_file_path = r"/home/liuxt/M3X_PH_WS/PH_validation_stepouts.mat"
PH_val_stepouts = scipy.io.loadmat(PH_val_stepouts_file_path)['validation_stepout']
# Combine validation stepouts
val_stepouts_combined = np.concatenate((M3X_val_stepouts, PH_val_stepouts), axis=1)

# Print shapes for confirmation
print("Combined training stepouts shape:", training_stepouts_combined.shape)
print("Combined validation stepouts shape:", val_stepouts_combined.shape)

# convert the stepouts to an array
training_stepouts_combined = np.array(training_stepouts_combined)
val_stepouts_combined = np.array(val_stepouts_combined)


# parameters init & X_tensor / y_tensor processing

features = training_data_combined[0][0][0].shape[1]  # Number of features in each trial matrix
units = 8  # LSTM units
dropout_rate = 0.5  # Dropout rate
num_classes = 5  # Number of classes for classification 1 - 5 rating
# Initialize lists to hold the extracted data
X_list = []
y_list = []

# Loop through each cell in all_trial_matrices
for subject in training_data_combined:
    for exercise in subject:
        for trial in exercise:
            if trial.size > 0:  # Check if the session is not empty
                # Convert session to a numpy array and ensure it has the correct shape
                trial_array = np.array(trial)
                # Check if the session has enough dimensions
                if trial_array.ndim == 1:
                    trial_array = trial_array.reshape(-1, features)
                # if trial_array.shape[0] > 30000: #check if the session is too long
                #     continue
                X_list.append(trial_array)



# Compute mean and std for each feature across all data, ignoring NaNs
all_data = np.concatenate(X_list, axis=0)
feature_means = np.nanmean(all_data, axis=0)
feature_stds = np.nanstd(all_data, axis=0)
feature_stds[feature_stds == 0] = 1  # Prevent division by zero

X_list_norm = []
for x in X_list:
    x_norm = x.copy()
    # Normalize each feature independently, ignoring NaNs
    for f in range(x.shape[1]):
        mask = ~np.isnan(x[:, f])
        x_norm[mask, f] = (x[mask, f] - feature_means[f]) / feature_stds[f]
    # After normalization, set any remaining NaNs (missing sensors) to 0
    x_norm[np.isnan(x_norm)] = 0
    X_list_norm.append(x_norm)

# Pad sequences to the same length
# max_sequence_length = max(seq.shape[0] for seq in X_list_norm)
max_sequence_length = 15000
X_padded = pad_sequences(X_list_norm, maxlen=max_sequence_length, padding='post', dtype='float32', value=0)


# Normalize the validation data using training set statistics
X_val_list = []
for trial in val_matrices_combined[0]:
            if trial.size > 0:
                trial_array = np.array(trial)
                if trial_array.ndim == 1:
                    trial_array = trial_array.reshape(-1, features)
                trial_norm = trial_array.copy()
                for f in range(trial_array.shape[1]):
                    mask = ~np.isnan(trial_array[:, f])
                    trial_norm[mask, f] = (trial_array[mask, f] - feature_means[f]) / feature_stds[f]
                trial_norm[np.isnan(trial_norm)] = 0
                X_val_list.append(trial_norm)

X_val_padded = pad_sequences(X_val_list, maxlen=max_sequence_length, padding='post', dtype='float32', value=0)

# Label fusion for PH data
y_list = []
counter = 0
for subject in training_labels_combined:
    counter += 1
    if counter == 18:
         print("M3X labels: ", len(y_list))
    for exercise in subject:
        for trial in exercise:
            if trial.size > 0:  # Check if the session is not empty
                # Convert to float array, ignore NaNs in averaging
                trial_arr = np.array(trial, dtype=float)
                avg_label = np.nanmean(trial_arr)
                rounded_label = int(np.rint(avg_label))
                y_list.append(rounded_label)

# Label fusion for validation set
y_val_list = []
for trial in val_labels_combined[0]:
            if trial.size > 0:  # Check if the session is not empty
                trial_arr = np.array(trial, dtype=float)
                avg_label = np.nanmean(trial_arr)
                rounded_label = int(np.rint(avg_label))
                y_val_list.append(rounded_label)

print("Number of training samples:", len(X_padded))
print("Number of validation samples:", len(X_val_padded))
print("y_list:", len(y_list))
print("y_val_list:", len(y_val_list))

# convert validation set and labels into tensors
X_val_tensor = tf.convert_to_tensor(X_val_padded, dtype=tf.float32)
y_val_tensor = tf.convert_to_tensor(y_val_list, dtype=tf.int32)
stepout_val_tensor = tf.convert_to_tensor(val_stepouts_combined, dtype=tf.float32)

# Oversample minority classes to deal with class imbalance

from collections import Counter
from sklearn.utils import resample

# Convert X_list_norm and y_list to numpy arrays for easier indexing
X_array = X_padded
y_array = np.array(y_list)

# Count samples per class
class_counts = Counter(y_array)
max_count = max(class_counts.values())

X_resampled = []
y_resampled = []
stepouts_resampled = []

# Oversample each class to match the size of the largest class
for cls in np.unique(y_array):
    idx = np.where(y_array == cls)[0]
    X_cls = X_array[idx]
    y_cls = y_array[idx]
    st_cls = training_stepouts_combined.T[idx]
    X_upsampled, y_upsampled, stepouts_upsampled = resample(
        X_cls, y_cls, st_cls,
        replace=True,
        n_samples=max_count,
    )
    X_resampled.extend(X_upsampled)
    y_resampled.extend(y_upsampled)
    stepouts_resampled.extend(stepouts_upsampled)

# Shuffle the resampled data
combined = list(zip(X_resampled, y_resampled, stepouts_resampled))
np.random.shuffle(combined)
X_resampled, y_resampled, stepouts_resampled = map(np.array, zip(*combined))

# Convert to tensors
X_tensor   = tf.convert_to_tensor(X_resampled, dtype=tf.float32)
y_tensor   = tf.convert_to_tensor(y_resampled, dtype=tf.int32)
stepout_tensor = tf.convert_to_tensor(stepouts_resampled, dtype=tf.float32)

# Model architecture
units = 8
input_layer = Input(shape=(max_sequence_length, features), name='input_layer')
masking_layer = Masking(mask_value=0, input_shape=(max_sequence_length, features))(input_layer)  # Mask padding
# bilstm1 = Bidirectional(LSTM(units=units, return_sequences=True))(masking_layer)
# layernorm1 = tf.keras.layers.LayerNormalization()(bilstm1)
dropout = Dropout(dropout_rate)(masking_layer)
bilstm2 = Bidirectional(LSTM(units=units))(dropout)
layernorm2 = tf.keras.layers.LayerNormalization()(bilstm2)
stepout  = Input(shape=(1,), name='stepout') 
merged = tf.keras.layers.Concatenate()([layernorm2, stepout])  # Concatenate LSTM output with stepout
output_layer = Dense(1, activation='linear')(merged)  # Only 1 output neuron for regression

model = Model(inputs=[input_layer,stepout], outputs=output_layer)

# Checkpoint callback class to save the model every epoch

checkpoint_cb = ModelCheckpoint(
    filepath='/home/liuxt/M3X_PH_WS/checkpoints/BiLSTM_resample_alltrain_epoch{epoch:02d}.keras',
    save_weights_only=False,
    save_best_only=False
)

# training

# Set batch size
batch_size = 32

# Compile with regression loss
model.compile(
    optimizer='adam',
    loss='mean_absolute_error',  # or 'mean_absolute_error'
    metrics=['mse']
)
model.summary()

# Make sure labels are float
y_tensor = tf.cast(y_tensor, tf.float32)
y_val_tensor = tf.cast(y_val_tensor, tf.float32)
stepout_tensor     = tf.reshape(stepout_tensor,     [-1, 1])
stepout_val_tensor = tf.reshape(stepout_val_tensor, [-1, 1])

# Build the model
model.build(input_shape=(None, max_sequence_length, features))  # (batch_size, timesteps, features)

# Train the model with early stopping, using X_tensor/y_tensor for training and X_val_tensor/y_val_tensor for validation
early_stop = EarlyStopping(monitor='val_loss', patience=3)

record = model.fit(
    {'input_layer': X_tensor, 'stepout': stepout_tensor},
    y_tensor,
    epochs=70,
    batch_size=batch_size,
    validation_data=({'input_layer': X_val_tensor,
                      'stepout': stepout_val_tensor},
                     y_val_tensor),
    callbacks=[early_stop, checkpoint_cb],
)