#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~~~~~~~~ Salon ~~~~~~~~~~~~\n"

MAIN_MENU(){
  # Print input for return calls
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
 
  SERVICE_MENU
  read SERVICE_ID_SELECTED

  # Fetch required service
  RESULT_SERVICE_QUERY=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  # if selection invalid
  if [[ -z $RESULT_SERVICE_QUERY ]]
  then
    # Warning and return
    MAIN_MENU "Please select one of the service options below"
  
  # if valid selection
  else
    CUSTOMER_MENU
    # ask customer
    # book appointment
  fi
}

SERVICE_MENU() {
  echo "How may I help you?"
  RESULT_SERVICE_QUERY=$($PSQL "SELECT * FROM services")
  echo "$RESULT_SERVICE_QUERY" | while read SERVICE_ID BAR NAME BAR
  do
    echo "$SERVICE_ID) $NAME"
  done
}

CUSTOMER_MENU() {
  # ask customer phone number
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE

  # look for customer
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  # if customer not found
  if [[ -z $CUSTOMER_ID ]]
  then
    # ask customer phone number
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME

    # add new customer to database
    CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  # fetch customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Ask service time?
  echo -e "\nWhat time would you like to book?"
  read SERVICE_TIME

  # create a new appointment
  APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

  # Give customer feedback
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  echo -e "\nI have put you down for a $(echo $SERVICE | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $NAME | sed -r 's/^ *| *$//g')."
}

MAIN_MENU