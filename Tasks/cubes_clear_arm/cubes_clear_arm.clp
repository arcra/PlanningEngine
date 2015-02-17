(defrule cubes_clear_arm-both
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params both) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (children_status ?t ?))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_clear_arm) (params left) (step 1 $?steps) (parent ?t))
		(task (plan ?planName) (action_type cubes_clear_arm) (params right) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_clear_arm-execute
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params ?side) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))


	; ?side arm is NOT free
	(arm_info (side ?side) (grabbing ?grabbed_cube&~nil) (enabled TRUE))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?grabbed_cube free) (step 1 $?steps) (parent ?t))
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				SUCCESS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_clear_arm-success
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params ?side) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (side ?side) (grabbing nil))
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_clear_arm-failed
	(task (id ?t) (plan ?planName) (action_type cubes_clear_arm) (params ?side) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (side ?side) (grabbing ~nil) (enabled FALSE))
	=>
	(assert
		(task_status ?t failed)
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
