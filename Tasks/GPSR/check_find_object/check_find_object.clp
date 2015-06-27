################################
#         DEXEC RULES
################################

(defrule check_find_object-check_module-VISION
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(checked module_is_connected VISION)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params VISION) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_find_object-module_disconnected-VISION
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(module (name VISION) (status disconnected))
	?pnpdt_f1__ <-(checked module_is_connected VISION)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params VISION) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

(defrule check_find_object-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(check_find_object $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

