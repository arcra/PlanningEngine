################################
#         DEXEC RULES
################################

(defrule check_process_string-decompose
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_process_string) (params ?string) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(checked module_is_connected LANG_UND)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params LANG_UND) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_process_string-detected-not_connected-LANG_UND
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_process_string) (params ?string) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(module (name LANG_UND) (status disconnected))
	?pnpdt_f1__ <-(checked module_is_connected LANG_UND)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params LANG_UND) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

(defrule check_process_string-clear-checked-LANG_UND
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_process_string) (params ?string) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(checked module_is_connected LANG_UND)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

