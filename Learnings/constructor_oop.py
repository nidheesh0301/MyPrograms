class Computer:
    job = "DBA"   #this is called class variables, and if we declare somethign inside init, then its called instance variable 
    def __init__(self):
        self.name='Nidheesh'
        self.age='18'
    def compare(self, obj2):
        if self.age==obj2.age:
            print("age is same")
        else:
            print("age is different")
obj1=Computer()
Obj2=Computer()
Obj2.age='20'
obj1.compare(Obj2)
print(obj1.age)
print(Obj2.age)
print(obj1.job)