################################
#         DEXEC RULES
################################

(defrule check_getclose_location-decompose
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(checked module_is_connected MVN-PLN)
	)
	(not
		(checked location_exists ?location)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params MVN_PLN) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type check_location_exists) (params ?location) (step 2 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_getclose_location-detected-location_does_not_exist
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(error location_does_not_exist ?location)
	?pnpdt_f1__ <-(checked module_is_connected MVN_PLN)
	?pnpdt_f2__ <-(checked location_exists ?location)
	(module (name MVN_PLN) (status ?status))
	(test (neq ?status disconnected))
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type wait_user_set_location) (params ?location) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_getclose_location-detected-not_connected-MVN_PLN
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_getclose_location) (params ?location) (step $?pnpdt_steps__) )
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

(defrule check_getclose_location-clear-checked_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(checked location_exists ?location)
	=>
	(retract ?pnpdt_f1__)
)

(defrule check_getclose_location-clear-checked_module
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_getclose_location) (params ?location) (step $?pnpdt_steps__) )
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

