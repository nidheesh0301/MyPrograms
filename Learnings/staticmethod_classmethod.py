class Student:

    company="SAP"

    def __init__(self,m1,m2,m3):
        self.m1=m1
        self.m2=m2
        self.m3=m3
    def avg(self):
        return (self.m1 + self.m2 + self.m3 )/3
    @classmethod      #This is a keyword to add when we use a method common to the class not to the objects 
    def comp(cls):
        return cls.company 
    @staticmethod  #This is a static method, we dont need to pass any arguments 
    def static():
        print("i'm a static method in Student class")

obj1=Student(20,30,40)
print(obj1.avg())
print(Student.comp())
Student.static()
