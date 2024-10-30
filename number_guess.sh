#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing -t --no-align -c"

# Generate a random number between 1 and 1000
RANDOM_GUESS=$((RANDOM % 1000 + 1))
i=0

# Function to check if the input is an integer
check_integer() {
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Error: Argument is not an integer."
    exit 1
  fi
}

# Prompt for username
read -p "Enter your username: " username

# Validate username length
if [[ ${#username} -gt 22 ]]; then 
  echo "Not valid username."
  exit 1
fi

# Fetch user data from the database
user=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$username'")

# Check if user exists
if [[ -z $user ]]; then 
  res=$($PSQL "INSERT INTO users(username) VALUES('$username')")
  echo -e "Welcome, $username! It looks like this is your first time here.\n"
else
  # Extract values from user data
  IFS='|' read -r games_played best_game <<< "$user"
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

# Prompt for guessing the secret number
read -p "Guess the secret number between 1 and 1000: " guessed_number
check_integer $guessed_number

# Game loop for guessing
while [[ $guessed_number -ne $RANDOM_GUESS ]]; do 
    ((i++))  # Increment the guess counter
    if (( guessed_number > RANDOM_GUESS )); then
      echo $RANDOM_GUESS
      read -p "It's lower than that, guess again: " guessed_number
      check_integer $guessed_number
    elif (( guessed_number < RANDOM )); then
      echo $RANDOM_GUESS
      read -p "It's higher than that, guess again: " guessed_number
      check_integer $guessed_number
    fi
done

# Successful guess message
((i++))  # Increment for the correct guess
echo "You guessed it in $i tries. The secret number was $RANDOM. Nice job!"
