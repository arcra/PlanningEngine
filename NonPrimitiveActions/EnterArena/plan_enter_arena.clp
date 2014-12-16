(defrule enter_arena-task
	(task (id ?t) (plan ?planName) (action_type enter_arena) (params ?entrance_location) (step $?steps))
	(active_task ?t)
	(not 
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (executed))
	=>
	(assert
		(executed)
;		(task (plan ?planName) (action_type force_fail) (step 0 $?steps) (parent ?t) )
		(task (plan ?planName) (action_type check_getclose_location) (params ?entrance_location)
			(step 1 $?steps) (parent ?t) )
		(task (plan ?planName) (action_type wait_obstacle) (params "door") (step 2 $?steps) (parent ?t) )
		(task (plan ?planName) (action_type arms_goto) (params "navigation") (step 3 $?steps)
			(parent ?t) )
		(task (plan ?planName) (action_type getclose_location) (params ?entrance_location)
			(step 4 $?steps) (parent ?t) )
	)
)

