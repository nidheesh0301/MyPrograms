class MyComputer:
    
    def __init__(self, cpu, ram):
        self.cpu=cpu
        self.ram=ram
    def config_show(self):
        print("Config of my system is ", self.cpu, self.ram )
obj1=MyComputer(32,16)
obj2=MyComputer(64,32)

obj1.config_show()
obj2.config_show()
