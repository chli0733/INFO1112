#!/bin/bash

#helper function - decimal to binary
decimal_to_binary() {
  local num=$1
  local binary=""
  local temp=$num
  for weight in 128 64 32 16 8 4 2 1; do
    if (( $temp >= $weight )); then
      bit=1
      temp=$(($temp - $weight))
    else
      bit=0
    fi
    binary="$binary$bit"
  done
}
# helper function - register to binary
register_to_binary() {
  local register=$1
  if [ "$register" -eq 0 ]; then
    echo "00"
  elif [ "$register" -eq 1]; then
    echo "01"
  elif [ "$register" -eq 2]; then
    echo "10"
  else
    echo "11"
  fi
}

# the function to do the instruction "quit"
process_quit() {
  register="$1"
  value="$2"
  # checker
  if [[ "$register" != "0" ]] || [[ "$value" != "0" ]]; then
    echo "Error: QUIT instruction must contain register - 0 and value - 0."
    exit 1
  fi
  # conversions to binary using helper functions
  local binary_register=($register_to_binary "$register")
  local binary_value=($decimal_to_binary "$value")
  
  # bitwise operations for addition
  local quit_value byte1 byte2
  # combines binary and opcode (1 << 10) into 1 variable
  (( quit_value = ( 8 << 10 ) | ( 2#$binary_register << 8 ) | 2#binary_value ))
  # splits the binary into 2 bytes (upper and lower), where 0xFF used to confirm lowest 8 bits remain
  (( byte1 = ( quit_value >> 8 ) & 0xFF ))
  (( byte2 = ( quit_value & 0xFF )))
  printf "$(printf '\\x%02x\\x%02x' "$byte1" "$byte2")" >> "$output_file"
}
# the function to do the instruction "load"
process_load() {
  register="$1"
  value="$2"
  # checker (whether register is valid)
  if [[ "$register" != 0 && "$register" != 1 ]]; then
    echo "Error: LOAD instruction must contain register of 0 or 1"
    exit 1
  fi
  # checker (whether value is valid)
  if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 0 || value > 128 )); then
    echo "Error: LOAD instruction must contain integer between 0 and 128."
    exit 1
  fi
  # conversions to binary using helper functions
  local binary_register=($register_to_binary "$register")
  local binary_value=($decimal_to_binary "$value")
  
  # bitwise operations for addition
  local load_value byte1 byte2
  # combines binary and opcode (1 << 10) into 1 variable
  (( load_value = ( 1 << 10 ) | ( 2#$binary_register << 8 ) | 2#binary_value ))
  # splits the binary into 2 bytes (upper and lower), where 0xFF used to confirm lowest 8 bits remain
  (( byte1 = ( load_value >> 8 ) & 0xFF ))
  (( byte2 = ( load_value & 0xFF )))
  printf "$(printf '\\x%02x\\x%02x' "$byte1" "$byte2")" >> "$output_file"
}
# the function to do the instruction "store"
process_store() {
  register="$1"
  value="$2"
  # checker (whether register is valid)
  if [[ "$register" != 0 && "$register" != 1 ]]; then
    echo "Error: STORE instruction must contain register of 0 or 1"
    exit 1
  fi
  # checker (whether value is valid)
  if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 0 || value > 128 )); then
    echo "Error: STORE instruction must contain integer between 0 and 128."
    exit 1
  fi
  # conversions to binary using helper functions
  local binary_register=($register_to_binary "$register")
  local binary_value=($decimal_to_binary "$value")

  # bitwise operations for store
  local store_value byte1 byte2
  # combines binary and opcode (2 << 10) into 1 variable
  (( load_value = ( 2 << 10 ) | ( 2#$binary_register << 8 ) | 2#binary_value ))
  # splits the binary into 2 bytes (upper and lower), where 0xFF used to confirm lowest 8 bits remain
  (( byte1 = ( store_value >> 8 ) & 0xFF ))
  (( byte2 = ( store_value & 0xFF )))
  printf "$(printf '\\x%02x\\x%02x' "$byte1" "$byte2")" >> "$output_file"
}
# the function to do the instruction "add"
process_add() {
  register="$1"
  value="$2"
  # checker (whether register is valid)
  if [[ "$register" != 0 && "$register" != 1 ]]; then
    echo "Error: ADD instruction must contain register of 0 or 1"
    exit 1
  fi
  # checker (whether value is valid)
  if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 0 || value > 128 )); then
    echo "Error: ADD instruction must contain integer between 0 and 128."
    exit 1
  fi
  # conversions to binary using helper functions
  local binary_register=($register_to_binary "$register")
  local binary_value=($decimal_to_binary "$value")

  # bitwise operations for addition
  local summation_value byte1 byte2
  # combines binary and opcode (3 << 10) into 1 variable
  (( summation_value = ( 3 << 10 ) | ( 2#$binary_register << 8 ) | 2#binary_value ))
  # splits the binary into 2 bytes (upper and lower), where 0xFF used to confirm lowest 8 bits remain
  (( byte1 = ( summation_value >> 8 ) & 0xFF ))
  (( byte2 = ( summation_value & 0xFF )))
  printf "$(printf '\\x%02x\\x%02x' "$byte1" "$byte2")" >> "$output_file"
}
# the function to do the instruction "sub"
process_sub() {
  register="$1"
  value="$2"
  # checker (whether register is valid)
  if [[ "$register" != 0 && "$register" != 1 ]]; then
    echo "Error: SUB instruction must contain register of 0 or 1"
    exit 1
  fi
  # checker (whether value is valid)
  if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 0 || value > 128 )); then
    echo "Error: SUB instruction must contain integer between 0 and 128."
    exit 1
  fi
  # conversions to binary using helper functions
  local binary_register=($register_to_binary "$register")
  local binary_value=($decimal_to_binary "$value")
  
  # bitwise operations for subtraction
  local subtraction_value byte1 byte2
  # combines binary and opcode (4 << 10) into 1 variable
  (( subtraction_value = ( 4 << 10 ) | ( 2#$binary_register << 8 ) | 2#binary_value ))
  # splits the binary into 2 bytes (upper and lower), where 0xFF used to confirm lowest 8 bits remain
  (( byte1 = ( subtraction_value >> 8 ) & 0xFF ))
  (( byte2 = ( subtraction_value & 0xFF )))
  printf "$(printf '\\x%02x\\x%02x' "$byte1" "$byte2")" >> "$output_file"
}
# the function to do the instruction "print"
process_print() {
  register="$1"
  value="$2"
  # checker (whether register is valid)
  if [[ "$register" != 0 && "$register" != 1 ]]; then
    echo "Error: PRINT instruction must contain register of 0 or 1"
    exit 1
  fi
  # checker (whether value is valid)
  if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 0 || value > 128 )); then
    echo "Error: PRINT instruction must contain integer between 0 and 128."
    exit 1
  fi
  # conversions to binary using helper functions
  local binary_register=($register_to_binary "$register")
  local binary_value=($decimal_to_binary "$value")
  
  # bitwise operations for subtraction
  local print_value byte1 byte2
  # combines binary and opcode (9 << 10) into 1 variable
  (( print_value = ( 9 << 10 ) | ( 2#$binary_register << 8 ) | 2#$binary_value ))
  # splits the binary into 2 bytes (upper and lower), where 0xFF used to confirm lowest 8 bits remain
  (( byte1 = ( print_value >> 8 ) & 0xFF ))
  (( byte2 = ( print_value & 0xFF )))
  printf "$(printf '\\x%02x\\x%02x' "$byte1" "$byte2")" >> "$output_file"
}


# checks whether something was inserted in assembler, else return error
if [[ $# -eq 0 ]]; then
  echo "usage: no argument is provided"
  exit 1
fi
if [[ $# -gt 1 ]]; then
  echo "usage: more than one arguments are provided"
  exit 1
fi
# checks whether file in question exists in directory
if [[ ! -f "$1" ]]; then
  echo "usage: input is not a file or it does not exist"
  exit 1
fi
# checks whether file in question is a .vsc file
if [[ "$1" != *.vsc ]]; then
  echo "usage: input does not have the extension .vsc"
  exit 1
fi
# check whether the file in question is empty
if [[ ! -s "$1" ]]; then
  echo "usage: the file is empty - no .bin file is produced"
  exit 1
fi

# removes old output_file just in case
rm -f "$output_file"

# reading instructions from .vsc file
lines=()
# reads characters in a line of a file and moves it to a variable called line
while IFS= read -r line || [[ -n "$line" ]]; do
  # remove characters (leaving integers)
  non_character_lines="${line//$'\r'/}"
  # skip empty lines if present
  if [[ -n "$non_character_lines" ]]; then
    lines+=("$non_character_lines")
  fi
# loops until file is empty 
done < "$1"

# program type check
line1="${lines[0]}"
if [[ "$line1" == 0 ]]; then
  # 0-program check
  if [[ "${#lines[@]}" -eq 2 ]] && [[ "${lines[1]}" == "QUIT,0,0" ]]; then
    # proceed with 0-program
    # creates a .bin file with name of the .vsc file
    output_file="${1%.vsc}.bin"
    # clears output_file
    > "$output_file"
    # inserts "QUIT,0,0" into output_file
    process_quit "0" "0"
    echo "It is a QUIT program"
    echo "The content of the .bin file is"
    xxd -p -c 1 "$output_file"
  else
    echo "Error: Invalid 0-program."
    exit 1
  fi
elif [[ "$line1" == 2 ]]; then
  # 2-program check
  value1="${lines[1]}"
  value2="${lines[2]}"
  if [[ "$value1" =~ ^[0-9]+$ ]] && [[ "$value2" =~ ^[0-9]+$ ]]; then 
    if (( value1 < 0 || value1 > 128 )); then
      echo "Error: value 1 is an invalid number. Please put a number between 0 and 128."
      exit 1
    elif (( value2 < 0 || value2 > 128 )); then
      echo "Error: value 2 is an invalid number. Please put a number between 0 and 128."
      exit 1
    else
      # proceed with 2-program
      # creates a .bin file with name of the .vsc file
      output_file="${1%.vsc}.bin"
      # converts values into hex bytes
      printf "$(printf '\\x%02x\\x%02x' "${lines[1]}" "${lines[2]}")" > "$output_file"
      # processes instructions
      for ((i=3; i<${#lines[@]}; i++)); do
        IFS=',' read -r instruction register value <<< "${lines[$i]}"
        case "$instruction" in
          "LOAD") process_load "$register" "$value" ;;
          "STORE") process_store "$register" "$value" ;;
          "ADD") process_add "$register" "$value" ;;
          "SUB") process_sub "$register" "$value" ;;
          "QUIT") process_quit "$register" "$value" ;;
          "PRINT") process_print "$register" "$value" ;;
          *)
          echo "Error: Unknown instruction '$instruction' on line $((i+1))."
          # cleans up broken file
          rm -f "$output_file"
          exit 1
          ;;
        esac
      done
      echo "It is an ADD/SUB program"
      echo "The content of the .bin file is"
      xxd -p -c 1 "$output_file"
    fi
  else
    echo "Error: Lines 2 and 3 must be integers"
    exit 1
  fi

else
  echo "Error: Line 1 must be 0 or 2"
  exit 1
fi
