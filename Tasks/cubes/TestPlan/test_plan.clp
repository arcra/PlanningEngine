(defrule test_plan-plan
	(task (id ?t) (plan ?planName) (action_type test_plan) (params ?entrance_location) (step $?steps))
	(active_task ?t)
	(not 
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm going to execute the plan:" ?planName)
			(step 1 $?steps) (parent ?t) )
		(task (plan ?planName) (action_type enter_arena) (params ?entrance_location)
			(step 2 $?steps) (parent ?t) )
	)
)
