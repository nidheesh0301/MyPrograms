#with inheritance we can use method from base class in subclass 
class BaseClass:
    def set_name(self,name):
        print("this is my base class function")
        self.name=name

class subclass(BaseClass):

    def welcome(self):
        print("welcome to my program")

    def display_name(self):
        print("my name is "+self.name)


y=subclass()
y.welcome()

y.set_name("Nidheesh")  #this function is inherited from baseclass 
y.display_name()
