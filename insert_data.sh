#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  if [[ $YEAR != "year" ]]
  then 
    # Check if the WINNER team exists in the database
    TEAM=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # If WINNER team does not exist, insert it
    if [[ -z $TEAM ]]
    then 
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $WINNER"
      fi
    fi

    # Check if the OPPONENT team exists in the database
    TEAM2=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # If OPPONENT team does not exist, insert it
    if [[ -z $TEAM2 ]]
    then
      INSERT_TEAM2_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM2_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi
    fi

    TEAM=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    TEAM2=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$TEAM,$TEAM2,$WINNER_GOALS,$OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games $YEAR,$ROUND,$TEAM,$TEAM2,$WINNER_GOALS,$OPPONENT_GOALS"
    fi
  fi
done

