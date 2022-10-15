#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"
# generate random number between 1 and 1000
SECRET_NUMBER=$((1 + $RANDOM % 1000))
# get username
echo "Enter your username:"
read USERNAME
# check if username exists and get history if so
USERNAME_RESULT=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")
if [[ -z $USERNAME_RESULT ]]
then
  # if username doesn't exist
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # if username exists, print history
  read GAMES_PLAYED BAR BEST_GAME <<< $USERNAME_RESULT
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo "Guess the secret number between 1 and 1000:"
while [[ -z $GUESS || $GUESS != $SECRET_NUMBER ]]
do
  read GUESS
  # if guess is not blank
  if [[ ! -z $GUESS ]]
  then
    # add to number of guesses
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
    # if guess is not an integer
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    # if guess is higher than secret number
    elif (( $GUESS > $SECRET_NUMBER ))
    then
      echo "It's lower than that, guess again:"
    # if guess is lower than secret number
    elif (( $GUESS < $SECRET_NUMBER ))
    then
      echo "It's higher than that, guess again:"
    fi
  fi
done
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
# If a new user
if [[ -z $USERNAME_RESULT ]]
then
  # create user history
  HISTORY_RESULT=$($PSQL "INSERT INTO users VALUES('$USERNAME', 1, $NUMBER_OF_GUESSES)")
# if not a new best game
elif (( $NUMBER_OF_GUESSES > $BEST_GAME ))
then
  # update games played that user
  HISTORY_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
else
  # if not a new user and it is a new best game, update games played and best game
  HISTORY_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
fi