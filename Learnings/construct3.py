#self is a pointer which directs object to the method ie; when we call x.display() x will go as an argument to self method 

class CrossroadsTeamMember:
    year=2020  #this is a class variable, this will be updated if any method updates this value 
    def __init__(self, name, age, place):
        self.name=name
        self.age=age
        self.place=place
    def add_age(self):
        self.age=self.age+1
    def relocate(self, place):
        self.place=place
    def display(self):
        print('Current year:'+str(CrossroadsTeamMember.year))
        print('Name:' +self.name)
        print("age:" +str(self.age))
        print("place: "+self.place)
    @classmethod    #a method which is applicable for all methods in the program 
    def add_year(cls):
        cls.year=cls.year+1
    @staticmethod    #used when we need something static function to be used in the program
    def welcome_display():
        print("----Welcome to the python basics-------")


x=CrossroadsTeamMember('Nid',21,'kuttippuram')
y=CrossroadsTeamMember('vig',20,'tvm')

CrossroadsTeamMember.welcome_display()
x.display()
y.display()

print("..............year passed....!")

CrossroadsTeamMember.year=CrossroadsTeamMember.year+1
x.add_age()
y.add_age()


x.display()
y.display()

print("calling class method here -------")

CrossroadsTeamMember.add_year() 
x.add_age()
y.add_age()
x.relocate("delhi")
y.relocate("Budapest")

x.display()
y.display()



