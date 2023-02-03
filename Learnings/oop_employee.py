class Employee:
    

    def __init__(self,Empid):
        self.Empid=Empid

    def checkname(self):
        print('My Employee id is', self.Empid)
obj1=Employee('i502493')
obj1.checkname()



