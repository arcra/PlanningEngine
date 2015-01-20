;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		COMMAND REQUESTS AND RESPONSES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule wait_obstacle-door_unknown
	(task (id ?t) (action_type wait_obstacle) (params "door"))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (BB_answer "mp_obstacle" wait_obstacle ? ?))
	(not (waiting (symbol wait_obstacle)) )
	(not (timer_sent wait_obstacle_sleep ? ?))
	(not (BB_timer wait_obstacle_sleep))
	=>
	(send-command "mp_obstacle" wait_obstacle "door" 30000)
)

(defrule wait_obstacle-door_closed
	(task (id ?t) (action_type wait_obstacle) (params "door"))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?d <-(BB_answer "mp_obstacle" wait_obstacle 1 ?)
	=>
	(retract ?d)
	(setTimer 2000 wait_obstacle_sleep)
)

(defrule wait_obstacle-check_again
	(task (id ?t) (action_type wait_obstacle) (params "door"))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?time <-(BB_timer wait_obstacle_sleep)
	=>
	(retract ?time)
	(send-command "mp_obstacle" wait_obstacle "door" 30000)
)

(defrule wait_obstacle-door_open-speech
	(task (id ?t) (plan ?planName) (step $?steps) (action_type wait_obstacle) (params "door"))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))
	
	(BB_answer "mp_obstacle" wait_obstacle 0 ?)
	(not (wait_obstacle door_open))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I can see now that the door is open.")
			(step $?steps) (parent ?t))
		(wait_obstacle door_open)
	)
)

(defrule wait_obstacle-door_open
	(task (id ?t) (plan ?planName) (step $?steps) (action_type wait_obstacle) (params "door"))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))
	
	(BB_answer "mp_obstacle" wait_obstacle 0 ?)
	?f <-(wait_obstacle door_open)
	=>
	(retract ?f)
	(assert
		(task_status ?t successful)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			SPEECH NOTIFICATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule wait_obstacle-start_speech
	(task (id ?t) (plan ?planName) (action_type wait_obstacle) (params "door") (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(waiting (symbol wait_obstacle))
	(not (speech_notification_sent wait_obstacle) )
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm waiting for the door to be opened.")
			(step 1 $?steps) (parent ?t))
		(speech_notification_sent wait_obstacle)
	)
	(setTimer 10000 wait_obstacle_speech)
)

(defrule wait_obstacle-speechtimer_timedout_before_door_is_open
	(task (id ?t) (plan ?planName) (action_type wait_obstacle) (params "door") (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (BB_answer "mp_obstacle" wait_obstacle 0 ?) )
	(BB_timer wait_obstacle_speech)
	=>
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I'm still waiting for the door to be opened.") (step 1 $?steps) (parent ?t))
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			FINALIZATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule wait_obstacle-clean_flag
	(task (id ?t) (plan ?planName) (step $?steps) (action_type wait_obstacle) (params "door"))
	(active_task ?t)
	(task_status ?t ?)
	(not (cancel_active_tasks))

	?sp <-(speech_notification_sent wait_obstacle)
	=>
	(retract ?sp)
)
