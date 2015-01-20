;			SUCCESSFUL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_stack_cubes-successful
	(task (id ?t) (plan ?planName) (action_type cubes_stack_cubes))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(cubes_goal $?stack)
	(stack $?stack)
	=>
	(assert
		(task_status ?t successful)
	)
)

;			EXECUTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_stack_cubes-set_base
	(task (id ?t) (plan ?planName) (action_type cubes_stack_cubes) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(cubes_goal ?base $?)
	(not (stack ?base $?))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_move_cube) (params ?base cubestable) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_stack_cubes-next_goal_cube
	(task (id ?t) (plan ?planName) (action_type cubes_stack_cubes) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(cubes_goal $?stack1 ?top_cube ?cube $?)
	(or
		(stack $?stack1 ?top_cube ~?cube $?)
		(stack $?stack1 ?top_cube)
	)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step 1 $?steps) (parent ?t))
	)
)

;(defrule cubes_stack_cubes-next_goal_cube-in_arm
;	(task (id ?t) (plan ?planName) (action_type cubes_stack_cubes) (step ?step $?steps) (parent ?pt))
;	(active_task ?t)
;	(not (task_status ?t ?))
;	(not (cancel_active_tasks))
;
;	(cubes_goal $?stack1 ?top_cube ?cube $?)
;	(stack $?stack1 ?top_cube)
;	(or
;		(right_arm ?cube)
;		(left_arm ?cube)
;	)
;	=>
;	(assert
;		(task (plan ?planName) (action_type cubes_put_cube) (params ?cube ?top_cube) (step (- ?step 1) $?steps) (parent ?pt))
;	)
;)