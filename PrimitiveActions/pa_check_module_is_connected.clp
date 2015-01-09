(defrule check_module_is_connected-send_command
	(task (id ?t) (action_type check_module_is_connected) (params ?module))
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

(defrule check_module_is_connected-not_connected
	(task (id ?t) (plan ?planName) (action_type check_module_is_connected) (params ?module) (step $?steps) )
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_answer "connected" =(sym-cat check_module_is_connected_ ?module) 0 ?)
	=>
	(assert
		(task_status ?t failed)
	)
)

(defrule check_module_is_connected-connected
	(task (id ?t) (action_type check_module_is_connected) (params ?module))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_answer "connected" =(sym-cat check_module_is_connected_ ?module) 1 ?)
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule check_module_is_connected-finished
	(task (id ?t) (action_type check_module_is_connected) (params ?module))
	(active_task ?t)
	(task_status ?t ?)
	(not (cancel_active_tasks))
	=>
	(bind ?f
		(assert
			(checked_module_is_connected ?module)
		)
	)
	(set_delete ?f 20)
)
