from time import sleep
from threading import Thread

class Hello(Thread):
    def run(self):
        for i in range(5):
            print('Hello')
            sleep(1)
class Hi(Thread):
    def run(self):
        for i in range (5):
            print("hi")
            sleep(1)
obj1=Hello()
obj2=Hi()

obj1.start()
sleep(0.2)
obj2.start()

obj1.join() #join is used to wait for the running thread to complete before printing bye 
obj2.join()

print("BYE")