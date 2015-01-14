(defrule cubes_take_cube-arm_busy
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cube ?cube ? ?y ?)

	(or
		(and
			; Cube is in right arm's reach
			(test (< ?y ?*cube_side*))
			; Right arm is NOT free
			(right_arm ?obj&~nil)
		)
		(and
			; Cube is in left arm's reach
			(test (> ?y (- 0 ?*cube_side*)))
			; Left arm is NOT free
			(left_arm ?obj&~nil)
		)
	)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?obj free)
			(step (- ?step 1) $?steps) (parent ?pt))
	)
)

(defrule cubes_take_cube-send_right
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cube ?cube ?x ?y ?z)

	; Cube is in right arm's reach
	;(test (< ?y ?*cube_side*))
	(test (< ?y 0))
	; Right arm is free
	(right_arm nil)
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
	(left_arm nil)
	(not (waiting (symbol take_cube_left)))
	(not (BB_answer "takexyz" take_cube_left ? ?))
	(not (cubes_taking ?cube))
	=>
	(send-command "takexyz" take_cube_left (str-cat "left " ?x " " ?y " " ?z) 60000 2)
	(assert
		(cubes_taking ?cube)
	)
)

(defrule cubes_take_cube-error
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "takexyz" ? 0 ?)
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I couldn't take the cube " ?cube ". It's probably to far for me to get.")
			(step (- ?step 1) $?steps) (parent ?pt))
	)
)

(defrule cubes_take_cube-right_taken
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?s <-(stack $?stack ?cube)
	(BB_answer "takexyz" take_cube_right 1 ?)

	?a <-(right_arm nil)
	=>
	(retract ?a ?s)
	(assert
		(stack $?stack)
		(right_arm ?cube)
		(task_status ?t successful)
		;(task (plan ?planName) (action_type ra_goto) (params "navigation") (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_take_cube-left_taken
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?s <-(stack $?stack ?cube)
	(BB_answer "takexyz" take_cube_left 1 ?)

	?a <-(left_arm nil)
	=>
	(retract ?a ?s)
	(assert
		(stack $?stack)
		(left_arm ?cube)
		(task_status ?t successful)
		;(task (plan ?planName) (action_type la_goto) (params "navigation") (step 1 $?steps) (parent ?t))
	)
)

;			CLEAN UP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_take_cube-clean_flag
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(task_status ?t ?)
	(not (cancel_active_tasks))

	?ct <-(cubes_taking ?)
	=>
	(retract ?ct)
)
