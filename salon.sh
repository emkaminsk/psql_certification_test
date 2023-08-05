#!/bin/bash

PSQL="psql -U freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

# main menu
MAIN_MENU() {  
  # display a numbered list of the services
  SERVICES=$($PSQL "select service_id, name from services order by service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  # read selection
  read SERVICE_ID_SELECTED
  # check selection if it is numeric and is a number between 1 and max service_id
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # not numeric
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU
    exit 0
  fi
  IS_IN_TABLE=$($PSQL "select service_id from services where service_id = '$SERVICE_ID_SELECTED'")
  if [[ -z $IS_IN_TABLE ]]
  then
    # if not - call MAIN_MENU
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU
    exit 0
  # if yes - call service with the selection
  else
    SERVICE $SERVICE_ID_SELECTED
    exit 0
  fi
}

# run the service
SERVICE() {
  # read telephone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # if there is no number in database, ask for name and save to customers
  CUSTOMER_NAME=$($PSQL "SELECT name from customers where phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  TRIMMED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ //g')
  # read customer_id from database
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
  # read service name
  SERVICE_NAME=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED'")
  TRIMMED_SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/ //g')
  # read time
  echo -e "\nWhat time would you like your $TRIMMED_SERVICE_NAME, $TRIMMED_CUSTOMER_NAME?"
  read SERVICE_TIME
  # create appointment
  INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  # write the proper information that appointment is put down
  echo -e "\nI have put you down for a $TRIMMED_SERVICE_NAME at $SERVICE_TIME, $TRIMMED_CUSTOMER_NAME."
}

# main flow of the program
MAIN_MENU
