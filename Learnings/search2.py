position=0

def search(lst,a):
    i=0
    while i < len(lst):
    
        if lst[i]==n:
            globals()['position']=i
            return True
            
        i += 1      
    return False 
       

list=[0,1,2,3,4,5,6,7]
n=5

if search(list,n):
    print('Found the number',position)
else:
    print("not found")