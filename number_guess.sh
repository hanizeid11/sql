#!/bin/bash

# Database connection
PSQL="psql --username=freecodecamp --dbname=number_guessing -t --no-align -c"

# Function to get user data
get_user_data() {
    local username=$1
    # Get games_played and best_game, use | as a delimiter
    user_data=$($PSQL "SELECT games_played || '|' || COALESCE(best_game::text, 'NULL') FROM users WHERE username='$username'")
    echo $user_data
}

# Function to add new user
add_user() {
    local username=$1
    $PSQL "INSERT INTO users (username) VALUES ('$username')"
}

# Function to update user games
update_user() {
    local username=$1
    local number_of_guesses=$2
    $PSQL "UPDATE users SET games_played = games_played + 1, best_game = COALESCE(LEAST(best_game, $number_of_guesses), $number_of_guesses) WHERE username='$username'"
}

# Main logic
echo "Enter your username:"
read username

# Retrieve user data
user_data=$(get_user_data "$username")
if [[ -z $user_data ]]; then
    echo "Welcome, $username! It looks like this is your first time here."
    add_user "$username"
else
    # Read games_played and best_game using | as a delimiter
    IFS='|' read games_played best_game <<< "$user_data"
    
    # Handle case where best_game might be NULL
    if [[ $best_game == "NULL" ]]; then
        best_game="N/A"
    fi

    echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

# Generate a random secret number between 1 and 1000
secret_number=$(( RANDOM % 1000 + 1 ))
number_of_guesses=0
echo "Guess the secret number between 1 and 1000:"

while true; do
    read guess
    if ! [[ $guess =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        continue
    fi

    number_of_guesses=$((number_of_guesses + 1))

    if (( guess < secret_number )); then
        echo "It's higher than that, guess again:"
    elif (( guess > secret_number )); then
        echo "It's lower than that, guess again:"
    else
        echo "You guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"
        update_user "$username" "$number_of_guesses"
        exit
    fi
done
