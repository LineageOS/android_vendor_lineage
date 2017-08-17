for combo in $(curl -s https://raw.githubusercontent.com/LineageOS/hudson/master/lineage-build-targets | sed -e 's/#.*$//' | grep lineage-15.0 | awk '{printf "lineage_%s-%s\n", $1, $2}')
do
    add_lunch_combo $combo
done
