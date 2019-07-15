# Author：weizhou
# Date: 20190708

# looping through `ls` results in bash shell script
for f in $(cat filelist.txt); do
  echo "File -> $f"
done