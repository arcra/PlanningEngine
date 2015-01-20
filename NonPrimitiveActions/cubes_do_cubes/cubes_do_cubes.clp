(defglobal ?*cube_side* = 0.04)
(defglobal ?*cube_offset* = 0.1)

(defrule cubes_do_cubes-detect_error
	(declare (salience 100))

	?cg1 <-(cubes_goal $? ?cube $?)
	?cg2 <-(cubes_goal $? ?cube $?)
	(test (neq ?cg1 ?cg2))
	=>
	(retract ?cg2)
	(log-message WARNING "Incompatible cubes goals were created! Dropped one.")
)

;	EXECUTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_do_cubes-get_info
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(cubes_goal $?stack)
	(not (stack $?stack))
	(not (cubes_do_cubes getting_info))
	(not (cubes_do_cubes info_ready))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_get_info) (step 1 $?steps) (parent ?t))
		(cubes_do_cubes getting_info)
	)
)

(defrule cubes_do_cubes-get_info-failed
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(children_status ?t failed)
	?f <-(cubes_do_cubes getting_info)
	=>
	(retract ?f)
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I couldn't find any cubes. I will try again.")
			(step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_do_cubes-get_info-succeeded-cube_not_found
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?f <-(cubes_do_cubes getting_info)
	(stack $?)
	(cubes_goal $? ?cube $?)
	(not (cube ?cube $?))
	=>
	(retract ?f)
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I didn't see the cube " ?cube ". I will look again.") (step 1 $?steps) (parent ?t))
		
	)
)

(defrule cubes_do_cubes-get_info-succeeded
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?f <-(cubes_do_cubes getting_info)
	(stack $?)
	(not
		(and
			(cubes_goal $? ?cube $?)
			(not (cube ?cube $?))
		)
	)
	=>
	(retract ?f)
	(assert
		(cubes_do_cubes info_ready)
	)
)

(defrule cubes_do_cubes-stack_cubes
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(cubes_goal $?stack)
	(not (stack $?stack))
	(cubes_do_cubes info_ready)
	(not (cubes_do_cubes stacking_cubes))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_stack_cubes) (step 1 $?steps) (parent ?t))
		(cubes_do_cubes stacking_cubes)
	)
)

(defrule cubes_do_cubes-stack_cubes-fail-speak
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(children_status ?t failed)
	(cubes_do_cubes info_ready)
	(cubes_do_cubes stacking_cubes)
	(not (cubes_do_cubes failed_speaking))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I couldn't manage to stack the cubes. I will try again.") (step 1 $?steps) (parent ?t))
		(cubes_do_cubes failed_speaking)
	)
)

(defrule cubes_do_cubes-stack_cubes-fail-clear_flags
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(children_status ?t ?)
	?f1 <-(cubes_do_cubes info_ready)
	?f2 <-(cubes_do_cubes stacking_cubes)
	?f3 <-(cubes_do_cubes failed_speaking)
	=>
	(retract ?f1 ?f2 ?f3)
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


(defrule cubes_do_cubes-finish-clear_arms
	(task (id ?t) (plan ?planName) (action_type cubes_do_cubes) (step $?steps))
	(active_task ?t)
	?ts <-(task_status ?t successful)
	(not (cubes_goal $?))
	
	(or
		(arm_info (side right) (grabbing ~nil))
		(arm_info (side left) (grabbing ~nil))
	)
	=>
	(retract ?ts)
	(assert
		(task (plan ?planName) (action_type cubes_clear_arm) (params both) (step 1 $?steps) (parent ?t))
	)
)
