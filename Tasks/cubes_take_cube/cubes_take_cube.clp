;				SUCCESSFUL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_take_cube-successful-verify
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (grabbing ?cube))
	(not (cubes_take_cube verifying))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_get_info) (step 1 $?steps) (parent ?t))
		(cubes_take_cube verifying)
	)
)

(defrule cubes_take_cube-successful
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (grabbing ?cube))
	?f <-(cubes_take_cube verifying)
	=>
	(retract ?f)
	(assert
		(task_status ?t successful)
	)
)

;				VERIFY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_take_cube-not_successful
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	?ts <-(task_status ?t successful)
	(not (cancel_active_tasks))

	?a <-(arm_info (side ?side) (grabbing ?cube))
	(cube ?cube $?)
	=>
	(retract ?ts ?a)
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I could not take the " ?cube ". I will try again.")
			(step 1 $?steps) (parent ?t))
		(arm_info (side ?side) (grabbing nil) (position "custom"))
	)
)

;				EXECUTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_take_cube-right_arm-disabled
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cube ?cube ? ?y ?)

	; Cube is not in left arm's reach
	(test (< ?y (- 0 ?*cube_side*)))
	;(test (< ?y 0))

	; Right arm is disabled.
	(arm_info (side right) (enabled FALSE))
	
	(not (cubes_take_cube speech_disabled))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "My right arm is not enabled. I cannot take the cube " ?cube)
			(step 1 $?steps) (parent ?t))
		(cubes_take_cube speech_disabled)
	)
)

(defrule cubes_take_cube-right_arm-disabled-fail
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cube ?cube ? ?y ?)

	; Cube is not in left arm's reach
	(test (< ?y (- 0 ?*cube_side*)))
	;(test (< ?y 0))

	; Right arm is disabled.
	(arm_info (side right) (enabled FALSE))
	
	?f <-(cubes_take_cube speech_disabled)
	=>
	(retract ?f)
	(assert
		(task_status ?t failed)
	)
)

(defrule cubes_take_cube-left_arm-disabled
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cube ?cube ? ?y ?)

	; Cube is not in right arm's reach
	(test (> ?y ?*cube_side*))
	;(test (> ?y 0))

	; Left arm is disabled.
	(arm_info (side left) (enabled FALSE))
	
	(not (cubes_take_cube speech_disabled))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "My left arm is not enabled. I cannot take the cube " ?cube)
			(step 1 $?steps) (parent ?t))
		(cubes_take_cube speech_disabled)
	)
)

(defrule cubes_take_cube-left_arm-disabled-fail
	(task (id ?t) (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cube ?cube ? ?y ?)

	; Cube is not in right arm's reach
	(test (> ?y ?*cube_side*))
	;(test (> ?y 0))

	; Left arm is disabled.
	(arm_info (side left) (enabled FALSE))
	
	?f <-(cubes_take_cube speech_disabled)
	=>
	(retract ?f)
	(assert
		(task_status ?t failed)
	)
)

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
	(test (< ?y ?*cube_side*))
	;(test (< ?y 0))
	(or
		; Cube is the base cube, so it doesn't matter with which arm it takes the cube.
		(cubes_goal ?cube $?)
		; It is a straight take order, not as part of another task's decomposition.
		(not (cubes_goal $?))
		; Cube is NOT in left arm's reach or left arm is disabled.
		(not
			(and
				(test (> ?y (- 0 ?*cube_side*)))
				;(test (> ?y 0))
				(arm_info (side left) (enabled TRUE))
			)
		)
		; Cube is next cube to place and the stack is on the right side
		; (and therefore should take it with the right hand)
		(and
			(cubes_goal ?base $?stack1 ?cube $?)
			(stack ?base $?stack1)
			(cube ?base ? ?y1 ?)
			(test (< ?y1 ?*cube_side*))
			;(test (< ?y1 0))
		)
		; The next cube to place is on the left side
		; (i. e. use this one to clear the stack)
		(and
			(cubes_goal $?stack1 ?next_cube $?)
			(stack $?stack1 $?)
			(cube ?next_cube ? ?y1 ?)
			(test (> ?y1 (- 0 ?*cube_side*)))
		)
		; The other arm is holding the next cube to place
		; (i. e. use this one to clear the stack)
		(and
			(arm_info (side left) (grabbing ?next_cube))
			(cubes_goal $?stack1 ?next_cube $?)
			(stack $?stack1)
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
	(test (> ?y (- 0 ?*cube_side*)))
	;(test (> ?y 0))
	(or
		; Cube is the base cube, so it doesn't matter with which arm it takes the cube.
		(cubes_goal ?cube $?)
		; It is a straight take order, not as part of another task's decomposition.
		(not (cubes_goal $?))
		; Cube is NOT in right arm's reach or right arm is also busy or disabled.
		(not
			(and
				(test (< ?y ?*cube_side*))
				;(test (< ?y 0))
				(arm_info (side right) (enabled TRUE))
			)
		)
		; Cube is next cube to place and the stack is on the left side
		; (and therefore should take it with the left hand)
		(and
			(cubes_goal ?base $?stack1 ?cube $?)
			(stack ?base $?stack1)
			(cube ?base ? ?y1 ?)
			(test (> ?y1 (- 0 ?*cube_side*)))
			;(test (> ?y1 0))
		)
		; The next cube to place is on the right side
		; (i. e. use this one to clear the stack)
		(and
			(cubes_goal $?stack1 ?next_cube $?)
			(stack $?stack1 $?)
			(cube ?next_cube ? ?y1 ?)
			(test (< ?y1 ?*cube_side*))
		)
		; The other arm is holding the next cube to place
		; (i. e. use this one to clear the stack)
		(and
			(arm_info (side right) (grabbing ?next_cube))
			(cubes_goal $?stack1 ?next_cube $?)
			(stack $?stack1)
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
			(params "I don't know where the cube " ?cube " is. I will search for it.") (step 1 $?steps) (parent ?t))
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
	(test (< ?y ?*cube_side*))
	;(test (< ?y 0))
	; Right arm is free
	(arm_info (side right) (grabbing nil) (enabled TRUE))

	(or
		; Cube is the base cube, so it doesn't matter with which arm it takes the cube.
		(cubes_goal ?cube $?)
		; It is a straight take order, not as part of another task's decomposition.
		(not (cubes_goal $?))
		; Cube is NOT in left arm's reach or left arm is also busy or disabled.
		(not
			(and
				(test (> ?y (- 0 ?*cube_side*)))
				;(test (> ?y 0))
				(arm_info (side left) (grabbing nil) (enabled TRUE))
			)
		)
		; Cube is next cube to place and the stack is on the right side
		; (and therefore should take it with the right hand)
		(and
			(cubes_goal ?base $?stack1 ?cube $?)
			(stack ?base $?stack1)
			(cube ?base ? ?y1 ?)
			(test (< ?y1 ?*cube_side*))
			;(test (< ?y1 0))
		)
		; The next cube to place is on the left side
		; (i. e. use this one to clear the stack)
		(and
			(cubes_goal $?stack1 ?next_cube $?)
			(stack $?stack1 $?)
			(cube ?next_cube ? ?y1 ?)
			(test (> ?y1 (- 0 ?*cube_side*)))
		)
		; The other arm is holding the next cube to place
		; (i. e. use this one to clear the stack)
		(and
			(cubes_goal $?stack1 ?next_cube $?)
			(stack $?stack1)
			(arm_info (side left) (grabbing ?next_cube))
		)
	)


	(not (waiting (symbol take_cube_right)))
	(not (BB_answer "takexyz" take_cube_right ? ?))
	(not (cubes_taking ?cube))
	=>
	(send-command "takexyz" take_cube_right (str-cat "right " ?x " " ?y " " (+ ?z ?*cube_side*)) 60000 2)
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
	(test (> ?y (- 0 ?*cube_side*)))
	;(test (> ?y 0))
	; Left arm is free
	(arm_info (side left) (grabbing nil) (enabled TRUE))

	(or
		; Cube is the base cube, so it doesn't matter with which arm it takes the cube.
		(cubes_goal ?cube $?)
		; It is a straight take order, not as part of another task's decomposition.
		(not (cubes_goal $?))
		; Cube is NOT in right arm's reach or right arm is also busy or disabled.
		(not
			(and
				(test (< ?y ?*cube_side*))
				;(test (< ?y 0))
				(arm_info (side right) (grabbing nil) (enabled TRUE))
			)
		)
		; Cube is next cube to place and the stack is on the left side
		; (and therefore should take it with the left hand)
		(and
			(cubes_goal ?base $?stack1 ?cube $?)
			(stack ?base $?stack1)
			(cube ?base ? ?y1 ?)
			(test (> ?y1 (- 0 ?*cube_side*)))
			;(test (> ?y1 0))
		)
		; The next cube to place is on the right side
		; (i. e. use this one to clear the stack)
		(and
			(cubes_goal $?stack1 ?next_cube $?)
			(stack $?stack1  $?)
			(cube ?next_cube ? ?y1 ?)
			(test (< ?y1 ?*cube_side*))
		)
		; The other arm is holding the next cube to place
		; (i. e. use this one to clear the stack)
		(and
			(arm_info (side right) (grabbing ?next_cube))
			(cubes_goal $?stack1 ?next_cube $?)
			(stack $?stack1)
		)
	)

	(not (waiting (symbol take_cube_left)))
	(not (BB_answer "takexyz" take_cube_left ? ?))
	(not (cubes_taking ?cube))
	=>
	(send-command "takexyz" take_cube_left (str-cat "left " ?x " " ?y " " (+ ?z ?*cube_side*)) 60000 2)
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
