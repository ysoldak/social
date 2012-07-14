#!/bin/sh

#
# Each line of the input file expected to look like following:
# node_id:inbound_node_id,..,inbound_node_id
#

FILE_IN=$1
FILE_OUT=$2
IGNORE=$3

echo "Making .dot file"

echo "digraph $CONFIG {" > $FILE_OUT
while read line; do
	# echo $line
	node=`echo $line | sed 's/:.*//g' | sed 's/-/_/g' | sed 's/@/_at_/g'`
	if [ "$node" == "$IGNORE" ]; then
		continue
	fi
	echo "Processing: "$node
	relations=`echo $line | sed 's/.*://g'`
	for relation in `echo $relations | tr ',' '\n'`; do
		if [ "$relation" == "$IGNORE" ]; then
			continue
		fi
		relation=`echo $relation | sed 's/-/_/g' | sed 's/@/_at_/g'`
		# echo "r:"$relation
		echo "  $relation -> $node;" >> $FILE_OUT
	done
done < $FILE_IN
echo "}" >> $FILE_OUT
