(defrule cubes_put_cube-success
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube $?))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (right_arm ?cube))
	(not (left_arm ?cube))
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_put_cube-right-find_free_space
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free|cubestable)
		(step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(right_arm ?cube)
	(not (cubes_free_space right $?))
	(not (cubes_finding_free_space))
	(not (stacking ?))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_find_free_space) (params right)
			(step (- ?step 1) $?steps) (parent ?pt))
		(cubes_finding_free_space)
	)
)

(defrule cubes_put_cube-left-find_free_space
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free|cubestable) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(left_arm ?cube)
	(not (cubes_free_space left $?))
	(not (cubes_finding_free_space))
	(not (stacking ?))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_find_free_space) (params left)
			(step (- ?step 1) $?steps) (parent ?pt))
		(cubes_finding_free_space)
	)
)

(defrule cubes_put_cube-put_free-right
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free|cubestable) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?fs <-(cubes_free_space right ?x ?y ?z)
	(right_arm ?cube)
	=>
	(send-command "dropxyz" drop_free (str-cat "right " ?x " " ?y " " ?z) 180000)
	(assert
		(dropping ?fs)
	)
)

(defrule cubes_put_cube-put_free-left
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free|cubestable) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?fs <-(cubes_free_space left ?x ?y ?z)
	(left_arm ?cube)
	=>
	(send-command "dropxyz" drop_free (str-cat "left " ?x " " ?y " " ?z) 180000)
	(assert
		(dropping ?fs)
	)
)

(defrule cubes_put_cube-put_free-right-success
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ?) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "dropxyz" drop_free 1 ?)
	?fs <-(cubes_free_space right ?x ?y ?z)
	?d <-(dropping ?fs)
	?c <-(cube ?cube $?)
	?a <-(right_arm ?cube)
	=>
	(retract ?a ?c ?d ?fs)
	(assert
		(right_arm nil)
		(stack ?cube)
		(cube ?cube ?x ?y (+ ?z ?*cube_offset*))
	)
)

(defrule cubes_put_cube-put_free-left-success
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ?) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "dropxyz" drop_free 1 ?)
	?fs <-(cubes_free_space left ?x ?y ?z)
	?d <-(dropping ?fs)
	?c <-(cube ?cube $?)
	?a <-(left_arm ?cube)
	=>
	(retract ?a ?c ?d)
	(assert
		(left_arm nil)
		(stack ?cube)
		(cube ?cube ?x ?y (+ ?z ?*cube_offset*))
	)
)

(defrule cubes_put_cube-put_free-fail
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free|cubestable) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "dropxyz" drop_free 0 ?)
	?fs <-(cubes_free_space $?)
	?d <-(dropping ?fs)
	=>
	(retract ?d ?fs)
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I could not drop the cube" ?cube ". I will try again.")
			(step (- ?step 1) $?steps) (parent ?pt))
	)
)

; What to to when find_free_space fails
(defrule cubes_put_cube-free_space-error
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube cubestable) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(cubes_finding_free_space)
	=>
	(retract ?ffs)
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I could not find a free space where to put cube" ?cube ". I will try again.")
			(step (- ?step 1) $?steps) (parent ?pt))
	)
)

(defrule cubes_put_cube-no_free_space-stack-right
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube free))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(cubes_finding_free_space)
	(not (cubes_free_space right $?))
	(right_arm ?cube)

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
	(left_arm ?cube)

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

(defrule cubes_put_cube-stack-right
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ?top_cube))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(right_arm ?cube)

	(stack $?stack ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	=>
	(send-command "dropxyz" stack_cube (str-cat "right " ?x " " ?y " " (+ ?z (* 1.2 ?*cube_offset*))) 180000)
	(assert
		(stacking ?top_cube)
	)
)

(defrule cubes_put_cube-stack-left
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ?top_cube))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(left_arm ?cube)

	(stack $?stack ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	=>
	(send-command "dropxyz" stack_cube (str-cat "left " ?x " " ?y " " (+ ?z (* 1.2 ?*cube_offset*))) 180000)
	(assert
		(stacking ?top_cube)
	)
)

(defrule cubes_put_cube-right-center-no_space
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube center))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(right_arm ?cube)

	(stack $? ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	(and
		(test (< ?y ?*cube_side*))
		(test (> ?y (- 0 ?*cube_side*)))
	)
	=>
	(send-command "dropxyz" stack_cube (str-cat "right " ?x " " ?y " " (+ ?z (* 1.2 ?*cube_offset*))) 180000)
	(assert
		(stacking ?top_cube)
	)
)

(defrule cubes_put_cube-left-center-no_space
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube center))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(left_arm ?cube)

	(stack $? ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	(and
		(test (< ?y ?*cube_side*))
		(test (> ?y (- 0 ?*cube_side*)))
	)
	=>
	(send-command "dropxyz" stack_cube (str-cat "left " ?x " " ?y " " (+ ?z (* 1.2 ?*cube_offset*))) 180000)
	(assert
		(stacking ?top_cube)
	)
)

(defrule cubes_put_cube-right-center
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube center))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(right_arm ?cube)

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
	(send-command "dropxyz" drop_free (str-cat "right " ?x " 0 " ?z) 180000)
	(bind ?fs
		(assert
			(cubes_free_space right ?x 0 ?z)
		)
	)
	(assert
		(dropping ?fs)
	)
)

(defrule cubes_put_cube-left-center
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube center))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(left_arm ?cube)

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
	(send-command "dropxyz" drop_free (str-cat "left " ?x " 0 " ?z) 180000)
	(bind ?fs
		(assert
			(cubes_free_space left ?x 0 ?z)
		)
	)
	(assert
		(dropping ?fs)
	)
)

(defrule cubes_put_cube-stack-right-success
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ~cubestable))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "dropxyz" stack_cube 1 ?)
	?a <-(right_arm ?cube)
	?st <-(stacking ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	?c <-(cube ?cube $?)
	?s <-(stack $?stack ?top_cube)
	=>
	(retract ?a ?c ?s ?st)
	(assert
		(right_arm nil)
		(stack $?stack ?top_cube ?cube)
		(cube ?cube ?x ?y (+ ?z ?*cube_offset*))
	)
)

(defrule cubes_put_cube-stack-left-success
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ~cubestable))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "dropxyz" stack_cube 1 ?)
	?a <-(left_arm ?cube)
	?st <-(stacking ?top_cube)
	(cube ?top_cube ?x ?y ?z)
	?c <-(cube ?cube $?)
	?s <-(stack $?stack ?top_cube)
	=>
	(retract ?a ?c ?s ?st)
	(assert
		(left_arm nil)
		(stack $?stack ?top_cube ?cube)
		(cube ?cube ?x ?y (+ ?z ?*cube_offset*))
	)
)

(defrule cubes_put_cube-stack-failed
	(task (id ?t) (plan ?planName) (action_type cubes_put_cube) (params ?cube ~cubestable) (step ?step $?steps)
		(parent ?pt))
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
			(step (- ?step 1) $?steps) (parent ?pt))
	)
)
