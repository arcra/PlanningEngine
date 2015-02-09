(defrule cubes_delete_info-delete_stacks
	(task (id ?t) (plan ?planName) (action_type cubes_delete_info))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?s <-(stack $?)
	=>
	(retract ?s)
)


(defrule cubes_delete_info-delete_cubes
	(task (id ?t) (plan ?planName) (action_type cubes_delete_info))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack $?))
	?c <-(cube $?)
	=>
	(retract ?c)
)

(defrule cubes_delete_info-finish
	(task (id ?t) (plan ?planName) (action_type cubes_delete_info))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack $?))
	(not (cube $?))
	=>
	(assert
		(task_status ?t successful)
	)
)
