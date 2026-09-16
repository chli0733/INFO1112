#!/usr/bin/env bash

# checks whether something was inserted in emulator, else return error
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <filename.bin>."
  exit 1
fi
# checks whether file in question exists in directory
if [[ ! -f "$1" ]]; then
  echo "Error: File '$1' does not exist."
  exit 1
fi
# checks whether file in question is a .bin file
if [[ "$1" != *.bin ]]; then
  echo "Error: File '$1' does not have a .bin extension."
  exit 1
fi

# setting up emulator
R0=0
R1=0
PC=0

memory=()
for((i=0; i<256; i++)); do
  memory[i]=0
done

# setting up the .bin file to become several lines instead of 1 long line
bytes=()
while IFS= read -r byte_hex || [[ -n "$byte_hex" ]]; do
  clean_hex="${byte_hex//$'\r'/}"
  # Check if clean_hex is non-empty before converting
  if [[ -n "$clean_hex" ]]; then
    bytes+=("$((16#$clean_hex))")
  fi
# loops until file is empty 
done < <(xxd -p -c 1 "$1")

byte="${bytes[0]}"
# Check if program size is valid (must be an even number of bytes)
if (( ${#bytes[@]} % 2 != 0 )); then
  echo "Error: Corrupted file. Byte count must be even."
  exit 1
fi

# Program type check
if [[ ${#bytes[@]} -eq 2 && "${bytes[0]}" -eq 128 && "${bytes[1]}" -eq 0 ]]; then
  # Proceed with 0-program
  PC=0
elif [[ ${#bytes[@]} -ge 4 ]]; then
  # Proceed with 2-program
  # Load static data into memory addresses 1 and 2
  memory[1]="${bytes[0]}"
  memory[2]="${bytes[1]}"
  # Instructions start at byte index 2
  PC=2
else
  echo "Error: Invalid binary file layout."
  exit 1
fi

# Fetch-Decode-Execute Loop
while (( PC < ${#bytes[@]} )); do
  # Fetch 2 bytes (16 bits)
  b1="${bytes[$PC]}"
  b2="${bytes[$PC+1]}"
  
  # Combine into 16-bit word
  task=$(( (b1 << 8) | b2 ))
  
  # Decode bitwise fields
  instruction=$(( (task >> 10) & 0x3F ))
  register=$(( (task >> 8) & 0x03 ))
  value=$(( task & 0xFF ))
  
  # Advance Program Counter
  (( PC += 2 ))

  # Executions
  if [[ "$instruction" -eq 0 ]]; then 
    # LOAD
    if [[ "$register" -eq 0 ]]; then
      R0="${memory[$value]}"
    else
      R1="${memory[$value]}"
    fi
  elif [[ "$instruction" -eq 1 ]]; then 
    # STORE
    if [[ "$register" -eq 0 ]]; then
      memory[$value]="$R0"
    else
      memory[$value]="$R1"
    fi
  elif [[ "$instruction" -eq 2 ]]; then 
    # ADD
    if [[ "$register" -eq 0 ]]; then
      R0=$(( R0 + R1 ))
    else
      R1=$(( R1 + R0 ))
    fi
  elif [[ "$instruction" -eq 3 ]]; then 
    # SUB
    if [[ "$register" -eq 0 ]]; then
      R0=$(( R0 - R1 ))
    else
      R1=$(( R1 - R0 ))
    fi
  elif [[ "$instruction" -eq 9 ]]; then 
    # PRINT
    if [[ "$register" -eq 0 ]]; then
      echo "$R0"
    else
      echo "$R1"
    fi
  elif [[ "$instruction" -eq 32 ]]; then 
    # QUIT
    break
  else # Unknown instruction catch-all
    echo "Error: Unknown instruction '$instruction' at byte position $((PC - 2))"
    exit 1
  fi
done