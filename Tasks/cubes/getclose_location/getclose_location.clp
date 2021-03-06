;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		COMMAND REQUESTS AND RESPONSES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule getclose_location-not_moved
	(task (id ?t) (action_type getclose_location) (params ?location))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))
	
	(speech_notification_sent getclose_location)
	(not (moving))
	=>
	(assert (moving))
	(send-command "mp_getclose" getclose_location ?location 180000)
)

(defrule getclose_location-timeout_before_answer_or_failed
	(task (id ?t) (plan ?planName) (action_type getclose_location) (params ?location) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(moving)
	(speech_notification_sent getclose_location)
	(BB_answer "mp_getclose" getclose_location 0 ?location)
	(not (getclose_location failed_speech))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "It seems I couldn't manage to get there, I will check for problems and try again.") (step 1 $?steps) (parent ?t) )
		(getclose_location failed_speech)
	)
)

(defrule getclose_location-check_getclose_location
	(task (id ?t) (plan ?planName) (action_type getclose_location) (params ?location) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?m <-(moving)
	?sp <-(speech_notification_sent getclose_location)
	?f <-(getclose_location failed_speech)
	=>
	(retract ?m ?sp ?f)
	(assert
		(task (plan ?planName) (action_type check_getclose_location) (step 1 $?steps) (params ?location) (parent ?t))
	)
)

(defrule getclose_location-succeeded-speech
	(task (id ?t) (plan ?planName) (step $?steps) (action_type getclose_location) (params ?location))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(moving)
	(speech_notification_sent getclose_location)
	(BB_answer "mp_getclose" getclose_location 1 ?location)
	(not (getclose_location succeeded))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I arrived to the" ?location) (step 1 $?steps) (parent ?t))
		(getclose_location succeeded)
	)
)


(defrule getclose_location-succeeded
	(task (id ?t) (plan ?planName) (step $?steps) (action_type getclose_location) (params ?location))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?m <-(moving)
	?sp <-(speech_notification_sent getclose_location)
	?f <-(getclose_location succeeded)
	=>
	(retract ?m ?sp ?f)
	(assert
		(task_status ?t successful)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			SPEECH NOTIFICATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule getclose_location-start_speech
	(task (id ?t) (plan ?planName) (action_type getclose_location) (params ?location) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (speech_notification_sent getclose_location))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm going to the" ?location)
			(step 1 $?steps) (parent ?t))
		(speech_notification_sent getclose_location)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			CANCEL TASK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule getclose_location-cancel-start_cancel
	(task (id ?t) (action_type getclose_location))
	(active_task ?t)
	(not (task_status ?t ?))
	(cancel_active_tasks)

	(moving)
	(not (BB_answer "mp_stop" cancel_getclose_location ? ?))
	(not (waiting (symbol cancel_getclose_location)))
	=>
	(send-command "mp_stop" cancel_getclose_location "" 1000)
)

(defrule getclose_location-cancel-failed_response
	(task (id ?t) (action_type getclose_location))
	(active_task ?t)
	(not (task_status ?t ?))
	(cancel_active_tasks)

	(moving)
	(BB_answer "mp_stop" cancel_getclose_location 0 ?)
	=>
	(send-command "mp_stop" cancel_getclose_location "" 1000)
)

(defrule getclose_location-cancel-successful_response-moving-speech
	(task (id ?t) (action_type getclose_location))
	(active_task ?t)
	(not (task_status ?t ?))
	(cancel_active_tasks)

	(BB_answer "mp_stop" cancel_getclose_location 1 ?)
	?sn <-(speech_notification_sent getclose_location)
	?m <-(moving)
	=>
	(retract ?sn ?m)
)

(defrule getclose_location-cancel-successful_response-not_moving-speech
	(task (id ?t) (action_type getclose_location))
	(active_task ?t)
	(not (task_status ?t ?))
	(cancel_active_tasks)

	;(BB_answer "mp_stop" cancel_getclose_location 1 ?)
	?sn <-(speech_notification_sent getclose_location)
	(not (moving))
	=>
	(retract ?sn)
)
