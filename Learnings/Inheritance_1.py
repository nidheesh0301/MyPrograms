#with inheritance we can use method from base class in subclass 
class BaseClass:
    def display(self):
        print("this is my base class function")
class SubClass(BaseClass):
    def welcome(self):
        print(" this is my subclass function")
x=BaseClass()
x.display()

y=SubClass()
y.welcome()
y.display()  #this function is from base class 

