################################
#         DEXEC RULES
################################

(defrule check_getclose_position-decompose
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_getclose_position) (params ?x ?y ?angle) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(checked module_is_connected MVN_PLN)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params MVN_PLN) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_getclose_position-detected-not_connected-MVN_PLN
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_getclose_position) (params ?x ?y ?angle) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(checked module_is_connected MVN_PLN)
	(module (name MVN_PLN) (status disconnected))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params MVN_PLN) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

(defrule check_getclose_position-clear-checked_module
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_getclose_position) (params ?x ?y ?angle) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(checked module_is_connected MVN_PLN)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

