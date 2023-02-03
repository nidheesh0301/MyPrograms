#operator over loading means replacing the arithmetic operators using inbuilt functions 
#Firstname.name will go as the first argument to the init function 
#secondname.name will go as second argument to the init function


class sample:
    def set_name(self,name):
        self.name=name

    def __add__(self,arg2):
        full_name=self.name+" " +arg2.name
        return full_name

x=sample()
y=sample()

x.set_name("Nidheesh")
y.set_name("kadhaliyil")

complete_name=x+y
print(complete_name)
