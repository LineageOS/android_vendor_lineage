for combo in $(cat vendor/cm/jenkins-build-targets)
do
    add_lunch_combo $combo
done
