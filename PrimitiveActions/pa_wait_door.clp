;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		COMMAND REQUESTS AND RESPONSES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule wait_door-door_unknown
	?p <-(plan (action_type wait_door) (params "door"))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (BB_answer "mp_obstacle" wait_door ? ?))
	(not (waiting (symbol wait_door)) )
	(not (timer_sent wait_door_sleep ? ?))
	=>
	(send-command "mp_obstacle" wait_door "door" 30000)
) 

(defrule wait_door-door_closed
	?p <-(plan (action_type wait_door) (params "door"))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	?d <-(BB_answer "mp_obstacle" wait_door 1 ?)
	=>
	(retract ?d)
	(setTimer 2000 wait_door_sleep)
)

(defrule wait_door-check_again
	?p <-(plan (action_type wait_door) (params "door"))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	?t <-(BB_timer wait_door_sleep)
	=>
	(retract ?t)
	(send-command "mp_obstacle" wait_door "door" 30000)	
)

(defrule wait_door-door_open
	?p <-(plan (task ?taskName) (step $?steps) (action_type wait_door) (params "door"))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "mp_obstacle" wait_door 0 ?)
	?sp <-(speech_notification_sent wait_door)
	=>
	(retract ?sp)
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "I can see now that the door is open.")
			(step $?steps) )
		
		(plan_status ?p successful)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			SPEECH NOTIFICATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule wait_door-start_speech
	?p <-(plan (task ?taskName) (action_type wait_door) (params "door") (step ?step $?steps))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(waiting (symbol wait_door))
	(not (speech_notification_sent wait_door) )
	=>
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "I'm waiting for the door to be opened.") (step (- ?step 1) $?steps) )
		(speech_notification_sent wait_door)
	)
	(setTimer 10000 wait_door_speech)
)

;(defrule wait_door-response_received_before_door_is_open
;	(active_plan (task ?taskName) (action_type wait_door) (params "door") (step $?steps))
;	(not
;		(plan_status (task ?taskName) (action_type wait_door) (params "door") (step $?steps))
;	)
;	(not (BB_answer "mp_obstacle" wait_door 0 ?) )
;	(BB_answer "spg_say" wait_door_speech ? ?)
;	=>
;	(setTimer 10000 wait_door_speech)
;)

(defrule wait_door-speechtimer_timedout_before_door_is_open
	?p <-(plan (task ?taskName) (action_type wait_door) (params "door") (step ?step $?steps))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (BB_answer "mp_obstacle" wait_door 0 ?) )
	(BB_timer wait_door_speech)
	=>
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "I'm still waiting for the door to be opened.") (step (- ?step 1) $?steps) )
	)
)
