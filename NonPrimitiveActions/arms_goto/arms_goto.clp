(defrule arms_goto-decompose
	(task (plan ?planName) (id ?t) (action_type arms_goto) (params ?position) (step $?steps) )
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	=>
	(assert
		(task (plan ?planName) (action_type la_goto) (params ?position) (step 1 $?steps) (parent ?t))
		(task (plan ?planName) (action_type ra_goto) (params ?position) (step 1 $?steps) (parent ?t))
	)
)
