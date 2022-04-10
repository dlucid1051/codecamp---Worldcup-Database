#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

## START OF MY CODE:
clear
echo -e '\n~~  Script to create a world cup database ~~\n'
# Empty the tables and reset IDs
echo -e '\nReset the tables in the worldcup database:'
SQL_STR="TRUNCATE teams RESTART IDENTITY CASCADE"
echo $($PSQL "$SQL_STR")
SQL_STR="TRUNCATE games RESTART IDENTITY CASCADE"
echo $($PSQL "$SQL_STR")


# Iterate through the games.csv rows and add data
echo -e '\nImporting games.csv data:'
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
   # Skip first row if it's a header
  if [[ $YEAR != "year" ]]  #it's not a header
  then

    # Get winner ID
    STR_SQL="SELECT team_id FROM teams WHERE name = '$WINNER'"
    WINNER_ID=$($PSQL "$STR_SQL")
    # If not found
    if [[ -z $WINNER_ID ]]
    then
      # Insert team
      STR_SQL="INSERT INTO teams(name) VALUES('$WINNER')"
      INSERT_TEAM_RESULT=$($PSQL "$STR_SQL")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $WINNER"
      fi
      # Get new winner ID
      STR_SQL="SELECT team_id FROM teams WHERE name = '$WINNER'"
      WINNER_ID=$($PSQL "$STR_SQL")
    fi

    # Get opponent ID
    STR_SQL="SELECT team_id FROM teams WHERE name = '$OPPONENT'"
    OPPONENT_ID=$($PSQL "$STR_SQL")
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert team
      STR_SQL="INSERT INTO teams(name) VALUES('$OPPONENT')"
      INSERT_TEAM_RESULT=$($PSQL "$STR_SQL")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi
      # Get new opponent ID
      STR_SQL="SELECT team_id FROM teams WHERE name='$OPPONENT'"
      OPPONENT_ID=$($PSQL "$STR_SQL")
    fi

    # Insert games
    STR_SQL="INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) "
    STR_SQL=$STR_SQL"VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"
    INSERT_GAMES_RESULT=$($PSQL "$STR_SQL")
    if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted game" $YEAR - $ROUND - $WINNER vs $OPPONENT:
    fi
  fi
done
# Exit
