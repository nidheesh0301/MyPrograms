
import random

random_input = input("enter a number: ")

if random_input.isdigit():
    random_input =  int(random_input)
    if random_input <= 0:
        print("entered value is not above zero")
        quit()
        
else:
    print("entered value is not a number")
    quit()

random_number=random.randint(1, random_input)
tries = 0
while True:
    tries+= 1
    user_guess = input("please guess a number: ")

    if user_guess.isdigit():
        user_guess =  int(user_guess)

        if user_guess <= 0:
             print("entered value is not above zero")
             quit()
    else:
        print("entered value is not a number")
        quit()

    if user_guess == random_number:
        print("you are right, you guessed in attempt:",tries)
        quit()
    else:
        print("better luck next time")
        
        continue 
