#!/bin/bash

# Define the PSQL command
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  # Retrieve services from the database
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")

  # Check if services were found
  if [[ -z $SERVICES ]]; then
    echo "No service found."
    return  # Exit the function if no services are available
  fi

  # Display available services
  echo "$SERVICES" | while IFS="|" read -r id name; do 
      # Trim leading spaces from both id and name
  id=$(echo "$id" | xargs)
  name=$(echo "$name" | xargs)
  echo "$id) $name"
  done

  # Prompt for service selection
  read SERVICE_ID_SELECTED
  SEARCH=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  # Validate service selection
  if [[ -z $SEARCH ]]; then
    MAIN_MENU  # Call the function again for valid selection
    return  # Exit the current function after the call
  fi

  # Prompt for customer phone number
  echo -e "What's your phone number?\n"
  read CUSTOMER_PHONE
  
  # Fetch customer information based on phone number
  CUSTOMER=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Check if the customer exists
  if [[ -z $CUSTOMER ]]; then 
    echo -e "I don't have a record for that phone number, what's your name?\n" 
    read CUSTOMER_NAME
    
    # Insert new customer record into the database
    CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo "New customer record created for $CUSTOMER_NAME."
    echo "$CUSTOMER_ID"
  else
    # Extract customer_id and customer_name from the query result
    read -r CUSTOMER_ID CUSTOMER_NAME <<< "$CUSTOMER"
    echo "$CUSTOMER_ID"
  fi

  # Ask for appointment time
  echo -e "What time would you like your cut, $CUSTOMER_NAME?\n"
  read SERVICE_TIME
  
  # Insert appointment into the appointments table
  APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirmation message
  echo "I have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Call the MAIN_MENU function
MAIN_MENU
