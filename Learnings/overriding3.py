#here we are calling the base class function directly using super() in construction init function and the method setname 

class BaseClass:
    def __init__(self):
        print(" this is base class construction function")

    def set_name(self,name):
        print("this is my base class set name function")
        self.name=name

class subclass(BaseClass):

    def __init__(self):
        print("this is subclass constructor function")
        super().__init__()

    def set_name(self,name):
        print("this is my sub class setname function")
        super().set_name(name)

    def welcome(self):
        print("welcome to my program")

    def display_name(self):
        print("my name is "+self.name)

y=subclass()
y.welcome()
y.set_name("Nidheesh")  #this function is inherited from baseclass 
y.display_name()
