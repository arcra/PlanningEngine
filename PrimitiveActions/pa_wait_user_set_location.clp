(defrule wait_user_set_location-start_timer
	?p <-(plan (action_type wait_user_set_location))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (waiting (symbol wait_user_set_location)))
	(not (BB_answer "mp_position" wait_user_set_location ? ?))
	(not (timer_sent wait_user_set_location $?))
	(speech_notification_sent wait_user_set_location)
	=>
	(setTimer 5000 wait_user_set_location)
)

(defrule wait_user_set_location-timedout_or_failed
	?p <-(plan (action_type wait_user_set_location))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "mp_position" wait_user_set_location 0 ?)
	=>
	(setTimer 1000 wait_user_set_location)
)

(defrule wait_user_set_location-timer_alarm
	?p <-(plan (action_type wait_user_set_location) (params ?location))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_timer wait_user_set_location)
	=>
	(send-command "mp_position" wait_user_set_location ?location)
)

(defrule wait_user_set_location-succeeded
	?p <-(plan (action_type wait_user_set_location))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "mp_position" wait_user_set_location 1 ?)
	=>
	(assert
		(plan_status ?p succeeded)
	)
)


; SPEECH RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_user_set_location-send_speech
	?p <-(plan (task ?taskName) (action_type wait_user_set_location) (params ?location) (step $?steps))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (speech_notification_sent wait_user_set_location))
	=>
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "Please set the location" ?location " in the map, so I can continue with the execution.") (step $?steps))

		(speech_notification_sent wait_user_set_location)
	)
	(setTimer 10000 wait_user_set_location_speech)
)

(defrule wait_user_set_location-send_speech_again
	?p <-(plan (action_type wait_user_set_location))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	?sn <-(speech_notification_sent wait_user_set_location)
	(BB_timer wait_user_set_location_speech)
	=>
	(retract ?sn)
)


; FINISHED RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_user_set_location-succeeded
	?p <-(plan (action_type wait_user_set_location))
	(active_plan ?p)
	(plan_status ?p ?)
	?sn <-(speech_notification_sent wait_user_set_location)
	=>
	(retract ?sn)
)
