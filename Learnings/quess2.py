from curses.ascii import isdigit
import random

random_input = input("enter a number: ")

if random_input.isdigit():
    random_input =  int(random_input)

else:
    print("please enter a number")
    quit()

random_number=random.randint(1, random_input)
print(random_number)

# while True:
#     user_guess = input("guess the number: ")

#     if user_guess.isdigit():
#         user_guess =  int(user_guess)

#     else:
#         print("please enter a number next time")

#     if user_guess == random_input:
#         print("awesome..!")
#         break
#     else:
#         print("wrong pick try again")
         
