#!/bin/bash
#####################################################
# @Author: Muhammad Nasir Akram
# Last_change: 5.07.2024
#####################################################

# global variables
username=""
password=""
email=""
PWD="${HOME}/ConfigBot"
credentials_file=$PWD/Creds.key
email_file=$PWD/EmailAddress.txt

clear_screen () {
	printf "\033c"
}
print_menu () {
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo " ████████╗  ██╗█████╗███╗   ██╗██████╗███████╗     ████████████╗█████████████╗███████╗
██╔════██║  ████╔══██████╗  ████╔════╝██╔════╝    ██╔════██╔══████╔════██╔══████╔════╝
██║    ████████████████╔██╗ ████║  ████████╗      ██║    ██████╔█████╗ ██║  █████████╗
██║    ██╔══████╔══████║╚██╗████║   ████╔══╝      ██║    ██╔══████╔══╝ ██║  ██╚════██║
╚████████║  ████║  ████║ ╚████╚██████╔███████╗    ╚████████║  ███████████████╔███████║
 ╚═════╚═╝  ╚═╚═╝  ╚═╚═╝  ╚═══╝╚═════╝╚══════╝     ╚═════╚═╝  ╚═╚══════╚═════╝╚══════╝"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "What would you like to change?"
	echo "$1 1 - Set/Change Username"
	echo "$2 2 - Set/Change Password"
	echo "$3 3 - Set/Change your email address"
	echo "$4 4 - Exit"
	echo "---------------------------------------------"
}
file_exists() {
	file=$1
	if [ -f "$file" ]
	then	
		return 1
	else
		return 0
	fi
}
populate_current_credentials() {
	file_exists $credentials_file
	if [ $? == 1 ]
	then
		credentials=$(<$file)
		arrCRED=(${credentials//:/ })
		username=${arrCRED[0]}
		password=${arrCRED[1]}
		if [ -z ${username} ]
		then
			username="x"
		fi
	else
		clear_screen
                print_menu '*' - -
                echo "Credentials file does not exits. Creating.."
                touch $PWD/Creds.key
                sleep 1
                echo "credentials file created.. going back to the main menu."
                sleep 2
                clear_screen
                main
	fi
}
populate_current_email() {
	file_exists $email_file
	if [ $? == 1 ]
        then
                loc_email=$(<$file)
                if [ -z ${loc_email} ]
                then
                        email="x"
                fi
        else
                clear_screen
                print_menu - - '*' -
                echo "Email file does not exist. Creating.."
                touch $PWD/EmailAddress.txt
                sleep 1
                echo "Email file created.. going back to the main menu."
                sleep 2
                clear_screen
                main
        fi
}
update_current_credentials() {
	echo "$username:$password" > $credentials_file
}
update_current_email() {
	echo "$email" > $email_file
}
read_selection() {
	read -p "Please enter either 1, 2, 3 or 4 to exit: " $selection
	return $selection
}
encrypt_password() {
	echo $password | openssl aes-256-cbc -a -salt -pass pass:versatel
}
back_to_current_menu() {
        clear_screen
        if [ $1 == 1 ]
        then
                print_menu '*' - - -
		echo "You did not enter anything, please type in your new username again."
		sleep 1.5 
		menu_selection 1
        elif [ $1 == 2 ]
        then
                print_menu - '*' - -
		echo "You cannot leave password empty, please type in your new password again."
                sleep 1.5
                menu_selection 2
	elif [ $1 == 3 ]
        then
                print_menu - - '*' -
                echo "You cannot leave email empty, please type in your email again."
                sleep 1.5
                menu_selection 2
	elif [ $1 == 4 ]
	then
		echo "Exiting..."
		clear_screen
		exit 0
	else
                print_menu - - - '*'
		exit 0
        fi
}
menu_selection() {
	
	if [ $1 == 1 ]
	then
        	clear_screen
        	print_menu '*' - - -
		echo "Enter 4 to exit"
		read -p "Please enter your new Username: " new_username
		if [ -z ${new_username} ]
		then
			back_to_current_menu 1
		elif [ $new_username == "4" ]
		then
			clear_screen
			print_menu - - - '*'
			echo "Exiting..."
			sleep 1
			clear_screen
			exit 0
		else
			# Username is not empty to lets save it in credentials file
			echo "Username: $new_username"
			clear_screen
			print_menu '*' - - -
			echo "Saving..."
			username=$new_username
                        update_current_credentials
			populate_current_credentials
			sleep 0.5
			clear_screen
			print_menu '*' - - -
			echo "Successfully saved. Redirecting to mail menu in 3 seconds"
			sleep 3
			# go to main screen
			main
		fi
	elif [ $1 == 2 ]
	then
        	clear_screen
        	print_menu - '*' - -
		echo "Enter 4 to exit"
        	echo "Note: your password will not appear as you type"
        	read -s -p "Please enter your new Password: " new_password
		echo $new_password
		if [ -z ${new_password} ]
                then
                        back_to_current_menu 2
                elif [ $new_password == "4" ]
                then
                        clear_screen
                        print_menu - '*' - -
                        echo "Exiting..."
                        sleep 1
                        clear_screen
                        exit 0
                else
                        # Password is not empty to lets save it in credentials file
                        echo "Password: $new_password"
                        clear_screen
                        print_menu - '*' - -
                        password=$new_password
			password=$(encrypt_password)
                        update_current_credentials
                        populate_current_credentials
                        sleep 0.5
                        clear_screen
                        print_menu - '*' - -
                        echo "Password successfully saved. Redirecting back to main menu in 3 seconds"
                        sleep 3
                        # go to main screen
                        main
                fi
	elif [ $1 == 3 ]
        then
                clear_screen
                print_menu - - '*' -
                echo "Enter 4 to exit"
                read -p "Please enter your email: " new_email
                echo $new_email
                if [ -z ${new_email} ]
                then
                        back_to_current_menu 3
                elif [ $new_password == "4" ]
                then
                        clear_screen
                        print_menu - - - '*'
                        echo "Exiting..."
                        sleep 1
                        clear_screen
                        exit 0
                else
                        # Password is not empty so lets save it in credentials file
                        echo "Email: $new_email"
                        clear_screen
                        print_menu - - '*' -
                        email=$new_email
                        update_current_email
                        populate_current_email
                        sleep 0.5
                        clear_screen
                        print_menu - - '*' -
                        echo "Email: $new_email successfully saved. Redirecting back to main menu in 3 seconds"
                        sleep 3
                        # go to main screen
                        main
                fi
	elif [ $1 == 4 ]
	then
        	clear_screen
        	print_menu - - - '*'
        	echo "Exiting..."
        	sleep 1
		clear_screen
        	exit 0
	else
        	clear_screen
        	print_menu - - - -
        	echo "Incorrect selection"
		sleep 1
        	echo "Going back to main screen..."		
        	sleep 1
        	main
	fi

}

main() {
	clear_screen
	populate_current_credentials
	print_menu - - - -
	read_selection
	$REPLY=$?
	menu_selection $REPLY
}

main

