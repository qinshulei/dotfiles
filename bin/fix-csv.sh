#!/bin/bash

fileName=$1
if [ -z "${fileName}" ];then
    echo "Error: you must input the file name"
    exit 1
fi

echo -n -e "\\xEF\\xBB\\xBF" > csv.csv
cat ${fileName} >> csv.csv
rm -rf ./${fileName}
mv csv.csv ${fileName}
