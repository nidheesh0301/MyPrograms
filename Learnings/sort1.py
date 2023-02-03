
#this is using bubble sort by swapping numbers 

def sort(lst):
    for i in range(len(lst)-1,0,-1):  #range(4,0,-1) -s is step size (from last to first), i will start with 5
        print("i is ",i, lst[i])
        for j in range(i): # j will start from 0 
            print("j is ", j,lst[j])
            if lst[j] > lst[j+1]: # 
                temp=lst[j] 
                lst[j]=lst[j+1]
                lst[j+1]=temp

    

lst=[5,3,8,6,7,2]
sort(lst)
print(lst)