for combo in $(curl -s https://raw.githubusercontent.com/LineageOS/hudson/master/lineage-build-targets | sed -e 's/#.*$//' | grep cm-14.1 | awk '{printf "cm_%s-%s\n", $1, $2}')
do
    add_lunch_combo $combo
done
