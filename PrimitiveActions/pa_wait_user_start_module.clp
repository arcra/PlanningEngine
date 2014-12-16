(defrule wait_user_start_module-start_timer
	(task (id ?t) (action_type wait_user_start_module))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (waiting (symbol wait_user_start_module)))
	(not (BB_answer "connected" wait_user_start_module ? ?))
	(not (timer_sent wait_user_start_module $?))
	(speech_notification_sent wait_user_start_module)
	=>
	(setTimer 5000 wait_user_start_module)
)

(defrule wait_user_start_module-timedout_or_failed
	(task (id ?t) (action_type wait_user_start_module))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_answer "connected" wait_user_start_module 0 ?)
	=>
	(setTimer 4000 wait_user_start_module)
)

(defrule wait_user_start_module-timer_alarm
	(task (id ?t) (action_type wait_user_start_module) (params ?module))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_timer wait_user_start_module)
	=>
	(send-command "connected" wait_user_start_module ?module)
)

(defrule wait_user_start_module-succeeded
	(task (id ?t) (action_type wait_user_start_module))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_answer "connected" wait_user_start_module 1 ?)
	=>
	(assert
		(task_status ?t succeeded)
	)
)


; SPEECH RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_user_start_module-send_speech
	(task (id ?t) (plan ?planName) (action_type wait_user_start_module) (params ?module) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (speech_notification_sent wait_user_start_module))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "Please start the module: " ?module ", so I can continue with the execution.") (step $?steps) (parent ?pt))

		(speech_notification_sent wait_user_start_module)
	)
	(setTimer 10000 wait_user_start_module_speech)
)

(defrule wait_user_start_module-send_speech_again
	(task (id ?t) (action_type wait_user_start_module))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	?sn <-(speech_notification_sent wait_user_start_module)
	(BB_timer wait_user_start_module_speech)
	=>
	(retract ?sn)
)


; FINISHED RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_user_start_module-succeeded
	(task (id ?t) (action_type wait_user_start_module))
	(active_task ?t)
	(task_status ?t ?)
	?sn <-(speech_notification_sent wait_user_start_module)
	=>
	(retract ?sn)
)
