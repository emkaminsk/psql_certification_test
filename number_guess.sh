#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# populate variables
POPULATE_VARIABLES() {
  SELECT_USERS=$($PSQL "select user_id, name, games_played, best_game from users where name='$USERNAME'")
  IFS="|" read USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< $SELECT_USERS
  UPDATE_GAMES_PLAYED=$($PSQL "update users set games_played = games_played + 1 where user_id = $USER_ID")
  USERNAME=$(echo $USERNAME | sed 's/ //g')  
}

# generate a random number from 1 to 1000
NUMBER=$(( $RANDOM % 1000 + 1 ))
# prompt for username
echo "Enter your username:"
read USERNAME
# check if user is in the database
SELECT_USERS=$($PSQL "select user_id from users where name='$USERNAME'")
# if not add to db and print welcome
if [[ -z $SELECT_USERS ]]
then
  INSERT_USER=$($PSQL "insert into users(name) values('$USERNAME')")
  POPULATE_VARIABLES
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # if yes increment number of games played, print welcome
  POPULATE_VARIABLES
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo -e "\nGuess the secret number between 1 and 1000:"
ROUND=0
# start a while loop for guessing
while [[ 1 == 1 ]]
do 
  # read the current input
  read THIS_GUESS
  # check if input is numeric
  if [[ ! $THIS_GUESS =~ ^[0-9]{1,4}$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  else
    ROUND=$(($ROUND+1))
    # check the input against number - if lower
    if [[ $THIS_GUESS -lt $NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
    else
    # print if higher
      if [[ $THIS_GUESS -gt $NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
      else
        # print if equal , conditionally update best game and exit
        echo -e "\nYou guessed it in $ROUND tries. The secret number was $NUMBER. Nice job!"
        if [[ -z $BEST_GAME || $ROUND -lt $BEST_GAME ]]
        then
          UPDATE_BEST_GUESS=$($PSQL "update users set best_game=$ROUND where user_id=$USER_ID")
        fi
        exit
      fi
    fi
  fi
done