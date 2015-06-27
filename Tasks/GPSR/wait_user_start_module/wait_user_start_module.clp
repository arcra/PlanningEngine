################################
#         DEXEC RULES
################################

(defrule wait_user_start_module-speech-send_again
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_timer wait_user_start_module_speech)
	?pnpdt_f2__ <-(wait_user_start_module speech_sent)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
)

(defrule wait_user_start_module-speech-send_speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(module (name ?module) (speech_name ?mod_sp))
	(not
		(wait_user_start_module speech_sent)
	)
	=>
	(assert
		(wait_user_start_module speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "Please start the " ?mod_sp " so I can continue with the execution.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 10000 wait_user_start_module_speech)
)

(defrule wait_user_start_module-succeeded
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer "connected" wait_user_start_module 1 ?)
	?pnpdt_f1__ <-(module (name ?module) (id ?mod_id) (speech_name ?sp_name))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
		(module (name ?module) (id ?mod_id) (status connected) (speech_name ?sp_name))
	)
)

(defrule wait_user_start_module-timer-start_timer
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_user_start_module speech_sent)
	(not
		(waiting (symbol wait_user_start_module))
	)
	(not
		(BB_answer "connected" wait_user_start_module ? ?)
	)
	(not
		(timer_sent wait_user_start_module $?)
	)
	(not
		(BB_timer wait_user_start_module)
	)
	=>
	(setTimer 5000 wait_user_start_module)
)

(defrule wait_user_start_module-timer-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "connected" wait_user_start_module 0 ?)
	=>
	(retract ?pnpdt_f1__)
	(setTimer 4000 wait_user_start_module)
)

(defrule wait_user_start_module-timer-timer_alarm
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(module (name ?module) (id ?mod_id))
	(BB_timer wait_user_start_module)
	=>
	(retract ?pnpdt_f1__)
	(send-command "connected" wait_user_start_module ?mod_id  )
)

################################
#      FINALIZING RULES
################################

(defrule wait_user_start_module-clear_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(wait_user_start_module $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

