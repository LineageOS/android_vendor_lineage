for combo in $(curl -s https://raw.githubusercontent.com/CyanogenMod/hudson/master/cm-build-targets | sed -e 's/#.*$//' | grep cm-12.0 | awk {'print $1'})
do
    add_lunch_combo $combo
done
