################################
#         DEXEC RULES
################################

(defrule wait_user_set_location-create_location_template
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_set_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(location (name ?location))
	)
	=>
	(assert
		(location (name ?location) (speech_name (str-cat ?location)))
	)
)

(defrule wait_user_set_location-speech-send_again
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_set_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_timer wait_user_set_location_speech)
	?pnpdt_f2__ <-(wait_user_set_location speech_sent)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
)

(defrule wait_user_set_location-speech-send_speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_set_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(location (name ?location) (speech_name ?loc_name))
	(not
		(wait_user_set_location speech_sent)
	)
	=>
	(assert
		(wait_user_ser_location speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "Please set the location " ?loc_name " in the map so I can continue with the execution.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 10000 wait_user_set_location_speech)
)

(defrule wait_user_set_location-succeeded
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_set_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "mp_position" wait_user_set_location 1 ?)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule wait_user_set_location-timer-start_timer
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_set_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_user_set_location speech_sent)
	(not
		(waiting (symbol wait_user_set_location))
	)
	(not
		(BB_answer "mp_position" wait_user_set_location ? ?)
	)
	(not
		(timer_sent wait_user_set_location $?)
	)
	(not
		(BB_timer wait_user_set_location)
	)
	=>
	(setTimer 5000 wait_user_set_location)
)

(defrule wait_user_set_location-timer-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_set_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "mp_position" wait_user_set_location 0 ?)
	=>
	(retract ?pnpdt_f1__)
	(setTimer 3000 wait_user_set_location)
)

(defrule wait_user_set_location-timer-timer_alarm
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_set_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_timer wait_user_set_location)
	=>
	(retract ?pnpdt_f1__)
	(send-command "mp_position" wait_user_set_location ?location  )
)

################################
#      FINALIZING RULES
################################

(defrule wait_user_set_location-clear_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_set_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(wait_user_set_location $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

