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
    @classmethod
    def add_year(cls):
        cls.year=cls.year+1


x=CrossroadsTeamMember('Nid',21,'kuttippuram')
y=CrossroadsTeamMember('vig',20,'tvm')

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

x.display()
y.display()



