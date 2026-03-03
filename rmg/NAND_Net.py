
# 3-Layer Neural Network for a NAND Gate

import math
import numpy as np
import scipy.special as sp  # For the sigmoid function expit()

def sig_deriv(x):
    return math.exp(-x) / ( (1 + math.exp(-x))**2 )

vec_sig_deriv = np.vectorize(sig_deriv)

class NeuralNet:
    def __init__(self, inputnodes, hiddennodes, outputnodes, learningrate):
        # Set number of nodes in each layer
        self.inodes = inputnodes
        self.hnodes = hiddennodes
        self.onodes = outputnodes

        # Weight matrices 'input -> hidden' & 'hidden-> output'
        self.wih = np.array([[ 0.9, -0.2],
                             [ 0.7,  0.3],
                             [-0.5, -0.7],
                             [ 0.1, -0.6],
                             [-0.4,  0.2]])

        self.who = np.array([[-0.9,  0.2,  0.6, -0.2, 0.1],
                             [ 0.7, -0.4, -0.3,  0.2, 0.6]])

        # Learning rate
        self.lr = learningrate

        # The activation function is the sigmoid function
        self.activation_fn = lambda x: sp.expit(x)

    # Train the neural network
    def train(self, inputs_list, targets_list):
        # Convert lists to 2d arrays
        inputs = np.array(inputs_list, ndmin=2).T
        targets = np.array(targets_list, ndmin=2).T

        # Calculate signals into the hidden layer
        hidden_inputs = np.dot(self.wih, inputs)
        # Calculate the signals from the hidden layer
        hidden_outputs = self.activation_fn(hidden_inputs)

        # Calculate signals into the output layer
        final_inputs = np.dot(self.who, hidden_outputs)
        # Calculate the signals from the output layer
        final_outputs = self.activation_fn(final_inputs)

        # The output error is: target - actual
        output_errors = targets - final_outputs
        # The hidden layer error is the output_errors, split by weights, recombined at the hidden nodes
        hidden_errors = np.dot(self.who.T, output_errors)

        # Update the weights between the hidden & output layers
        final_in_back = vec_sig_deriv(final_inputs)
        self.who += self.lr * np.dot((output_errors * final_in_back), np.transpose(hidden_outputs))

        # Update the weights between the input & hidden layers
        hidden_in_back = vec_sig_deriv(hidden_inputs)
        self.wih += self.lr * np.dot((hidden_errors * hidden_in_back), np.transpose(inputs))

    # Query the neural network
    def query(self, inputs_list):
        # Convert list to a 2d array
        inputs = np.array(inputs_list, ndmin=2).T

        # Calculate signals into the hidden layer
        hidden_inputs = np.dot(self.wih, inputs)
        # Calculate signals from the hidden layer
        hidden_outputs = self.activation_fn(hidden_inputs)

        # Calculate signals into the output layer
        final_inputs = np.dot(self.who, hidden_outputs)
        # Calculate signals from the output layer
        final_outputs = self.activation_fn(final_inputs)

        return final_outputs

# Create the neural network
input_nodes = 2
hidden_nodes = 5
output_nodes = 2
learning_rate = 0.5

net = NeuralNet(input_nodes, hidden_nodes, output_nodes, learning_rate)

# Load the training data
training_data_list = [[0,0,0.01,0.99], [0,1,0.01,0.99], [1,0,0.01,0.99], [1,1,0.99,0.01]]

# Train the network, where 'epochs' is the number of times the training dataset is used
epochs = 1
for _ in range(epochs):
    for record in training_data_list:
        # Scale & shift the inputs
        inputs = np.array(record[:2], dtype=float) * 0.99 + 0.01
        # Create the target output values
        targets = np.zeros(output_nodes)
        targets[0] = record[2]
        targets[1] = record[3]
        # Update the network weights
        net.train(inputs, targets)

# Load the test data
test_data_list = [[0,0,0.01,0.99], [0,1,0.01,0.99], [1,0,0.01,0.99], [1,1,0.99,0.01]]

# Test the neural network
scorecard = []
'''
net.wih = np.array([[ 3.79213578, -8.51045568],
                    [ 7.66299405, -3.41941666],
                    [ 0.40620045, -2.6490232 ],
                    [ 3.18404165, -7.3792833 ],
                    [-8.40486461,  3.80623094]])

net.who = np.array([[-3.62182705,  3.22362353, -1.19626314, -2.59896118, -3.43382837],
                    [ 3.56334152, -3.24647641,  1.32823989,  2.61237492,  3.43381549]])
'''
print('WIH\n',net.wih)
print('WHO\n',net.who)

for record in test_data_list:
    # The correct answer is the 1st value
    correct_label = 0
    if record[3] > record[2]:
        correct_label = 1
    # Scale & shift the inputs
    inputs = np.array(record[:2], dtype=float) * 0.99 + 0.01
    # Query the network
    outputs = net.query(inputs)
    print('OUT\n',outputs)
    # The index of the highest value corresponds to the label
    label = np.argmax(outputs)
    # Update the 'scorecard'
    if label == correct_label:
        scorecard.append(1)
    else:
        scorecard.append(0)

# Display the performance score
scorecard_array = np.asarray(scorecard)
perf = scorecard_array.sum() / scorecard_array.size
print(f'Performance = {perf}')

