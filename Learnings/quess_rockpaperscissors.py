from random import randint
print("welcome to rock paper scissors game..!")

options=["rock","paper","scissors"]

user_pick = input("select rock/paper/scissor or q to quit: ").lower()

if user_pick == "q":
    quit()

random_number = randint(0,2)
while True:

     computer_pick=options[random_number]

     if user_pick == "rock" and computer_pick =="paper":
        print("you won..!")
        break 
     else:
        print("computer wins")
        quit()
        