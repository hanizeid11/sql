#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

#Your git repository should have at least five commits

#Your script should randomly generate a number that users have to guess
RANDOM=$((RANDOM % 1000 +1))
i=0
#When you run your script, you should prompt the user for a username with Enter your username:, and take a username as input. Your database should allow usernames that are 22 characters
read -p "Enter your username" username
if [[ ${#username} -gt 22 ]]
then 
  echo "Not valid usename"
  exit 1
fi

#If that username has been used before, it should print Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses., with <username> being a users name from the database, <games_played> being the total number of games that user has played, and <best_game> being the fewest number of guesses it took that user to win the game
user=$($PSQL "SELECT games_played, best_game FROM users WHERE username=$username")
echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
#If the username has not been used before, you should print Welcome, <username>! It looks like this is your first time here.
if [[ -z $user ]]
then 
  res=$($PSQL "INSERT INTO users(username) VALUES($username)")
  echo -e "Welcome, $username! It looks like this is your first time here.\n"
#The next line printed should be Guess the secret number between 1 and 1000: and input from the user should be read
read -p "Guess the secret number between 1 and 1000:" guessed_number
check_integer $guessed_number
#Until they guess the secret number, it should print It's lower than that, guess again: if the previous input was higher than the secret number, and It's higher than that, guess again: if the previous input was lower than the secret number. Asking for input each time until they input the secret number.
while [[ $guessed_number -ne $RANDOM ]]; do 
    ((i++))
    if (( $guessed_number > $RANDOM ))
    then
      read -p "It's higher than that, guess again:" guessed_number
      check_integer $guessed_number
    elif (( $guessed_number < $RANDOM ))
    then
      read -p "It's lower than that, guess again:" guessed_number
      check_integer $guessed_number
    fi
done
#If anything other than an integer is input as a guess, it should print That is not an integer, guess again:
check_integer() {
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Error: Argument is not an integer."
    exit 1
  fi
}
#When the secret number is guessed, your script should print You guessed it in <number_of_guesses> tries. The secret number was <secret_number>. Nice job! and finish running
if [[ $guessed_number -eq $RANDOM ]]
then 
  echo "You guessed it in $i tries. The secret number was $RANDOM. Nice job!"
#The message for the first commit should be Initial commit

#The rest of the commit messages should start with fix:, feat:, refactor:, chore:, or test:

#You should finish your project while on the main branch, your working tree should be clean, and you should not have any uncommitted changes 
