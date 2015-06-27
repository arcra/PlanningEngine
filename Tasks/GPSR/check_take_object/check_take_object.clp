################################
#         DEXEC RULES
################################

(defrule check_take_object-check_module-ARMS
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(checked module_is_connected ARMS)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params ARMS) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_take_object-check_module-ST_PLN
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(checked module_is_connected ST-PLN)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params ST-PLN) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_take_object-check_object_reachable
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(check_take_object checked_find_object ?object)
	(not
		(error object_not_found ?object)
	)
	(not
		(checked object_is_reachable ?object)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_object_is_reachable) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_take_object-module_disconnected-ARMS
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(module (name ARMS) (status disconnected))
	?pnpdt_f1__ <-(checked module_is_connected ARMS)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params ARMS) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_take_object-module_disconnected-ST_PLN
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(module (name ST-PLN) (status disconnected))
	?pnpdt_f1__ <-(checked module_is_connected ST-PLN)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params ST-PLN) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_take_object-object_not_reachable
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (speech_name ?item_name))
	(checked object_is_reachable ?object)
	(error object_not_reachable ?object)
	(not
		(check_take_object not_reachable_speech)
	)
	=>
	(assert
		(check_take_object not_reachable_speech)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I cannot reach the " ?item_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule check_take_object-object_not_reachable_spoken
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(error object_not_reachable ?object)
	?pnpdt_f2__ <-(check_take_object not_reachable_speech)
	?pnpdt_f3__ <-(checked object_is_reachable ?object)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule check_take_object-succeeded
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(module (name VISION) (status connected))
	?pnpdt_f1__ <-(checked module_is_connected ST-PLN)
	?pnpdt_f2__ <-(checked module_is_connected ARMS)
	?pnpdt_f3__ <-(checked module_is_connected VISION)
	(module (name ST-PLN) (status connected))
	(module (name ARMS) (status connected))
	?pnpdt_f4__ <-(checked object_is_reachable ?object)
	(not
		(error object_not_reachable ?object)
	)
	(not
		(error object_not_found ?object)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__ ?pnpdt_f4__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule check_take_object-clear-checked_module
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(checked module_is_connected ?)
	=>
	(retract ?pnpdt_f1__)
)

(defrule check_take_object-clear-error-not_reachable
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(error object_not_reachable ?object)
	=>
	(retract ?pnpdt_f1__)
)

(defrule check_take_object-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(check_take_object $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

