(defrule cubes_clear_arm-both
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params both) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	=>
	(assert
		(task (plan ?planName) (action_type cubes_clear_arm) (params left) (step 1 $?steps) (parent ?t))
		(task (plan ?planName) (action_type cubes_clear_arm) (params right) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_clear_arm-right
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params right) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))


	; Arm in reach is NOT free
	(right_arm ?grabbed_cube&~nil)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?grabbed_cube free) (step (- ?step 1) $?steps) (parent ?pt))
	)
)

(defrule cubes_clear_arm-left
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params left) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))


	; Arm in reach is NOT free
	(left_arm ?grabbed_cube&~nil)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?grabbed_cube free) (step (- ?step 1) $?steps) (parent ?pt))
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				SUCCESS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_clear_arm-right-success
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params right) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(right_arm nil)
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_clear_arm-left-success
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params left) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(left_arm nil)
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_clear_arm-both-success
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params both) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(left_arm nil)
	(right_arm nil)
	=>
	(assert
		(task_status ?t successful)
	)
)
