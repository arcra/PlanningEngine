(defrule cubes_clear_arm-both
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params both) (step $?steps) (parent ?pt))
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
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params right) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))


	; Right arm is NOT free
	(arm_info (side right) (grabbing ?grabbed_cube&~nil))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?grabbed_cube free) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_clear_arm-left
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params left) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))


	; Left arm is NOT free
	(arm_info (side left) (grabbing ?grabbed_cube&~nil))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?grabbed_cube free) (step 1 $?steps) (parent ?t))
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				SUCCESS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_clear_arm-right-success
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params right) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (side right) (grabbing nil))
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_clear_arm-left-success
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params left) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (side left) (grabbing nil))
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_clear_arm-both-success
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params both) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (side right) (grabbing nil))
	(arm_info (side left) (grabbing nil))
	=>
	(assert
		(task_status ?t successful)
	)
)
