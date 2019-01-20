#!/bin/bash
##################################################################
## Name:	compile.sh                                      ##
## Purpose:	assembles and links nasm source into executable ##
##              then executes objdump to generate and print out ##
##              shellcode and it's length.                      ##
##                   &&  Xero-Xero                              ##
##################################################################


PROGRAM=$1
EXT="${PROGRAM##*.}"


if [ $EXT == "nasm" ];
    then
	PROGRAM="${PROGRAM%.*}"
    else
	PROGRAM=$1
fi

if [ ! -f $PROGRAM.nasm ];
    then
	echo "[!] Cannot find $PROGRAM.nasm"
	echo "[-] Exiting"
	exit
fi

echo
echo "  Author Xero-Zero (Xero-Z) "
echo
echo "[+] Assembling $PROGRAM.nasm with \"nasm -f  -o $PROGRAM.o $PROGRAM.nasm\" "

nasm -f elf32 -o $PROGRAM.o $PROGRAM.nasm

# Link with the -N argument (omagic) to not make text section read-only

echo "[+] Linking $PROGRAM.o with \"ld -melf_i386 -zexecstack -N -o $PROGRAM $PROGRAM.o\""

ld -melf_i386 -zexecstack -N -o $PROGRAM $PROGRAM.o


echo '[+] Generating shellcode via objdump and sed ...'

SHELLCODE=$(objdump -d ./$PROGRAM|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g')

# Get the shellcode size in bytes (\xyy = 1byte):

size=$((((${#SHELLCODE})-2)/4))

echo "[+] $size bytes shellcode generated:"
echo "[+] Saved as shellcode.txt "
echo
echo "$SHELLCODE"
echo
echo "$SHELLCODE" > shellcode.txt
echo
