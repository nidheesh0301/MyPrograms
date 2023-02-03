#when we want to query more records from database andload in memory and want to work with 1 record at a time, yield can be used 
def topten():

    n = 1
    while n <= 10:
        sqr = n*n
        yield sqr 
        n += 1

values = topten()

for i in values:
    print(i)