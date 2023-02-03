def check_even(lst):
    e=0
    o=0
    for i in lst:
        if i%2==0:
            e=e+1
        else:
            o=o+1
    return e,o
  
lst=[10,12,14,15,16,16,17,1]
even,odd=check_even(lst)
print(even,odd)
