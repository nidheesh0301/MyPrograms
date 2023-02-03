#selection sort swaps outer loop not inner loop like bubble sort 


def sort(lst):
    for i in range(5):
        print("im I", i)
        minpos=i
        print("im minpos",i)
        for j in range(i,6): 
            print("Im J" , j)
            if lst[j] < lst[minpos]:
                minpos=j
                print("minpos after if", minpos,lst[minpos])  #at the end of j loop minpos= 2
        temp = lst[i]
        lst[i] = lst[minpos]
        lst[minpos] = temp    

lst=[5,3,8,6,7,2]
sort(lst)
print(lst)