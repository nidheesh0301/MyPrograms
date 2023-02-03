#multi level inheritance -> inherit base class to subclass and again to another subclass. In the child class all methods of base class will be available 
#multiple inheritance -> inherit multiple classes to one subclass 
class First:
    def display_first(self):
        print("first")
class Second(First):
    def dispay_second(init):
        print("second")
class Third(First):
    def display_third(init):
        print("third")

x=Third()
x.display_third()
x.display_first()