(defrule wait_user_start_module-start_timer
	?p <-(plan (action_type wait_user_start_module))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (waiting (symbol wait_user_start_module)))
	(not (BB_answer "connected" wait_user_start_module ? ?))
	(not (timer_sent wait_user_start_module $?))
	(speech_notification_sent wait_user_start_module)
	=>
	(setTimer 5000 wait_user_start_module)
)

(defrule wait_user_start_module-timedout_or_failed
	?p <-(plan (action_type wait_user_start_module))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "connected" wait_user_start_module 0 ?)
	=>
	(setTimer 4000 wait_user_start_module)
)

(defrule wait_user_start_module-timer_alarm
	?p <-(plan (action_type wait_user_start_module) (params ?module))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_timer wait_user_start_module)
	=>
	(send-command "connected" wait_user_start_module ?module)
)

(defrule wait_user_start_module-succeeded
	?p <-(plan (action_type wait_user_start_module))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "connected" wait_user_start_module 1 ?)
	=>
	(assert
		(plan_status ?p succeeded)
	)
)


; SPEECH RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_user_start_module-send_speech
	?p <-(plan (task ?taskName) (action_type wait_user_start_module) (params ?module) (step $?steps) (parent ?pp))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (speech_notification_sent wait_user_start_module))
	=>
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "Please start the module: " ?module ", so I can continue with the execution.") (step $?steps) (parent ?pp))

		(speech_notification_sent wait_user_start_module)
	)
	(setTimer 10000 wait_user_start_module_speech)
)

(defrule wait_user_start_module-send_speech_again
	?p <-(plan (action_type wait_user_start_module))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	?sn <-(speech_notification_sent wait_user_start_module)
	(BB_timer wait_user_start_module_speech)
	=>
	(retract ?sn)
)


; FINISHED RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_user_start_module-succeeded
	?p <-(plan (action_type wait_user_start_module))
	(active_plan ?p)
	(plan_status ?p ?)
	?sn <-(speech_notification_sent wait_user_start_module)
	=>
	(retract ?sn)
)
