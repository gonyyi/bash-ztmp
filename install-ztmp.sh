#!/bin/sh

# ztmp installer 1.0.0
# (c) gon y. yi (gonyyi.com/copyright.txt)

tmpHomeDir=$(echo ~)
echo "zTmp install\n(c)Gon Y. Yi (gonyyi.com)\n"
echo "Install location:"
echo "  (1) bash"
echo "  (2) zshrc"
read -p "Where to install? (1/2):" tmpInstLoc

if [ $tmpInstLoc != "1" ] && [ $tmpInstLoc != "2" ]; then 
	echo "Allowed input is 1 or 2, but supplied <$tmpInstLoc>"
	return 1
fi

if [ $tmpInstLoc == "1" ]; then 
	echo "Installing for bash"
	target=".bashrc"
else
	echo "Installing for zshrc"
	target=".zshrc"
fi

cp .bashrc-ztmp.sh ~
if [ $? -eq 0 ]; then
	echo "[OK] Copy script to home directory ($tmpHomeDir/)"
else
	echo "[FAIL] Copy script to home directory ($tmpHomeDir/)"
	return 1
fi 

if [ $(grep "source $tmpHomeDir/.bashrc-ztmp.sh" $tmpHomeDir/$target | wc -l |xargs) -eq 0 ]; then 
	echo "source $tmpHomeDir/.bashrc-ztmp.sh" >> $tmpHomeDir/$target
	if [ $? -eq 0 ]; then
		echo "[OK] successfully added to $tmpHomeDir/$target"
	else
		echo "[FAIL] cannot add to $tmpHomeDir/$target"
	fi
else 
	echo "[WARN] <source .bashrc-ztmp.sh> already exist in $tmpHomeDir/$target"
fi 
