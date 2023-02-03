from random import randint
print("welcome to rock paper scissors game..!") 

user_wins = 0
computer_wins = 0

options=["rock","paper","scissors"]




while True:

    user_pick = input("select rock/paper/scissors or q to quit: ").lower()
    
    if user_pick == "q":
        break
    
    if user_pick not in options:
        print("your selection is incorrect")
        continue
    random_number = randint(0,2)
    computer_pick=options[random_number]
    
    print(computer_pick)

    if user_pick == "rock" and computer_pick =="scissors":
        print("you won..!")
        user_wins+=1

    elif user_pick == "paper" and computer_pick =="rock":
        print("you won..!")
        user_wins+=1

    elif user_pick == "scissors" and computer_pick =="paper":
        print("you won..!")
        user_wins+=1
         
    else:
        print("computer wins")
        computer_wins+=1
       
print("you won",user_wins )
print("computer won", computer_wins)