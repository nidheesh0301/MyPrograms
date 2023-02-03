#construction overriding -> sub class constructor will override the base class constructor init function 
#in following program when we have 2 constructors only the subclass constructor will be called as it has the precendence over main class 

class BaseClass:
    def __init__(self):
        print(" this is base class construction function")

    def set_name(self,name):
        print("this is my base class function")
        self.name=name

class subclass(BaseClass):

    def __init__(self):
        print("this is subclass constructor function")

    def welcome(self):
        print("welcome to my program")

    def display_name(self):
        print("my name is "+self.name)

y=subclass()
y.welcome()
y.set_name("Nidheesh")  #this function is inherited from baseclass 
y.display_name()
