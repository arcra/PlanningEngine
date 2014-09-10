;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		COMMAND REQUESTS AND RESPONSES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule getclose_location-not_moved
	?p <-(plan (action_type getclose_location) (params ?location))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (moving))
	=>
	(assert
		(moving)
	)
	(send-command "mp_getclose" getclose_location ?location 180000)
)

(defrule getclose_location-timeout_before_answer_or_failed
	?p <-(plan (task ?taskName) (action_type getclose_location) (params ?location) (step ?step $?steps))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	?m <-(moving)
	?sp <-(speech_notification_sent getclose_location)
	(BB_answer "mp_getclose" getclose_location 0 ?location)
	=>
	(retract ?m ?sp)
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "It seems I couldn't manage to get there, I will check for problems and try again.") (step (- ?step 2) $?steps) )
		(plan (task ?taskName) (action_type check_getclose_location) (step (- ?step 1) $?steps) (params ?location))
	)
)

(defrule getclose_location-succeeded
	?p <-(plan (task ?taskName) (step $?steps) (action_type getclose_location) (params ?location))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	?m <-(moving)
	?sp <-(speech_notification_sent getclose_location)
	(BB_answer "mp_getclose" getclose_location 1 ?location)
	=>
	(retract ?m ?sp)
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "I arrived to the" ?location) (step $?steps) )
		(plan_status ?p successful)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			SPEECH NOTIFICATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule getclose_location-start_speech
	?p <-(plan (task ?taskName) (action_type getclose_location) (params ?location) (step ?step $?steps))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(waiting (symbol getclose_location))
	(not (speech_notification_sent getclose_location) )
	=>
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "I'm going to the" ?location) (step (- ?step 1) $?steps) )
		(speech_notification_sent getclose_location)
	)
)
