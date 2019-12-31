#!/bin/bash

echo -n -e "\\xEF\\xBB\\xBF" > csv.csv
cat ${fileName} >> csv.csv
rm -rf ./${fileName}
mv csv.csv ${fileName}
