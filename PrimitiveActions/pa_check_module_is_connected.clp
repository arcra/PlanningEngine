(defrule check_module_is_connected-send_command
	?t <-(task (action_type check_module_is_connected) (params ?module))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (waiting (symbol =(sym-cat check_module_is_connected_ ?module))))
	(not (BB_answer "connected" =(sym-cat check_module_is_connected_ ?module) 1 ?))
	=>
	(send-command "connected" (sym-cat check_module_is_connected_ ?module) ?module)
)

(defrule check_module_is_connected-does_NOT_respond
	?t <-(task (plan ?planName) (action_type check_module_is_connected) (params ?module) (step $?steps) )
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_answer "connected" =(sym-cat check_module_is_connected_ ?module) 0 ?)
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I found the error, the module: " ?module " is not running or is not working properly.") (step $?steps) (parent ?t))
		(task_status ?t successful)
	)
)

(defrule check_module_is_connected-responds
	?t <-(task (action_type check_module_is_connected) (params ?module))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_answer "connected" =(sym-cat check_module_is_connected_ ?module) 1 ?)
	=>
	(assert
		(task_status ?t failed)
	)
)

(defrule check_module_is_connected-finished
	?t <-(task (action_type check_module_is_connected) (params ?module))
	(active_task ?t)
	(task_status ?t ?)
	=>
	(assert
		(checked_module_is_connected ?module)
	)
)
