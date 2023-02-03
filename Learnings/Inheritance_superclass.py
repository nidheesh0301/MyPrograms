class A:
    def __init__(self):
        print("I'm class A constructor")
    def feature(self):
        print("i'm class A function" )
class B():

    def __init__(self):
        super().__init__()
        print("I'm class B constructor")

    def feature(self):
        print("im  class B function ")

class C(A,B):
    def __init__(self):
        print("I'm class C constructor")

    def feature(self):
        print("im  class C function ")

obj2=C()
obj2.feature()