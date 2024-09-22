#!/bin/bash

#####################################################
# @Author: Muhammad Nasir Akram
# Last_change: 26.08.2024
#####################################################

# global variables
minute=""
hour=""
day=""
month=""
year=""
day_of_week=""
schedule=""
edit_conf_file=""
file_name=""
temp_cron_file=""
EXP_DIR=ConfigBot
PWD=$HOME/$EXP_DIR
EXPECT_FILE=NetAutoConfig
CONFIG_INPUT_DIR=config_input
CONFIG_OUTPUT_DIR=config_ouput
CONFIGURATION_FILE=""
DEVICE_NAME=""
TASKS_DIR=scheduled_tasks
TEMP_DIR=temp
EMAIL_FILE=EmailAddress.txt
EMAIL=""
NOTIFY_THROUGH_EMAIL="YES"
TASK_IDENTIFIER=""
TASK=scheduled_tasks.log
COMPLETED_TASKS=completed_tasks.log

clear_screen () {
	printf "\033c"
}

print_menu () {
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo " ██████╗██████╗███╗   ███████████╗██████╗     ██████╗ ██████╗████████╗
██╔════██╔═══██████╗  ████╔════████╔════╝     ██╔══████╔═══██╚══██╔══╝
██║    ██║   ████╔██╗ ███████╗ ████║  ███╗    ██████╔██║   ██║  ██║   
██║    ██║   ████║╚██╗████╔══╝ ████║   ██║    ██╔══████║   ██║  ██║   
╚██████╚██████╔██║ ╚██████║    ██╚██████╔╝    ██████╔╚██████╔╝  ██║   
 ╚═════╝╚═════╝╚═╝  ╚═══╚═╝    ╚═╝╚═════╝     ╚═════╝ ╚═════╝   ╚═╝   "
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "What would you like to to do?"					   
	echo "$1 1 - Create a config file & run it at a specific time"
	echo "$2 2 - Run an existing config at a specific time"	
	echo "$3 3 - Edit an exiting config file"
	echo "$4 4 - Remove an existing task"
	echo "$5 5 - Exit"
	echo "------------------------------------------------------"
}

generate_random_string() {
	random_string=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
}

get_timestamp() {
	currentTimestamp=$(date '+%d-%m-%Y_%H-%M-%S')
}

get_current_timestamp() {
	timestamp=$(date '+%H:%M       %d/%m/%Y')
}

populate_time_variables() {
	minute=$(date '+%M')
	hour=$(date '+%H')
	day=$(date '+%d')
	month=$(date '+%m')
	year=$(date '+%Y')
	day_of_week=$(date '+%u')
}

populate_current_email() {
        file_exists $PWD/$EMAIL_FILE
        if [ $? == 1 ]
        then
                read -r line < $PWD/$EMAIL_FILE
		EMAIL=$line 
		sleep 3
                if [ -z ${EMAIL} ]
                then
                        EMAIL="x"
                fi
        else
                touch $PWD/EmailAddress.txt
        fi
}

create_a_config_file_name() {
	get_timestamp
	generate_random_string
	random_file_name="${currentTimestamp}_${random_string}.conf"
}

create_a_config_file_name_with_prepend() {
	create_a_config_file_name
	prepend=$1
	postpend=$random_file_name
	random_file_name_with_prepend=""
	if [ -z $prepend ]
        then
		random_file_name_with_prepend=$postpend
	else
		random_file_name_with_prepend="$1_$postpend"
	fi
}

create_temp_cron_file_name() {
	get_timestamp
	generate_random_string
	temp_cron_file="${currentTimestamp}_${random_string}.cron"
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

input_is_integer() {
	if ! [[ "$1" =~ ^[0-9]+$ ]]
    	then
        	echo "Sorry integers only"
		return 0
	else
		return 1
	fi
}

create_input_file() {
	file_exists $PWD/$CONFIG_INPUT_DIR/$1
	result=$?
	if [ $result == 1 ]
	then
		echo "Error: File $1 already exits in $PWD/$CONFIG_INPUT_DIR"
		echo "Provide a different name"
		# lets go back to the step 1
		sleep 4
		menu_selection 1
	elif [ $result == 0 ]
	then
        	touch $PWD/$CONFIG_INPUT_DIR/$1
	else
		echo "An error has occured while checking for the existance of the file"
	fi
}

print_schedule_format() {
	get_current_timestamp
	echo "Current Timestamp:  $timestamp"
	echo ""
	echo " ______________ Hour            (0-23) $hour"
	echo "|  ____________ Minute          (0-59) $minute"
	echo "| |  __________ Day             (1-31) $day"
	echo "| | |  ________ Month           (1-12) $month"
	echo "| | | |"
	echo "| | | |"
	echo "* * * *"
}

print_schedule_format_completed() {
        get_current_timestamp
        echo "Current Timestamp:  $timestamp"
        echo ""
	echo "           ____ Hour            ($hour)"
	echo "          |____ Minute          ($minute)"
	echo "Complete->|____ Day             ($day)"
	echo "          |____ Month           ($month)"
	echo ""
	echo "Scheduled for:	    $hour:$minute	$day/$month/$year"
}

print_file_completed() {
	echo "          "
        echo "Complete->|____ config          ($CONFIGURATION_FILE)"
        echo "               "
}

print_device_completed() {
        echo "Complete->|____ device          ($DEVICE_NAME)"
        echo "               "
}

save_schedule() {
	schedule="$minute $hour $day $month *"
	clear_screen
        print_menu - '*' - - -
        print_config_file
        print_schedule
        echo "Enter 99 to exit"
        print_schedule_format_completed
	populate_file
}

print_config_file() {
	echo "configuration file: $CONFIGURATION_FILE"
}

print_schedule() {
	echo "Schedule: $schedule - 88 to start over"
}

populate_device() {
        echo "______________________________"
	echo "Please enter device-ip or hostname:"
        read device
        if [ -z "$device" ]
        then
		echo "Device-ip or hostname cannot be empty"
		sleep 2
		print_schedule_file_tree
                populate_device
        else
		if [ $device == "99" ]
        	then
                	clear_screen
                	print_menu - '*' - - -
                	echo "Exiting..."
                	sleep 0.7
                	clear_screen
                	exit 0
        	elif [ $device == "88" ]
        	then
                	echo "Starting over again..."
                	sleep 1
                	schedule=""
                	menu_selection 2
		else
			# is not empty
			DEVICE_NAME=$device
			print_schedule_file_tree
                	confirm_schedule_task
		fi
        fi
}

confirm_schedule_task() {
	echo "______________________________"
	read -p "Schedule task? (yes|no) default yes: " confirm
	if [ -z "$confirm" ]
	then
		schedule_task
	else
		echo "Yes or No"
		if [ "$confirm" == "yes" ]
		then
			schedule_task
		elif [ "$confirm" == "no" ]
		then
			main
		else
			echo "Wrong selection"
			sleep 2
			populate_file
		fi
	fi
}

confirm_remove_schedule() {
        clear_screen
        print_menu - - - '*' -
        echo "Please enter the identification string which was emailed to you. It can also be found in the list of cronjobs."
        read -p "Task-Identifier: " task_identifier
        if [ -z ${task_identifier} ]
        then
                echo "identifier string was empty"
                sleep 2
                #
		confirm_remove_schedule
        else
                # user did enter the task identifier, check if this identifier exists in the scheduled_tasks/scheduled_tasks.log
                if grep -Fxq $task_identifier $PWD/$TASKS_DIR/$TASK
                then
			remove_schedule_confirmed $task_identifier
			echo "Sucessfully removed!"
			TASK_IDENTIFIER=$task_identifier
			notify_through_email_schedule_cancelled
			sleep 1
                        clear_screen
                	print_menu - - - '*' -
                	echo "Exiting..."
                	sleep 1
                	clear_screen
                	exit 0 
                else
			clear_screen
                        print_menu - - - '*' -
                        echo "Identifier not found, possibly removed or invalid identifier supplied."
                        sleep 6
			clear_screen
                	print_menu - - - - -
                	echo "Going back to main screen..."
                	sleep 1
                	main
                fi

        fi
}

print_schedule_file_tree() {
	clear_screen
        print_menu - '*' - - -
        print_config_file
        print_schedule
        echo "Enter 99 to exit"
        if [ -z "$schedule" ]
        then
        	sch=$schedule	
        else
        	print_schedule_format_completed
        fi
        print_file_completed
	if [ -z "$DEVICE_NAME" ]
        then
        	sch=$schedule
        else
        	print_device_completed
        fi
}

notify_through_email_schedule() {
	populate_current_email
	contents="____⫯____ 
\n [▣🝙▣]　　
\n\nHello, \n\nScheduled task details: \n--------------------------------------------------------------------------------------\n| Time: $hour:$minute  Date: $day.$month.$year \n| Configuration File: $CONFIGURATION_FILE \n| Device: $DEVICE_NAME \n| Identifier: $TASK_IDENTIFIER \n--------------------------------------------------------------------------------------\n\nNote: When you change your windows password, make sure you change it for ConfigBot as well by running \n./ConfigBot/ChangeCreds.sh from your home directory. Thank you! \n\nBest Regards,\nConfigBot"

	echo -e $contents | mail -s "ConfigBot: Task successfully scheduled!" $EMAIL 
}

notify_through_email_schedule_cancelled() {
        populate_current_email
        contents="____⫯____
\n [▣🝙▣]　　
\n\nHello, \n\nFollowing task has been cancelled: \n--------------------------------------------------------------------------------------\n| Identifier: $TASK_IDENTIFIER \n--------------------------------------------------------------------------------------\n\nNote: When you change your windows password, make sure you change it for ConfigBot as well by running \n./ConfigBot/ChangeCreds.sh from your home directory. Thank you! \n\nBest Regards,\nConfigBot"

        echo -e $contents | mail -s "ConfigBot: Task cancelled!" $EMAIL
}

schedule_task() {
	print_schedule_file_tree
	generate_random_string
	# schedule the task
	#task="$schedule $PWD/$EXPECT_FILE $DEVICE_NAME cron $CONFIGURATION_FILE $random_string >> $PWD/logs/${year}_${month}_ConfigBot_History.log"
	TASK_IDENTIFIER=$random_string
	if [ "$NOTIFY_THROUGH_EMAIL" == "YES" ]
	then	
		task="$schedule $PWD/$EXPECT_FILE $DEVICE_NAME cron $CONFIGURATION_FILE $random_string > $PWD/logs/temp_${random_string}.log"
	elif [ "$NOTIFY_THROUGH_EMAIL" == "NO" ]
	then
		task="$schedule $PWD/$EXPECT_FILE $DEVICE_NAME cron $CONFIGURATION_FILE $random_string | tee -a $PWD/logs/${year}_${month}_ConfigBot_History.log > $PWD/logs/temp_${random_string}.log"	
	fi	
	print_schedule_file_tree
	echo "Scheduling..."
	#sleep 0.05
	create_temp_cron_file_name
	crontab -l > $PWD/$TEMP_DIR/$temp_cron_file
	echo "$task" >> $PWD/$TEMP_DIR/$temp_cron_file
	crontab $PWD/$TEMP_DIR/$temp_cron_file
	notify_through_email_schedule
	#sleep 0.05
	print_schedule_file_tree
	#do some house keeping
	echo "Successfully scheduled!"
	# Lets do some house keeping
	$PWD/HouseKeeping.sh
	echo "$TASK_IDENTIFIER" >> $PWD/$TASKS_DIR/$TASK
	rm $PWD/$TEMP_DIR/$temp_cron_file
	edit_config_file_confirmation
}

remove_schedule_confirmed() {
	identifier=$1
	if [ -z "$identifier" ]
	then
		echo "Task-identifier is empty. Please try again!"
		sleep 1
                confirm_remove_schedule
	else
        	crontab -l > $PWD/$TEMP_DIR/global_cron.bak
        	grep -v "$identifier" $PWD/$TEMP_DIR/global_cron.bak > $PWD/$TEMP_DIR/inverse_cron.tmp
		crontab $PWD/$TEMP_DIR/inverse_cron.tmp
		# remove entry from scheduled tasks
		cat $PWD/$TASKS_DIR/$TASK > $PWD/$TEMP_DIR/scheduled_tasks.bak
		grep -v "$identifier" $PWD/$TEMP_DIR/scheduled_tasks.bak > $PWD/$TEMP_DIR/inverse_scheduled.tmp
		cat $PWD/$TEMP_DIR/inverse_scheduled.tmp > $PWD/$TASKS_DIR/$TASK	
	fi
}

open_config_file() {
	echo "Opening file: $CONFIGURATION_FILE"
        vim "$PWD/$CONFIG_INPUT_DIR/$CONFIGURATION_FILE"	
	clear_screen
}

edit_config_file_confirmation() {
        sleep 0.5
	echo ""
        echo "______________________________"
        read -p "Open the configration file? (yes|no) default no: " confirm_open_file
        if [ -z "$confirm_open_file" ]
        then
             echo "Exiting..."
	     sleep 0.7
	     clear_screen
	     exit 0
        else
                if [ "$confirm_open_file" == "yes" ]
                then
                        open_config_file
                elif [ "$confirm_open_file" == "no" ]
                then
                    echo "Exiting..."
		    sleep 0.7
		    clear_screen
		    exit 0
                else
                        echo "Wrong selection. Exiting..."
                        sleep 2
			clear_screen
			exit 0	
                fi
        fi

}

edit_file() {
	clear_screen
        print_menu - - '*' - -
	echo "Please enter the name of the configuration file"
	read -p "configuration file: " config_file
        if [ -z ${config_file} ]
        then
                if [ -z "$CONFIGURATION_FILE" ]
                then
                        # user did not enter anything
                        echo "You cannot leave config filename empty"
                        sleep 2
                        edit_file
                else
                        clear_screen
                        print_menu - - '*' - -
                fi
	else
		# user did enter a filename, check if the file exits
                file_exists $PWD/$CONFIG_INPUT_DIR/$config_file
                result=$?
                if [ $result == 1 ]
                then
                        echo "File exits"
                        CONFIGURATION_FILE=$config_file
                        clear_screen
                        #print_menu - - '*' -
			open_config_file
			echo "File closed!"

                else
                        echo "File: $config_file not found. Please try again"
                        sleep 2
                        edit_file
                fi
	
	fi
}



populate_file() {
        clear_screen
        print_menu - '*' - - -
        print_config_file
        print_schedule
        echo "Enter 99 to exit"
        print_schedule_format_completed
	echo ""
        echo "______________________________"
	if [ -z "$CONFIGURATION_FILE" ]
                then
			echo "Please enter the config file:"		
		else
			echo "Press ENTER to choose: $CONFIGURATION_FILE -- or name of an existing file"
	fi
        read config_file
        if [ -z ${config_file} ]
        then
		if [ -z "$CONFIGURATION_FILE" ]
		then
			# user did not enter anything
                	echo "You cannot leave config filename empty"
                	sleep 2
                	populate_file
		else
			clear_screen
                        print_menu - '*' - - -
                        print_config_file
                        print_schedule
                        echo "Enter 99 to exit"
                        if [ -z "$schedule" ]
                        then
                                $sch=$schedule
                        else
                                print_schedule_format_completed
                        fi
                        print_file_completed
                        populate_device		
		fi
               
        elif [ $config_file == "99" ]
        then
                clear_screen
                print_menu - '*' - - -
                echo "Exiting..."
                sleep 0.7
                clear_screen
                exit 0
        elif [ $config_file == "88" ]
        then
                echo "Starting over again..."
                sleep 1
                schedule=""
                menu_selection 2
        else
		echo ""
                # user did enter a filename, check if the file exits
		file_exists $PWD/$CONFIG_INPUT_DIR/$config_file
		result=$?
		if [ $result == 1 ]
		then
			echo "File exits"
			CONFIGURATION_FILE=$config_file
			clear_screen
			print_menu - '*' - - -
			print_config_file
			print_schedule
			echo "Enter 99 to exit"
			if [ -z "$schedule" ]
			then
				$sch=$schedule
			else
				print_schedule_format_completed
			fi
			print_file_completed
			populate_device
		else
			echo "File: $config_file not found. Please try again"
			sleep 2
			populate_file
		fi
        fi
}

populate_minute() {
	clear_screen
        print_menu - '*' - - -
	print_config_file
	print_schedule
        echo "Enter 99 to exit"
        print_schedule_format
        echo "__|___________________________"
	echo "Please enter the minute: ($minute)"
        read new_minute
        if [ -z ${new_minute} ]
        then
        	# user did not enter anything so populate the default value
		populate_day	
        elif [ $new_minute == "99" ]
        then
        	clear_screen
        	print_menu - '*' - - -
        	echo "Exiting..."
        	sleep 0.7
        	clear_screen
        	exit 0
	elif [ $new_minute == "88" ]
        then
		echo "Starting over again..."
		sleep 1
		schedule=""
                menu_selection 2
        else
        	# user did enter a value, check if it is within the allowed limit
		input_is_integer $new_minute
		if [ $? == 0 ]
		then
			sleep 1
			populate_minute
		fi
		if (($new_minute>=0 && $new_minute<=59))
		then
			minute=$new_minute
			populate_day	
		else
			echo "Minute not in range(0-59), try again"
			sleep 2
        		populate_minute
		fi
        fi	
}

populate_hour() {
	clear_screen
        print_menu - '*' - - -
	print_config_file
	print_schedule
        echo "Enter 99 to exit"
        print_schedule_format
        echo "|_____________________________"
	echo "Please enter the hour: ($hour)"
        read new_hour
        if [ -z ${new_hour} ]
        then
                # user did not enter anything so populate the default value
		populate_minute
        elif [ $new_hour == "99" ]
        then
                clear_screen
                print_menu - '*' - - -
                echo "Exiting..."
                sleep 0.7
                clear_screen
                exit 0
	elif [ $new_hour == "88" ]
        then
                echo "Starting over again..."
                sleep 1
		schedule=""
                menu_selection 2
        else
                # user did enter a value, check if it is within the allowed limit
		input_is_integer $new_hour
                if [ $? == 0 ]
                then
                        sleep 1
                        populate_hour
                fi
                if (($new_hour>=0 && $new_hour<=23))
                then
                        hour=$new_hour
                        populate_minute
                else
			echo "Hour not in range(0-23), try again"
                        sleep 2
                        populate_hour
                fi
        fi
}

populate_day() {
	clear_screen
        print_menu - '*' - - -
	print_config_file
	print_schedule
        echo "Enter 99 to exit"
        print_schedule_format
        echo "____|_________________________"
	echo "Please enter the day: ($day)"
        read new_day
        if [ -z ${new_day} ]
        then
                # user did not enter anything so populate the default value
		populate_month
        elif [ $new_day == "99" ]
        then
                clear_screen
                print_menu - '*' - - -
                echo "Exiting..."
                sleep 0.7
                clear_screen
                exit 0
	elif [ $new_day == "88" ]
        then
                echo "Starting over again..."
                sleep 1
		schedule=""
                menu_selection 2
        else
                # user did enter a value, check if it is within the allowed limit
		input_is_integer $new_day
                if [ $? == 0 ]
                then
                        sleep 1
                        populate_day
                fi
                if (($new_day>=1 && $new_day<=31))
                then
                        day=$new_day
                        populate_month
                else
                        echo "Day not in range(1-31), try again"
                        sleep 2
                        populate_day
                fi
        fi
}

populate_month() {
	clear_screen
        print_menu - '*' - - -
	print_config_file
	print_schedule
        echo "Enter 99 to exit"
        print_schedule_format
        echo "______|_______________________"
	echo "Please enter the month: ($month)"
        read new_month
        if [ -z ${new_month} ]
        then
                # user did not enter anything so populate the default value
		echo "Saving schedule..."
                sleep 0.4
                save_schedule
        elif [ $new_month == "99" ]
        then
                clear_screen
                print_menu - '*' - - -
                echo "Exiting..."
                sleep 0.7
                clear_screen
                exit 0
	elif [ $new_month == "88" ]
        then
                echo "Starting over again..."
                sleep 1
		schedule=""
                menu_selection 2
        else
                # user did enter a value, check if it is within the allowed limit
		input_is_integer $new_month
                if [ $? == 0 ]
                then
                        sleep 1
                        populate_month
                fi
                if (($new_month>=1 && $new_month<=12))
                then
                        month=$new_month
                        echo "Saving schedule..."
                        sleep 0.4
                        save_schedule 
                else
                        echo "Month not in range(1-12), try again"
                        sleep 2
                        populate_month
                fi
        fi
}

populate_day_of_week() {
	clear_screen
        print_menu - '*' - - -
	print_config_file
	print_schedule
        echo "Enter 99 to exit"
        print_schedule_format
        echo "________|_____________________"
        echo "Please enter the day of week:"
        read new_day_of_week
        if [ -z ${new_day_of_week} ]
        then
                # user did not enter anything so populate the default value
		echo "Saving schedule..."
		sleep 1
		save_schedule
        elif [ $new_day_of_week == "99" ]
        then
                clear_screen
                print_menu - '*' - - -
                echo "Exiting..."
                sleep 0.7
                clear_screen
                exit 0
	elif [ $new_day_of_week == "88" ]
        then
                echo "Starting over again..."
                sleep 1
		schedule=""
                menu_selection 2
        else
                # user did enter a value, check if it is within the allowed limit
		input_is_integer $new_day_of_week
                if [ $? == 0 ]
                then
                        sleep 1
                        populate_day_of_week
                fi
                if (($new_day_of_week>=0 && $new_day_of_week<=7))
                then
			# the value is within the range
                        day_of_week=$new_day_of_week
			echo "Saving schedule..."
			sleep 1
                        save_schedule
                else
                        echo "Day of week not in range(0-7), try again"
                        sleep 2
                        populate_day_of_week
                fi
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
	else
		clear_screen
		print_menu '*' - - - -
		echo "Credentials file does not exits. exiting.."
		sleep 1
		exit 0
	fi
}

update_current_credentials() {
	echo "$username:$password" > $credentials_file
}

read_selection() {
	read -p "Please enter either 1, 2, 3, 4 or 5 to exit: " $selection
	return $selection
}

back_to_current_menu() {
        clear_screen
        if [ $1 == 1 ]
        then
                print_menu 'x' - - - -
		echo "You did not enter anything, please type in again your new username."
		sleep 1.5 
		menu_selection 1
        elif [ $1 == 2 ]
        then
                print_menu - '*' - - -
		echo "You cannot leave password empty, please type in again your new password."
                sleep 1.5
                menu_selection 2
	elif [ $1 == 5 ]
	then
		echo "Exiting..."
		clear_screen
		exit 0
	else
                print_menu - - - - '*'
		exit 0
        fi
}

menu_selection() {
	
	if [ $1 == 1 ]
	then
        	clear_screen
        	print_menu '*' - - - -
		echo "Note: If no filename is entered, a random filename will be generated"
		echo "      furthermore '.conf' extension will be added automatically to the file"
		read -p "configuration file: " new_filename
		new_filename="${new_filename// /_}"
		if [ -z ${new_filename} ]
		then
			# no file_name entered, will generate one automatically
			#back_to_current_menu 1
			create_a_config_file_name
			# lets ask the user if he/she wants to add a prepend to it
			clear_screen
			print_menu '*' - - - -
			echo "configuration file: $random_file_name"
			echo "[PREPEND] optional:"
			read prepend
			prepend="${prepend// /_}"
			if [ -z ${prepend} ]
			then
				clear_screen
                                        print_menu '*' - - - -
				# no prpend entered
				echo "configuration file: $random_file_name"
				CONFIGURATION_FILE=$random_file_name
				echo "file successfully created"
				create_input_file $random_file_name
				sleep 1
				menu_selection 2
			else
				# prepend was typed
				create_a_config_file_name_with_prepend $prepend
				clear_screen
                        	          print_menu '*' - - -
				CONFIGURATION_FILE=$random_file_name_with_prepend
				echo "configuration file: $random_file_name_with_prepend"
				echo "file successfully created"
				create_input_file $random_file_name_with_prepend
				sleep 1
				menu_selection 2
			fi

		elif [ $new_filename == "5" ]
		then
			clear_screen
			print_menu '*' - - - -
			echo "Exiting..."
			sleep 0.7
			clear_screen
			exit 0
		else
			# Filename is not empty, so lets create the file with the supplied name
			file_to_be_created=${new_filename}".conf"
			CONFIGURATION_FILE=$file_to_be_created
			clear_screen
                        print_menu '*' - - -
                        echo "configuration file: $file_to_be_created"
			echo "file successfully created"
                        create_input_file $file_to_be_created
                        sleep 2
                        menu_selection 2
		fi
	elif [ $1 == 2 ]
	then
		populate_time_variables
		populate_hour
	elif [ $1 == 3 ]
        then
                print_menu - - '*' - -
                edit_file	
	elif [ $1 == 4 ]
        then
                print_menu - - - '*' -
                confirm_remove_schedule
	elif [ $1 == 5 ]
	then
        	clear_screen
        	print_menu - - - - '*'
        	echo "Exiting..."
        	sleep 0.7
		clear_screen
        	exit 0
	else
        	clear_screen
        	print_menu - - - - -
        	echo "Incorrect selection"
		sleep 1
        	echo "Going back to main screen..."		
        	sleep 1
        	main
	fi

}

main() {
	clear_screen
	print_menu - - - - -
	read_selection
	$REPLY=$?
	menu_selection $REPLY
}

main

