(defrule cubes_get_info-delete_cubes
	(task (id ?t) (plan ?planName) (action_type cubes_get_info) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (getting_cubes_info))
	(or
		(stack $?)
		(cube $?)
	)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_delete_info) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_get_info-arms_goto-navigation
	(task (id ?t) (plan ?planName) (action_type cubes_get_info) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (cubes_info $?))
	(not (cube $?))
	(arm_info (position ~"navigation"))
	=>
	(assert
		(task (plan ?planName) (action_type arms_goto) (params "navigation") (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_get_info-detect_cubes
	(task (id ?t) (plan ?planName) (action_type cubes_get_info))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (side right) (position "navigation"))
	(arm_info (side left) (position "navigation"))
	(not (cubes_info $?))
	(not (cube $?))
	(not (cubes_get_info getting_info))
	=>
	(send-command "detectcubes" detect_cubes "all" 20000)
	(assert
		(cubes_get_info getting_info)
	)
)

(defrule cubes_get_info-detect_cubes-failed
	(task (id ?t) (plan ?planName) (action_type cubes_get_info) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(BB_answer "detectcubes" detect_cubes 0 ?)
	?f <-(cubes_get_info getting_info)
	=>
	(retract ?f)
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I could not find any cubes, I will try again.") (step 1 $?steps) (parent ?t))
	)
)

; ADD CHECK_DETECT_CUBES (in the previous rule)


(defrule cubes_get_info-cubes_get_info
	(task (id ?t) (plan ?planName) (action_type cubes_get_info))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (cubes_info $?))
	(not (cube $?))
	(BB_answer "detectcubes" detect_cubes 1 ?cubes_info)
	?f <-(cubes_get_info getting_info)
	=>
	(retract ?f)
	(assert
		(getting_cubes_info)
		(cubes_info (explode$ ?cubes_info))
	)
)

(defrule cubes_get_info-create_cube
	(task (id ?t) (plan ?planName) (action_type cubes_get_info))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ci <-(cubes_info ?name ?x ?y ?z $?cubes_info)
	=>
	(retract ?ci)
	(bind ?offset (/ (* ?y 0.08) 0.45))
	(if (< ?y 0) then
		(bind ?offset (/ (* ?y -0.08) -0.45))
	)
	(assert
		(cube (sym-cat ?name _cube) (+ ?x 0.03) (+ ?y ?offset) (- ?z 0.06))
;		(cube (sym-cat ?name _cube) ?x ?y (- ?z 0.06))
;		(cube (sym-cat ?name _cube) ?x ?y ?z)
		(cubes_info $?cubes_info)
	)
)

(defrule cubes_get_info-delete_cubes_info
	(task (id ?t) (plan ?planName) (action_type cubes_get_info))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ci <-(cubes_info )
	=>
	(retract ?ci)
)

(defrule cubes_get_info-start_building_stacks
	(task (id ?t) (plan ?planName) (action_type cubes_get_info))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (cubes_info $?))
	(cube ?name ?x ?y ?z)
	; This cube is not in any existing stack.
	(not (stack $? ?name $?))
	; There's no other cube in this area (on the top view of the table) that is below this one -> this is the base of the stack
	(not (and
			(cube ~?name ?x2 ?y2 ?z2)
			(test (>= (+ ?x2 ?*cube_side*) ?x))
			(test (<= (- ?x2 ?*cube_side*) ?x))

			(test (>= (+ ?y2 ?*cube_side*) ?y))
			(test (<= (- ?y2 ?*cube_side*) ?y))

			(test (< ?z2 ?z))
		)
	)
	=>
	(assert
		(stack ?name)
	)
)

(defrule cubes_get_info-keep_building_stacks
	(task (id ?t) (plan ?planName) (action_type cubes_get_info))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (cubes_info $?))
	(cube ?name ?x ?y ?z)
	; There's a stack this cube belongs to:
	;	top_cube is near and below this one.
	?s <-(stack $?stack_cubes ?top_cube)
	
	(cube ?top_cube ?x2 ?y2 ?z2)
	(test (>= (+ ?x2 ?*cube_side*) ?x))
	(test (<= (- ?x2 ?*cube_side*) ?x))

	(test (>= (+ ?y2 ?*cube_side*) ?y))
	(test (<= (- ?y2 ?*cube_side*) ?y))

	(test (< ?z2 ?z))

	; There's no other cube that belongs to this stack and is over top_cube and under name
	(not (and
			(cube ?name2 ?x3 ?y3 ?z3)
			(test (>= (+ ?x2 ?*cube_side*) ?x3))
			(test (<= (- ?x2 ?*cube_side*) ?x3))

			(test (>= (+ ?y2 ?*cube_side*) ?y3))
			(test (<= (- ?y2 ?*cube_side*) ?y3))

			(test (< ?z2 ?z3))

			(test (< ?z3 ?z))
		)
	)
	=>
	(retract ?s)
	(assert
		(stack $?stack_cubes ?top_cube ?name)
	)
)

(defrule cubes_get_info-stop_building_stacks
	(task (id ?t) (plan ?planName) (action_type cubes_get_info))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (cubes_info $?))

	; There are no more cubes without a stack
	(not
		(and
			(cube ?name ?x ?y ?z)
			(not
				(and
					(stack $?stack_cubes)
					(test (member$ ?name $?stack_cubes))
				)
			)
		)
	)
	?gci <-(getting_cubes_info)
	=>
	(retract ?gci)
	(assert
		(task_status ?t successful)
	)
)

