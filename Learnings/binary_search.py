#to do binary search the list has to be in an order 
position=0

def search(lst,a):
    l = 0
    u = len(lst)-1  #u=7
    while l <= u:
        mid = (l + u) // 2   #in first iteration mid becomes 0+7//2 = 3; next:  4+7//2 = 5
        if lst[mid] == n:    #checks 5==15 ? next: lst[5]=15
            globals()['position']= lst[mid]
            return True 
        else:
            if lst[mid] < n:   #checks 5<15 --> yes 
                l = mid + 1   #in first iteration l changes from 0 to 4
            else:
                u = mid -1
    return False 
       

list=[0,1,2,5,7,15,18,20]
n=20

if search(list,n):
    print('Found the number',position)
else:
    print("not found")