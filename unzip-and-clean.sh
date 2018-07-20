#!/bin/bash
INPUT=$1
OUTPUT=$2
F=$(file $INPUT)
gunzip -c $INPUT | egrep -a '^[-0-9]+,[0-9]+:[0-9a-fA-F,]+:[0-9a-fA-F,]+$' | egrep -av ",0:" > $OUTPUT
