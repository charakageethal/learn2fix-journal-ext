from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn import tree
from sklearn.naive_bayes import GaussianNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import RandomForestClassifier,AdaBoostClassifier
from sklearn.neural_network import MLPClassifier
import numpy as np

class CustomClassifier:

	def __init__(self,class_type):
		self.__classifier=None
		self.__class_type=class_type


	def train(self,train_data,train_labels):
		classfier_class=np.array([1 if l else 0 for l in train_labels])

		if(np.sum(train_labels)==0):
			self.__classifier=False
		elif(np.sum(train_labels)==train_labels.size):
			self.__classifier=True
		else:
			if self.__class_type=="SVM":
				classifier=make_pipeline(StandardScaler(),SVC(gamma='auto'))
			elif (self.__class_type=="DCT"):
				classifier=DecisionTreeClassifier()
			elif (self.__class_type=="NB"):
				classifier=GaussianNB()
			elif(self.__class_type=="MLP-20"):
				classifier=MLPClassifier(hidden_layer_sizes=(20,))
			elif(self.__class_type=="MLP-20-5"):
				classifier=MLPClassifier(hidden_layer_sizes=(20,5))
			elif(self.__class_type=="ADB"):
				classifier=AdaBoostClassifier(n_estimators=100,random_state=0)

			classifier.fit(train_data,classfier_class)
			self.__classifier=classifier


	def predict(self,test_inputs):
		if(np.size(test_inputs,0)>1):
			if (self.__classifier==False):
				return np.array([False for i in test_inputs])
			elif(self.__classifier==True):
				return np.array([True for i in test_inputs])
			else:
				classifier_predict=self.__classifier.predict(test_inputs)
				predicted_labels=[True if i==1 else False for i in classifier_predict]
				return predicted_labels
		else:
			if(self.__classifier==False):
				return False
			elif(self.__classifier==True):
				return True
			else:
				classifier_predicted=self.__classifier.predict(test_inputs)[0]
				if classifier_predicted==1:
					return True
				else:
					return False








