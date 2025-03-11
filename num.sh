#!/bin/bash
num=0
for i in *; do
	pnum=`printf '%3i\n' $num |sed -e 's/ /0/g'`
	echo $i | grep ^[0-9][0-9][0-9]  > /dev/null 2>&1
	if [ $? = 0 ]; then
		git mv $i ${pnum}-`echo $i | cut -c 5-`
	fi
	num=$((num + 10))
done
