class MyFirstClass:
    def hello(self,n):   #self is an argument,  name of it can be anything 
        self.name=n
    def print_name(self):
        print(self.name)
x=MyFirstClass()
y=MyFirstClass()

name='Nidheesh K'

x.hello(name)  #same as MyfirstClass.hello(x)
y.hello('Vignesh')

x.print_name()
y.print_name()
