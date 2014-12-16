;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		COMMAND REQUESTS AND RESPONSES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule getclose_location-not_moved
	(task (id ?t) (action_type getclose_location) (params ?location))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (moving))
	=>
	(assert
		(moving)
	)
	(send-command "mp_getclose" getclose_location ?location 180000)
)

(defrule getclose_location-timeout_before_answer_or_failed
	(task (id ?t) (plan ?planName) (action_type getclose_location) (params ?location) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	?m <-(moving)
	?sp <-(speech_notification_sent getclose_location)
	(BB_answer "mp_getclose" getclose_location 0 ?location)
	=>
	(retract ?m ?sp)
	(assert
		(task (plan ?planName) (action_type spg_say) (params "It seems I couldn't manage to get there, I will check for problems and try again.") (step (- ?step 2) $?steps) (parent ?pt) )
		(task (plan ?planName) (action_type check_getclose_location) (step (- ?step 1) $?steps) (params ?location) (parent ?pt))
	)
)

(defrule getclose_location-succeeded
	(task (id ?t) (plan ?planName) (step $?steps) (action_type getclose_location) (params ?location) (parent ?pt))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	?m <-(moving)
	?sp <-(speech_notification_sent getclose_location)
	(BB_answer "mp_getclose" getclose_location 1 ?location)
	=>
	(retract ?m ?sp)
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I arrived to the" ?location) (step $?steps) (parent ?pt) )
		(task_status ?t successful)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			SPEECH NOTIFICATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule getclose_location-start_speech
	(task (id ?t) (plan ?planName) (action_type getclose_location) (params ?location) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(waiting (symbol getclose_location))
	(not (speech_notification_sent getclose_location) )
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm going to the" ?location) (step (- ?step 1) $?steps) (parent ?pt) )
		(speech_notification_sent getclose_location)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			CANCEL TASK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule getclose_location-cancel-start_cancel
	(task (id ?t) (action_type getclose_location))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(cancel_active_tasks)
	(not (BB_answer "mp_stop" cancel_getclose_location ? ?))
	(not (waiting (symbol cancel_getclose_location)))
	=>
	(send-command "mp_stop" cancel_getclose_location "" 1000)
)

(defrule getclose_location-cancel-successful_response
	(task (id ?t) (action_type getclose_location))
	?at <-(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(cancel_active_tasks)
	(BB_answer "mp_stop" cancel_getclose_location 1 ?)
	=>
	(retract ?at)
)

(defrule getclose_location-cancel-failed_response
	(task (id ?t) (action_type getclose_location))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(cancel_active_tasks)
	(BB_answer "mp_stop" cancel_getclose_location 0 ?)
	=>
	(send-command "mp_stop" cancel_getclose_location "" 1000)
)
