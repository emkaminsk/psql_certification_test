#!/bin/bash
PSQL="psql --username=marcin --dbname=periodic_table -t --no-align -c"
# test the parameter
if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument.\n"
else
  # get atomic_number from elements
  # test if argument is integer
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    GET_ELEMENT=$($PSQL "select atomic_number from elements where atomic_number=$1")
  else
    # test if argument is max 2 chars
    if [[ $1 =~ ^[a-zA-Z]{1,2}$ ]]
    then
      GET_ELEMENT=$($PSQL "select atomic_number from elements where symbol='$1'")
    else
      GET_ELEMENT=$($PSQL "select atomic_number from elements where name='$1'")
    fi
  fi
  # test if GET_ELEMENT is not empty
  if [[ -z $GET_ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    # if it is not empty, print the expected text
    GET_DATA=$($PSQL "select name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius from elements inner join properties using(atomic_number) inner join types using(type_id) where elements.atomic_number=$GET_ELEMENT")
    echo $GET_DATA | while IFS="|" read NAME SYMBOL TYPE MASS MELTING BOILING
    do
      echo "The element with atomic number $GET_ELEMENT is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi
