(defrule cubes_move_cube-successful-cubestable
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube cubestable))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack ?cube $?)
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_move_cube-successful-not_cubestable
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube&~cubestable))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?top_cube ?cube)
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_move_cube-cubestable
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube cubestable) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack ?cube $?))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step (- ?step 4) $?steps) (parent ?pt))
		(task (plan ?planName) (action_type spg_say) (params "I will move cube " ?cube " to the table.") (step (- ?step 3) $?steps) (parent ?pt))
		(task (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step (- ?step 2) $?steps) (parent ?pt))
		(task (plan ?planName) (action_type cubes_put_cube) (params ?cube cubestable) (step (- ?step 1) $?steps) (parent ?pt))
	)
)

(defrule cubes_move_cube-same_side
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?top_cube)
	(stack $? ?cube $?)
	(cube ?cube ?x1 ?y1 ?z1)
	(cube ?top_cube ?x2 ?y2 ?z2)

	(or
		(and
			(test (> ?y1 (- 0 ?*cube_side*)))
			(test (> ?y2 (- 0 ?*cube_side*)))
		)
		(and
			(test (< ?y1 ?*cube_side*))
			(test (< ?y2 ?*cube_side*))
		)
	)
	(not (switching_sides))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step (- ?step 4) $?steps) (parent ?pt))
		(task (plan ?planName) (action_type spg_say) (params "I will move cube " ?cube " on top of cube " ?top_cube) (step (- ?step 3) $?steps) (parent ?pt))
		(task (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step (- ?step 2) $?steps) (parent ?pt))
		(task (plan ?planName) (action_type cubes_put_cube) (params ?cube ?top_cube) (step (- ?step 1) $?steps) (parent ?pt))
	)
)

(defrule cubes_move_cube-different_side
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?top_cube)
	(stack $? ?cube $?)
	(cube ?cube ?x1 ?y1 ?z1)
	(cube ?top_cube ?x2 ?y2 ?z2)

	(not
		(or
			(and
				(test (> ?y1 (- 0 ?*cube_side*)))
				(test (> ?y2 (- 0 ?*cube_side*)))
			)
			(and
				(test (< ?y1 ?*cube_side*))
				(test (< ?y2 ?*cube_side*))
			)
		)
	)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step (- ?step 4) $?steps) (parent ?pt))
		(task (plan ?planName) (action_type spg_say) (params "I will move cube " ?cube " on top of cube " ?top_cube) (step (- ?step 3) $?steps) (parent ?pt))
		(task (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step (- ?step 2) $?steps) (parent ?pt))
		(task (plan ?planName) (action_type cubes_put_cube) (params ?cube center) (step (- ?step 1) $?steps) (parent ?pt))
		(switching_sides)
	)
)

(defrule cubes_move_cube-different_side-right
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(switching_sides)
	(cube ?cube ?x1 ?y1 ?z1)
	(cube ?top_cube ?x2 ?y2 ?z2)
	(test (< ?y2 ?*cube_side*))
	=>
	(assert
		(send-command "takexyz" switch_cube (str-cat "right " ?x1 " " ?y1 " " ?z1) 50000 2)
	)
)

(defrule cubes_move_cube-different_side-left
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(switching_sides)
	(cube ?cube ?x1 ?y1 ?z1)
	(cube ?top_cube ?x2 ?y2 ?z2)
	(test (> ?y2 (- 0 ?*cube_side*)))
	=>
	(assert
		(send-command "takexyz" switch_cube (str-cat "left " ?x1 " " ?y1 " " ?z1) 50000 2)
	)
)

(defrule cubes_move_cube-different_side-success
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ss <-(switching_sides)
	(BB_answer "takexyz" switch_cube 1 ?)
	=>
	(retract ?ss)
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?cube ?top_cube) (step (- ?step 1) $?steps) (parent ?pt))		
	)
)
