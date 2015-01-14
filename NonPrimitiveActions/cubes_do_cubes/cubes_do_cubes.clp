(defglobal ?*cube_side* = 0.04)
(defglobal ?*cube_offset* = 0.1)

(defrule cubes_do_cubes-detect_error
	(declare (salience 100))

	(cubes_goal $? ?cube1 $? ?cube2 $?)
	?cg <-(cubes_goal $? ?cube2 $? ?cube1 $?)
	=>
	(retract ?cg)
	(log-message WARNING "Incompatible cubes goals were created! Dropped one.")
)

;	DECOMPOSE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_do_cubes-decompose
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(cubes_goal $?stack)
	(not (stack $?stack))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_get_info) (step 1 $?steps) (parent ?t))
		(task (plan ?planName) (action_type arms_goto) (params "navigation") (step 2 $?steps) (parent ?t))
		(task (plan ?planName) (action_type cubes_stack_cubes) (step 3 $?steps) (parent ?t))
	)
)


;	SET STATUS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule cubes_do_cubes-goal_reached
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?cg <-(cubes_goal $?stack)
	(stack $?stack)
	=>
	(retract ?cg)
)

(defrule cubes_do_cubes-successful
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (cubes_goal $?))
	=>
	(assert
		(task_status ?t successful)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			FINISHED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_do_cubes-not_finished
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes))
	(active_task ?t)
	?ts <-(task_status ?t ?)
	(not (cancel_active_tasks))

	(cubes_goal $?)
	=>
	(retract ?ts)
)

(defrule cubes_do_cubes-finish-fail
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	?ts <-(task_status ?t failed)
	=>
	(retract ?ts)
	(assert
		(task (plan ?planName) (action_type cubes_clear_arm) (params both) (step 1 $?steps) (parent ?t))
		(task (plan ?planName) (action_type spg_say) (params "I couldn't manage to stack the cubes. I will try again.")
			(step 2 $?steps) (parent ?t))
	)
)


(defrule cubes_do_cubes-finish-success
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	?ts <-(task_status ?t successful)
	(not (cubes_goal $?))
	(not
		(and
			(right_arm nil)
			(left_arm nil)
		)
	)
	=>
	(retract ?ts)
	(assert
		(task (plan ?planName) (action_type cubes_clear_arm) (params both) (step 1 $?steps) (parent ?t))
	)
)
