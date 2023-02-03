from collections import abc


a=5
b=10

try:
    print("opening resource")
    print("output of a/b is :" , a/b)
    k=int(input("enter a number: "))
    print(k)
except ZeroDivisionError as e:
    print('cant be divided by zero',e)
except ValueError as e:
    print('invalid input..! Error discription:',e)
except Exception as e:
    print("something went wrong")

finally:
    print("resource closed")

