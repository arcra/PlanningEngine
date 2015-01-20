(defrule cubes_put_cube-success
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube $?))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (arm_info (grabbing ?cube)))
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_put_cube-find_free_space
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free|cubestable)
		(step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (side ?side) (grabbing ?cube))
	(not (cubes_free_space ?side $?))
	(not (cubes_finding_free_space))
	(not (stacking ?))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_find_free_space) (params ?side)
			(step 1 $?steps) (parent ?t))
		(cubes_finding_free_space)
	)
)

(defrule cubes_put_cube-put_free
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free|cubestable) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?fs <-(cubes_free_space ?side ?x ?y ?z)
	?f1 <-(cubes_finding_free_space)
	(arm_info (side ?side) (grabbing ?cube))
	=>
	(retract ?f1)
	(send-command "dropxyz" drop_free (str-cat ?side " " ?x " " ?y " " ?z) 180000)
	(assert
		(dropping ?fs)
	)
)

(defrule cubes_put_cube-put_free-success
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ?) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "dropxyz" drop_free 1 ?)
	?fs <-(cubes_free_space ?side ?x ?y ?z)
	?d <-(dropping ?fs)
	?a <-(arm_info (side ?side) (grabbing ?cube))
	=>
	(retract ?a ?d ?fs)
	(assert
		(arm_info (side ?side) (grabbing nil) (position "custom"))
		(stack ?cube)
		(cube ?cube ?x ?y (+ ?z ?*cube_offset*))
	)
)

(defrule cubes_put_cube-put_free-fail-speech
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free|cubestable)
		(step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "dropxyz" drop_free 0 ?)
	(cubes_free_space $?)
	(dropping ?fs)
	(not (cubes_put_cube speech_fail_drop))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I could not drop the cube " ?cube ". I will try again.")
			(step 1 $?steps) (parent ?t))
		(cubes_put_cube speech_fail_drop)
	)
)

(defrule cubes_put_cube-put_free-fail-get_info
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free|cubestable)
		(step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?fs <-(cubes_free_space $?)
	?d <-(dropping ?fs)
	?f <-(cubes_put_cube speech_fail_drop)
	=>
	(retract ?d ?fs ?f)
	(assert
		(task (plan ?planName) (action_type cubes_get_info) (step 1 $?steps) (parent ?t))
	)
)

; What to do when find_free_space fails
(defrule cubes_put_cube-free_space-error
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (cubes_free_space $?))
	(cubes_finding_free_space)
	(not (cubes_put_cube free_space_failed))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I could not find a free space where to put cube" ?cube ". I will try again.")
			(step 1 $?steps) (parent ?t))
		(cubes_put_cube free_space_failed)
	)
)

(defrule cubes_put_cube-free_space-error-get_info
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?f1 <-(cubes_finding_free_space)
	?f2 <-(cubes_put_cube free_space_failed)
	=>
	(retract ?f1 ?f2)
	(assert
		(task (plan ?planName) (action_type cubes_get_info) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_put_cube-no_free_space-stack-right
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(cubes_finding_free_space)
	(not (cubes_free_space right $?))
	(arm_info (side right) (grabbing ?cube))

	; Find a REACHABLE stack that doesn't have "important cubes" and stack it there.
	(stack $?stack ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	(test (< ?y ?*cube_side*))
	(or
		(and
			(cubes_goal $?goals1 ?cube $?goals2)
			(not
				(and
					(cube ?name $?)
					(or
						(test (member$ ?name $?stack))
						(test (eq ?name ?top_cube))
					)
					(test (member$ ?name $?goals1))
				)
			)
		)
		(and
			(cubes_goal $?goals)
			(not
				(test (member$ ?cube $?goals))
			)
			(not
				(and
					(cube ?name $?)
					(or
						(test (member$ ?name $?stack))
						(test (eq ?name ?top_cube))
					)
					(test (member$ ?name $?goals))
				)
			)
		)
	)
	=>
	(retract ?ffs)
	(send-command "dropxyz" stack_cube (str-cat "right " ?x " " ?y " " (+ ?z (* 1.2 ?*cube_offset*))) 180000)
	(assert
		(stacking ?top_cube)
	)
)

(defrule cubes_put_cube-no_free_space-stack-left
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(cubes_finding_free_space)
	(not (cubes_free_space left $?))
	(arm_info (side left) (grabbing ?cube))

	; Find a REACHABLE stack that doesn't have "important cubes" and stack it there.
	(stack $?stack ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	(test (> ?y (- 0 ?*cube_side*)))
	(or
		(and
			(cubes_goal $?goals1 ?cube $?goals2)
			(not
				(and
					(cube ?name $?)
					(or
						(test (member$ ?name $?stack))
						(test (eq ?name ?top_cube))
					)
					(test (member$ ?name $?goals1))
				)
			)
		)
		(and
			(cubes_goal $?goals)
			(not
				(test (member$ ?cube $?goals))
			)
			(not
				(and
					(cube ?name $?)
					(or
						(test (member$ ?name $?stack))
						(test (eq ?name ?top_cube))
					)
					(test (member$ ?name $?goals))
				)
			)
		)
	)
	=>
	(retract ?ffs)
	(send-command "dropxyz" stack_cube (str-cat "left " ?x " " ?y " " (+ ?z (* 1.2 ?*cube_offset*))) 180000)
	(assert
		(stacking ?top_cube)
	)
)

(defrule cubes_put_cube-stack
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ?top_cube))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (side ?side) (grabbing ?cube))

	(stack $?stack ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	=>
	(send-command "dropxyz" stack_cube (str-cat ?side " " ?x " " ?y " " (+ ?z (* 1.2 ?*cube_offset*))) 180000)
	(assert
		(stacking ?top_cube)
	)
)

(defrule cubes_put_cube-center-no_space
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube center))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (side ?side) (grabbing ?cube))

	(stack $? ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	(and
		(test (< ?y ?*cube_side*))
		(test (> ?y (- 0 ?*cube_side*)))
	)
	=>
	(send-command "dropxyz" stack_cube (str-cat ?side " " ?x " " ?y " " (+ ?z (* 1.2 ?*cube_offset*))) 180000)
	(assert
		(stacking ?top_cube)
	)
)

(defrule cubes_put_cube-center
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube center))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (side ?side) (grabbing ?cube))

	; Get the ?x and ?z of any base cube.
	(stack ?base)
	(cube ?base ?x ? ?z)

	(not
		(and
			(stack ?name $?)
			(cube ?name ? ?y1 ?)
			(and
				(test (< ?y1 ?*cube_side*))
				(test (> ?y1 (- 0 ?*cube_side*)))
			)
		)
	)
	=>
	(send-command "dropxyz" drop_free (str-cat ?side " " ?x " 0 " ?z) 180000)
	(bind ?fs
		(assert
			(cubes_free_space ?side ?x 0 ?z)
		)
	)
	(assert
		(dropping ?fs)
	)
)

(defrule cubes_put_cube-stack-success
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ~cubestable))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "dropxyz" stack_cube 1 ?)
	?a <-(arm_info (side ?side) (grabbing ?cube))
	?st <-(stacking ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	?c <-(cube ?cube $?)
	?s <-(stack $?stack ?top_cube)
	=>
	(retract ?a ?c ?s ?st)
	(assert
		(arm_info (side ?side) (grabbing nil) (position "custom"))
		(stack $?stack ?top_cube ?cube)
		(cube ?cube ?x ?y (+ ?z ?*cube_offset*))
	)
)

(defrule cubes_put_cube-stack-failed
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ~cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "dropxyz" stack_cube 0 ?)
	?st <-(stacking ?top_cube)
	=>
	(retract ?st)
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I could not stack the cube" ?cube " on top of cube " ?top_cube ". I will try again.")
			(step 1 $?steps) (parent ?t))
	)
)
