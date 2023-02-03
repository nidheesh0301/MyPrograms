#multi level inheritance -> inherit base class to subclass and again to another subclass. In the child class all methods of base class will be available 
#multiple inheritance -> inherit multiple classes to one subclass 
#since we have display first in both First and Second class, left->right rule applies (ie, first search in left class then search in second class, 
# Prior to this the same class will be checked for the method name)


class First:
    def display(self):
        print("first")
class Second(First):
    def display(init):
        print("second")
class Third(First):
    def display_third(init):
        print("third")

x=Third()
x.display_third()
x.display()  