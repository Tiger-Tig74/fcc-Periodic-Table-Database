#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# get element details by atomic number
get_element_by_atomic_number() {
  $PSQL "
  SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass,
  t.type,
  p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  LEFT JOIN properties p USING(atomic_number)
  LEFT JOIN types t USING(type_id)
  WHERE e.atomic_number = $1::INTEGER;
  "
}

# get element details by symbol or name
get_element_by_symbol_or_name() {
  $PSQL "
  SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass,
  t.type,
  p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  LEFT JOIN properties p USING(atomic_number)
  LEFT JOIN types t USING(type_id)
  WHERE e.symbol = '$1'
  OR e.name ILIKE '$1';
  "
}

# check if argument is provided
if [ $# -eq 0 ]
then
  echo "Please provide an element as an argument."
else
  # check if the argument is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # fetch element details by atomic number
    ELEMENT_DETAILS=$(get_element_by_atomic_number "$1")
  else
    # fetch element details by symbol or name
    ELEMENT_DETAILS=$(get_element_by_symbol_or_name "$1")
  fi

  # check if element exists in the database
  if [ -z "$ELEMENT_DETAILS" ]
  then
    echo "I could not find that element in the database."
  else
    # parse and display element details
    IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL ATOMIC_MASS TYPE MELTING_POINT BOILING_POINT <<< "$ELEMENT_DETAILS"
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi