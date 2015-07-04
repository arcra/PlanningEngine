################################
#         DEXEC RULES
################################

(defrule check_module_is_connected-connected
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(module (name ?module) (speech_name ?sp_name) (id ?id))
	(BB_answer "connected" =(sym-cat check_module_is_connected_ ?module) 1 ?id)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(module (name ?module) (status connected) (speech_name ?sp_name) (id ?id))
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule check_module_is_connected-failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(check_module_is_connected ?module failed)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule check_module_is_connected-no_module_fact
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(module (name ?module))
	)
	(not
		(check_module_is_connected ?module failed)
	)
	=>
	(assert
		(check_module_is_connected ?module failed)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I could not check if module is connected. " (str-cat "There is no module fact for module: " ?module))) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(log-message INFO (str-cat "There is no module fact for module: " ?module))
)

(defrule check_module_is_connected-not_connected
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(module (name ?module) (speech_name ?sp_name) (id ?id))
	(BB_answer "connected" =(sym-cat check_module_is_connected_ ?module) 0 ?)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ failed)
		(module (name ?module) (status disconnected) (speech_name ?sp_name) (id ?id))
	)
)

(defrule check_module_is_connected-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(module (name ?module) (id ?id))
	(not
		(waiting (symbol =(sym-cat check_module_is_connected_ ?module)))
	)
	(not
		(BB_answer "connected" =(sym-cat check_module_is_connected_ ?module) 1 ?)
	)
	=>
	(send-command "connected" (sym-cat check_module_is_connected_ ?module) ?id  )
)

################################
#      FINALIZING RULES
################################

(defrule check_module_is_connected-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(check_module_is_connected $?)
	=>
	(retract ?pnpdt_f1__)
)

(defrule check_module_is_connected-create_flag
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params ?module) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	=>
	(assert
		(checked module_is_connected ?module)
	)
)

################################
#      CANCELING RULES
################################

