#!/bin/bash

CONFIG=$1

OUT_TXT=work/${CONFIG}.txt
OUT_DOT=work/${CONFIG}.dot

configure() {
	echo `grep "$2:" "$1" | sed "s/$2://"`
}

url_in=`configure $CONFIG "url_in"`
cmd_in=`configure $CONFIG "cmd_in"`
node_start=`configure $CONFIG "node_start"`
node_ignore=`configure $CONFIG "node_ignore"`
depth=`configure $CONFIG "depth"`

queue=()

process() {
	node=$1
	level=$2
	
	if [ "$node" == "$node_ignore" ]; then
		return
	fi
	
	if grep -q "${node}:" $OUT_TXT; then
		# echo "Already processed: "$node
		return
	fi
	
	echo "Processing: "$node
	
	line=$node":"
	
	iurl=`echo "$url_in" | sed "s/\[node\]/$node/"`
	curl -sS --retry 3 $iurl > work/node_in.html
	
	cmd="cat work/node_in.html | $cmd_in"
	ins=`eval $cmd`
	line=$line$ins
	echo $line >> $OUT_TXT
	
	let nextlevel=$level+1
	queue[$nextlevel]=${queue[$nextlevel]}$ins","
}

mkdir -p work

touch $OUT_TXT

process $node_start 0

for  (( i=1; i<=$depth; i++)); do
	echo
	echo "Level: $i"
	echo "-----------------------------"
	while [ ! -z "${queue[$i]}" ]; do
		node=`echo ${queue[$i]} | sed 's/,.*//g'`
		queue[$i]=`echo ${queue[$i]} | sed "s/$node,//g"`
		process $node $i
		sleep 1 # to be nice to the server
	done
done

./txt2dot.sh "$OUT_TXT" "$OUT_DOT" "$node_ignore"