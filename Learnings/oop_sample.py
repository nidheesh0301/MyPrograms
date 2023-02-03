class Cars:
    def __init__(self,name, price, color):
        self.name=name
        self.price=price
        self.color=color
    def start(self):
        print(self.name + "started")

X=Cars("BMW","10M","black")
Y=Cars("Rols","1B","white")



#del X.color   -> this is how we can delete an attribute
#del Y   -> this is how we can delete an object 

print(X.color, X.name,X.price)
print(Y.color, Y.name,Y.price)

print(id(X)) #to find the memory address of object X