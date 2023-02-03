


f = open('test.txt', 'r')
#print(f.read()) #this will read the complete line
#print(f.readline()) #this will read line by line 

#f1 = open('test1.txt','a') #to append 
f1 = open('test1.txt','w') #to write 
#f1.write('nidheesh')
#f1.write("nidheesh")
#f1 = open('my pic.jpg','wb')
for i in f:
    f1.write(i)