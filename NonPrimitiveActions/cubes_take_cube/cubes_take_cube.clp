;				SUCCESSFUL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_take_cube-successful
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (grabbing ?cube))
	=>
	(assert
		(task_status ?t successful)
	)
)

;				EXECUTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_take_cube-arm_busy-right
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cube ?cube ? ?y ?)

	; Right arm is NOT free
	(arm_info (side right) (grabbing ?obj&~nil))
	; Cube is in right arm's reach
	;(test (< ?y ?*cube_side*))
	(test (< ?y 0))
	; Cube is NOT in left arm's reach or left arm is also busy.
	(not
		(and
			;(test (> ?y (- 0 ?*cube_side*)))
			(test (> ?y 0))
			(arm_info (side left) (grabbing nil))
		)
	)
	(not (cubes_take_cube freeing_arm ?))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?obj free)
			(step 1 $?steps) (parent ?t))
		(cubes_take_cube freeing_arm right)
	)
)

(defrule cubes_take_cube-arm_busy-left
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cube ?cube ? ?y ?)

	; Left arm is NOT free
	(arm_info (side left) (grabbing ?obj&~nil))
	; Cube is in left arm's reach
	;(test (> ?y (- 0 ?*cube_side*)))
	(test (> ?y 0))
	; Cube is NOT in right arm's reach or right arm is also busy.
	(not
		(and
			;(test (< ?y ?*cube_side*))
			(test (< ?y 0))
			(arm_info (side right) (grabbing nil))
		)
	)
	(not (cubes_take_cube freeing_arm ?))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?obj free)
			(step 1 $?steps) (parent ?t))
		(cubes_take_cube freeing_arm left)
	)
)

(defrule cubes_take_cube-arm_busy-failed
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(children_status ?t failed)
	(cubes_take_cube freeing_arm ?side)
	(not (cubes_take_cube speaking_arm_busy))
	(arm_info (side ?side) (grabbing ?obj))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I could not drop the object " ?obj ". I will try again.") (step 1 $?steps) (parent ?t))
		(cubes_take_cube speaking_arm_busy)
	)
)

(defrule cubes_take_cube-arm_busy-failed-finish
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(children_status ?t ?)
	?f1 <-(cubes_take_cube freeing_arm ?)
	?f2 <-(cubes_take_cube speaking_arm_busy)
	=>
	(retract ?f1 ?f2)
	(assert
		(task_status ?t failed)
	)
)

(defrule cubes_take_cube-cube_not_found
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (arm_info (side right) (grabbing ?cube)))
	(not (arm_info (side left) (grabbing ?cube)))
	(not (cube ?cube $?))
	(not (cubes_take_cube speaking_not_found))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I could not find the cube " ?cube ". I'll search again.") (step 1 $?steps) (parent ?t))
		(cubes_take_cube speaking_not_found)
	)
)

(defrule cubes_take_cube-cube_not_found-get_info
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?f <-(cubes_take_cube speaking_not_found)
	(children_status ?t ?)
	=>
	(retract ?f)
	(assert
		(task (plan ?planName) (action_type cubes_get_info) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_take_cube-send_right
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cube ?cube ?x ?y ?z)

	; Cube is in right arm's reach
	;(test (< ?y ?*cube_side*))
	(test (< ?y 0))
	; Right arm is free
	(arm_info (side right) (grabbing nil))
	(not (waiting (symbol take_cube_right)))
	(not (BB_answer "takexyz" take_cube_right ? ?))
	(not (cubes_taking ?cube))
	=>
	(send-command "takexyz" take_cube_right (str-cat "right " ?x " " ?y " " ?z) 60000 2)
	(assert
		(cubes_taking ?cube)
	)
)

(defrule cubes_take_cube-send_left
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cube ?cube ?x ?y ?z)

	; Cube is in left arm's reach
	;(test (> ?y (- 0 ?*cube_side*)))
	(test (> ?y 0))
	; Left arm is free
	(arm_info (side left) (grabbing nil))
	(not (waiting (symbol take_cube_left)))
	(not (BB_answer "takexyz" take_cube_left ? ?))
	(not (cubes_taking ?cube))
	=>
	(send-command "takexyz" take_cube_left (str-cat "left " ?x " " ?y " " ?z) 60000 2)
	(assert
		(cubes_taking ?cube)
	)
)

(defrule cubes_take_cube-error-speak
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "takexyz" ? 0 ?)
	(not (cubes_take_cube speaking_take_failed))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I couldn't take the cube " ?cube ". It's probably to far for me to get. I will try again.")
			(step 1 $?steps) (parent ?t))
		(cubes_take_cube speaking_take_failed)
	)
)

(defrule cubes_take_cube-error-get_info
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?f <-(cubes_taking ?)
	?sp <-(cubes_take_cube speaking_take_failed)
	(children_status ?t ?)
	=>
	(retract ?sp ?f)
	(assert
		(task (plan ?planName) (action_type cubes_get_info) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_take_cube-right_taken
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?s <-(stack $?stack ?cube)
	(BB_answer "takexyz" take_cube_right 1 ?)

	?a <-(arm_info (side right) (grabbing nil))
	=>
	(retract ?a ?s)
	(assert
		(stack $?stack)
		(arm_info (side right) (grabbing ?cube) (position "custom"))
	)
)

(defrule cubes_take_cube-left_taken
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?s <-(stack $?stack ?cube)
	(BB_answer "takexyz" take_cube_left 1 ?)

	?a <-(arm_info (side left) (grabbing nil))
	=>
	(retract ?a ?s)
	(assert
		(stack $?stack)
		(arm_info (side left) (grabbing ?cube) (position "custom"))
	)
)

;			CLEAN UP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_take_cube-clean_taking
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(task_status ?t ?)
	(not (cancel_active_tasks))

	?ct <-(cubes_taking ?)
	=>
	(retract ?ct)
)

(defrule cubes_take_cube-clean_freeing_arms
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(task_status ?t ?)
	(not (cancel_active_tasks))

	?f <-(cubes_take_cube freeing_arm ?)
	=>
	(retract ?f)
)
