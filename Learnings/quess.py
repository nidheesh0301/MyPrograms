print ("welcome everyone")
var1 = input("Do you want to play a quick game?: ")
if var1 != "yes":
    quit()
else:
    print ("lets get started")
score=0
Q1 = input("What is the abbreviation of random access memory?: ").upper()

if Q1 == "RAM":
    print("Answer is correct..!")
    score+=1
else:
    print("Incorrect answer")

Q2 = input("what is the abbreviation of central processing unit?: ").upper()
if Q2 == "CPU":
    print("correct answer..!")
    score+=1
else:
    print("incorrect answer")

print("thanks for the participation, your score is: ", score/2*100,"%")