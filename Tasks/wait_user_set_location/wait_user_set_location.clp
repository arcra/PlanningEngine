(defrule wait_user_set_location-start_timer
	(task (id ?t) (action_type wait_user_set_location))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (waiting (symbol wait_user_set_location)))
	(not (BB_answer "mp_position" wait_user_set_location ? ?))
	(not (timer_sent wait_user_set_location $?))
	(not (BB_timer wait_user_set_location $?))
	(speech_notification_sent wait_user_set_location)
	=>
	(setTimer 5000 wait_user_set_location)
)

(defrule wait_user_set_location-timedout_or_failed
	(task (id ?t) (action_type wait_user_set_location))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))
	
	(BB_answer "mp_position" wait_user_set_location 0 ?)
	=>
	(setTimer 1000 wait_user_set_location)
)

(defrule wait_user_set_location-timer_alarm
	(task (id ?t) (action_type wait_user_set_location) (params ?location))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_timer wait_user_set_location)
	=>
	(send-command "mp_position" wait_user_set_location ?location)
)

(defrule wait_user_set_location-succeeded
	(task (id ?t) (action_type wait_user_set_location))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "mp_position" wait_user_set_location 1 ?)
	=>
	(assert
		(task_status ?t succeeded)
	)
)


; SPEECH RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_user_set_location-send_speech
	(task (id ?t) (plan ?planName) (action_type wait_user_set_location) (params ?location) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (speech_notification_sent wait_user_set_location))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "Please set the location" ?location " in the map, so I can continue with the execution.") (step (- ?step 1) $?steps) (parent ?pt))
		(speech_notification_sent wait_user_set_location)
	)
	(setTimer 10000 wait_user_set_location_speech)
)

(defrule wait_user_set_location-send_speech_again
	(task (id ?t) (action_type wait_user_set_location))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))
	
	?sn <-(speech_notification_sent wait_user_set_location)
	?timer <-(BB_timer wait_user_set_location_speech)
	=>
	(retract ?timer ?sn)
)


; FINISHED RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_user_set_location-succeeded
	(task (id ?t) (action_type wait_user_set_location))
	(active_task ?t)
	(task_status ?t ?)
	?sn <-(speech_notification_sent wait_user_set_location)
	=>
	(retract ?sn)
)
