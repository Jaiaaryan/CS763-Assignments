import torch
import sys
sys.path.append('src')
from imports import *
import numpy as np
import os

batchSize = 12  ## Sentence Length
lossClass = Criterion()
learningRate = 1

torch.set_default_tensor_type('torch.DoubleTensor')
torch.manual_seed(5)

def printAcc(start,batchSize):
	count = 0
	for i in range(batchSize):
		trial_data = data[start+i].view(1,-1)
		yPred = model.forward(trial_data)
		count += (int(yPred.view(1,-1).max(dim=1)[1])==int(labels[start+i]))
	print(count/batchSize)

def saveModel(fileToSave):
	global model
	file = open(fileToSave, 'wb')
	torch.save(model, file)
	file.close()
	return 

def getData(pathToData, pathToLabels):
	global data, labels
	train_data = open(pathToData,"r")
	train_labels = open(pathToLabels,"r")
	dictionary_file = open("src/for_dict.txt","r")

	dictionary = {}

	dictionary_opened = dictionary_file.readlines()

	for i in range(153):
		dictionary[int(dictionary_opened[i].split()[0])] = i

	data = train_data.readlines()
	labels = train_labels.readlines()
	num_sequences = len(data)
	
	for i in range(num_sequences):
		data[i] = torch.DoubleTensor([dictionary[int(x)] for x in data[i].split()])
		labels[i] = int(labels[i].split()[0])
			
	labels = torch.DoubleTensor(labels)

	train_data.close()
	train_labels.close()
	
		
def train(epoches,lr):
	global model,totalTrain
	totalTrain = len(data)
	for kkk in range(int(epoches)):
		batchLoss = 0
		permed = torch.randperm(totalTrain)
		counter = 0
		for j in range(totalTrain):
			i = permed[j]
			trial_data = data[i].view(1,-1)
			yPred = model.forward(trial_data)
			lossGrad, loss = lossClass.backward(yPred, torch.DoubleTensor([labels[i]]))
			batchLoss += (loss)
			model.backward(trial_data, lossGrad)
			counter+=1
			if counter==batchSize :
				for layer in model.Layers:
					if layer.isTrainable:
						layer.weight -= learningRate*(layer.gradWeight/batchSize)
						layer.bias -= learningRate*(layer.gradBias/batchSize)
				model.clearGradParam()
				counter = 0	
				print((totalTrain*kkk+j)//batchSize,batchLoss/batchSize)		
				batchLoss = 0	


def makeBestModel():
	model = Model(-1,128,153,153,1)
	return model


def trainModel():
	# 8 0 3 -1 6 -2 10 -6
	train(8,1)
	train(3,1e-1)
	printAcc(0,totalTrain)
	train(6,1e-2)
	printAcc(0,totalTrain)
	train(8,1e-6)
	printAcc(0,totalTrain)


def saveModel(fileToSave):
	global model
	file = open(fileToSave, 'wb')
	torch.save(model, file)
	file.close()
	return 
	
argumentList = sys.argv[1:]
arguments = {}
for i in range(int(len(argumentList)/2)):
	arguments[argumentList[2*i]] = argumentList[2*i + 1]
model = makeBestModel()
getData(arguments["-data"], arguments["-target"])
trainModel()

command = "mkdir " + arguments["-modelName"]
os.system(command)
fileToSave = arguments["-modelName"] + "/model.bin"
saveModel(fileToSave)


