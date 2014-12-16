;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		COMMAND REQUESTS AND RESPONSES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule check_obstacle-door_unknown
	(task (id ?t) (action_type check_obstacle) (params "door"))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (BB_answer "mp_obstacle" check_obstacle ? ?))
	(not (waiting (symbol check_obstacle)) )
	(not (timer_sent check_obstacle_sleep ? ?))
	=>
	(send-command "mp_obstacle" check_obstacle "door" 30000)
) 

(defrule check_obstacle-door_closed
	(task (id ?t) (action_type check_obstacle) (params "door"))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	?d <-(BB_answer "mp_obstacle" check_obstacle 1 ?)
	=>
	(retract ?d)
	(setTimer 2000 check_obstacle_sleep)
)

(defrule check_obstacle-check_again
	(task (id ?t) (action_type check_obstacle) (params "door"))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	?time <-(BB_timer check_obstacle_sleep)
	=>
	(retract ?time)
	(send-command "mp_obstacle" check_obstacle "door" 30000)	
)

(defrule check_obstacle-door_open
	(task (id ?t) (plan ?planName) (step $?steps) (action_type check_obstacle) (params "door") (parent ?pt))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_answer "mp_obstacle" check_obstacle 0 ?)
	?sp <-(speech_notification_sent check_obstacle)
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

(defrule check_obstacle-start_speech
	(task (id ?t) (plan ?planName) (action_type check_obstacle) (params "door") (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(waiting (symbol check_obstacle))
	(not (speech_notification_sent check_obstacle) )
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm waiting for the door to be opened.") (step (- ?step 1) $?steps) (parent ?pt))
		(speech_notification_sent check_obstacle)
	)
	(setTimer 10000 check_obstacle_speech)
)

(defrule check_obstacle-speechtimer_timedout_before_door_is_open
	(task (id ?t) (plan ?planName) (action_type check_obstacle) (params "door") (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (BB_answer "mp_obstacle" check_obstacle 0 ?) )
	(BB_timer check_obstacle_speech)
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm still waiting for the door to be opened.") (step (- ?step 1) $?steps) (parent ?pt))
	)
)
