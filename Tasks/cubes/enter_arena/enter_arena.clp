(defrule enter_arena-decompose
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type enter_arena) (params ?entrance_location) (step ?pnpdt_step__ $?pnpdt_steps__) (parent ?pnpdt_parent__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_getclose_location) (params ?entrance_location) (step 1 ?pnpdt_step__ $?pnpdt_steps__) (parent ?pnpdt_task__))
		(task (plan ?pnpdt_planName__) (action_type wait_obstacle) (params "door") (step 2 ?pnpdt_step__ $?pnpdt_steps__) (parent ?pnpdt_task__))
		(task (plan ?pnpdt_planName__) (action_type arms_goto) (params "navigation") (step 3 ?pnpdt_step__ $?pnpdt_steps__) (parent ?pnpdt_task__))
		(task (plan ?pnpdt_planName__) (action_type getclose_location) (params ?entrance_location) (step 4 ?pnpdt_step__ $?pnpdt_steps__) (parent ?pnpdt_task__))
	)
)
