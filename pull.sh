#!/bin/bash

PROJECT="wqael/ros"

pull() {
	echo "[[ $1 ]]"
    docker pull "$PROJECT:$line"
}

while IFS='' read -r line || [[ -n "$line" ]]; do
    pull "$line"
done < "$1"
