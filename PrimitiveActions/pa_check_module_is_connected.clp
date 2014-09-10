(defrule check_module_is_connected-send_command
	?p <-(plan (action_type check_module_is_connected) (params ?module))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (waiting (symbol (sym-cat check_module_is_connected_ ?module))))
	(not (BB_answer "connected" (sym-cat check_module_is_connected_ ?module) 1 ?))
	=>
	(send-command "connected" (sym-cat check_module_is_connected_ ?module) ?module)
)

(defrule check_module_is_connected-does_NOT_respond
	?p <-(plan (task ?taskName) (action_type check_module_is_connected) (params ?module) (step $?steps) )
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "connected" (sym-cat check_module_is_connected_ ?module) 0 ?)
	=>
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "I found the error, the module: " ?module " is not running or is not working properly.") (step $?steps))
		(plan_status ?p successful)
	)
)

(defrule check_module_is_connected-responds
	?p <-(plan (action_type check_module_is_connected) (params ?module))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "connected" (sym-cat check_module_is_connected_ ?module) 1 ?)
	=>
	(assert
		(plan_status ?p failed)
	)
)

(defrule check_module_is_connected-finished
	?p <-(plan (action_type check_module_is_connected) (params ?module))
	(active_plan ?p)
	(plan_status ?p ?)
	=>
	(assert
		(checked_module_is_connected ?module)
	)
)
