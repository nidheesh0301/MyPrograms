class Student:
    def __init__(self, name, rollno):
        self.name=name
        self.rollno=rollno 
        self.obj2=self.dept()   #inner class has to be added like this
    
    def show(self):
        print(self.name, self.rollno)
        self.obj2.show()    #calling the inner class here 

    class dept:
        def __init__(self):
            self.subject='mca'
        def show(self):
            print(self.subject)

obj1=Student('Nidheesh','i502493')
obj1.show()



        