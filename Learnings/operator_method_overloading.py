#program is workng, but not understanding why self.m1 is different in two functions 
class Student:
    def __init__(self, m1,m2):
        self.m1=m1
        self.m2=m2

    def __add__(self, other):
        m1=self.m1 + other.m1
        m2=self.m2 + other.m2
        print("self.m1 is", self.m1)
        print("other.m1 is", other.m1)
        print("self.m2 is: " ,self.m2)
        print("other.m2 is",other.m2)
        s3=Student(m1,m2)
        return s3 

    def __gt__(self, other):
        print("im self.m1", self.m1)
        print("im self.m2", self.m2)
        print("im other.m1", other.m1)
        print("im other.m2", other.m2)
        R1=self.m1+self.m2
        R2=other.m1+other.m2
        if R1 > R2:
            return True
        else:
            return False


S1 = Student(1,2)
S2 = Student(2,4)
S3=S2+S1

print("S3.m1 is" , S3.m1)
print("S3.m2 is" , S3.m2)

if S1 > S2:
    print("S1 wins")
else:
    print("S2 wins")