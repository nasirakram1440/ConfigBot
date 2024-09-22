#!/bin/bash
EXP_DIR=ConfigBot
PWD=$HOME/$EXP_DIR
CONFIG_INPUT_DIR=config_input
CONFIG_OUTPUT_DIR=config_ouput
CONFIGURATION_FILE=""
DEVICE_NAME=""
TASKS_DIR=scheduled_tasks
TEMP_DIR=temp
TASK=scheduled_tasks.log
COMPLETED_TASKS=completed_tasks.log
LOG_DIR=logs

remove_completed_schedule_confirmed() {
        identifier=$1
        crontab -l > $PWD/$TEMP_DIR/global_cron.bak
	sed -i "/$identifier/d" $PWD/$TEMP_DIR/global_cron.bak
	#awk '!/$identifier/' $PWD/$TEMP_DIR/global_cron.bak
        crontab $PWD/$TEMP_DIR/global_cron.bak 
	echo "" > $PWD/$TEMP_DIR/global_cron.bak
        # remove entry from scheduled tasks
        sed -i "/$identifier/d" $PWD/$TASKS_DIR/$COMPLETED_TASKS
	#awk '!/$identifier/' $PWD/$TASKS_DIR/$COMPLETED_TASKS
	remove_schedule_confirmed $identifier
	rm $PWD/$LOG_DIR/"temp_$identifier.log"
}

remove_schedule_confirmed() {
        identifier=$1
        if [ -z "$identifier" ]
        then
                echo "Task-identifier is empty. Please try again!"
        else
                # remove entry from scheduled tasks
                sed -i "/$identifier/d" $PWD/$TASKS_DIR/$TASK
		#awk '!/$identifier/' $PWD/$TASKS_DIR/$TASK
        fi
}

remove_completed_schedules() {
        # Tasks which have been completed should be removed from cron and log files
        while IFS= read -r identifiers; do
                remove_completed_schedule_confirmed $identifiers
        done < $PWD/$TASKS_DIR/$COMPLETED_TASKS
}

remove_completed_schedules
