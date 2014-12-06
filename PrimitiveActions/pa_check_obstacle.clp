;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		COMMAND REQUESTS AND RESPONSES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule wait_door-door_unknown
	?t <-(task (action_type wait_door) (params "door"))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (BB_answer "mp_obstacle" wait_door ? ?))
	(not (waiting (symbol wait_door)) )
	(not (timer_sent wait_door_sleep ? ?))
	=>
	(send-command "mp_obstacle" wait_door "door" 30000)
) 

(defrule wait_door-door_closed
	?t <-(task (action_type wait_door) (params "door"))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	?d <-(BB_answer "mp_obstacle" wait_door 1 ?)
	=>
	(retract ?d)
	(setTimer 2000 wait_door_sleep)
)

(defrule wait_door-check_again
	?t <-(task (action_type wait_door) (params "door"))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	?time <-(BB_timer wait_door_sleep)
	=>
	(retract ?time)
	(send-command "mp_obstacle" wait_door "door" 30000)	
)

(defrule wait_door-door_open
	?t <-(task (plan ?planName) (step $?steps) (action_type wait_door) (params "door") (parent ?pt))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_answer "mp_obstacle" wait_door 0 ?)
	?sp <-(speech_notification_sent wait_door)
	=>
	(retract ?sp)
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I can see now that the door is open.")
			(step $?steps) (parent ?pt))
		
		(task_status ?t successful)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			SPEECH NOTIFICATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule wait_door-start_speech
	?t <-(task (plan ?planName) (action_type wait_door) (params "door") (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(waiting (symbol wait_door))
	(not (speech_notification_sent wait_door) )
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm waiting for the door to be opened.") (step (- ?step 1) $?steps) (parent ?pt))
		(speech_notification_sent wait_door)
	)
	(setTimer 10000 wait_door_speech)
)

(defrule wait_door-speechtimer_timedout_before_door_is_open
	?t <-(task (plan ?planName) (action_type wait_door) (params "door") (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (BB_answer "mp_obstacle" wait_door 0 ?) )
	(BB_timer wait_door_speech)
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm still waiting for the door to be opened.") (step (- ?step 1) $?steps) (parent ?pt))
	)
)
