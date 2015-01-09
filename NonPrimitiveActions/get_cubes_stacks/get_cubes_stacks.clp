(defglobal ?*side* = 8.0)

(defrule get_cubes_stacks-detect_cubes
	(task (id ?t) (action_type get_cubes_stacks))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))

	(not (cubes_info $?))
	(not (cube $?))
	(not (waiting (symbol detect_cubes)))
	(not (BB_answer "detectcubes" detect_cubes ? ?))
	=>
	(send-command "detectcubes" detect_cubes "all" 5000)
)

(defrule get_cubes_stacks-get_cubes_info
	(task (id ?t) (action_type get_cubes_stacks))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))

	(not (cubes_info $?))
	(not (cube $?))
	(BB_answer "detectcubes" detect_cubes 1 ?cubes_info)
	=>
	(assert
		(cubes_info (explode ?cubes_info))
	)
)

(defrule get_cubes_stacks-create_cube
	(task (id ?t) (action_type get_cubes_stacks))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))

	?ci <-(cubes_info ?name ?x ?y ?z $?cubes_info)
	=>
	(retract ?ci)
	(assert
		(cube ?name ?x ?y ?z)
		(cubes_info $?cubes_info)
	)
)

(defrule get_cubes_stacks-delete_cubes_info
	(task (id ?t) (action_type get_cubes_stacks))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	?ci <-(cubes_info )
	=>
	(retract ?ci)
)

(defrule get_cubes_stacks-start_building_stacks
	(task (id ?t) (action_type get_cubes_stacks))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))

	(not (cubes_info $?))
	(cube ?name ?x ?y ?z)
	; This cube is not in any existing stack.
	(not (stack $? ?name $?))
	; There's no other cube in this area (on the top view of the table) that is below this one -> this is the base of the stack
	(not (and
			(cube ~?name ?x2 ?y2 ?z2)
			(test (>= (+ ?x2 ?*side*) ?x))
			(test (<= (- ?x2 ?*side*) ?x))

			(test (>= (+ ?y2 ?*side*) ?y))
			(test (<= (- ?y2 ?*side*) ?y))

			(test (<= (+ ?z2 ?*side*) ?z))
		)
	)
	=>
	(assert
		(stack ?name)
	)
)

(defrule get_cubes_stacks-keep_building_stacks
	(task (id ?t) (action_type get_cubes_stacks))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))

	(not (cubes_info $?))
	(cube ?name ?x ?y ?z)
	; There's a stack this cube belongs to:
	;	top_cube is near and below this one.
	?s <-(stack $?stack_cubes ?top_cube)
	
	(cube ?top_cube ?x2 ?y2 ?z2)
	(test (>= (+ ?x2 ?*side*) ?x))
	(test (<= (- ?x2 ?*side*) ?x))

	(test (>= (+ ?y2 ?*side*) ?y))
	(test (<= (- ?y2 ?*side*) ?y))

	(test (<= (+ ?z2 ?*side*) ?z))

	; There's no other cube that belongs to this stack and is over top_cube and under name
	(not (and
			(cube ?name2&~?name&~?top_cube ?x3 ?y3 ?z3)
			(test (>= (+ ?x2 ?*side*) ?x3))
			(test (<= (- ?x2 ?*side*) ?x3))

			(test (>= (+ ?y2 ?*side*) ?y3))
			(test (<= (- ?y2 ?*side*) ?y3))

			(test (<= (+ ?z2 ?*side*) ?z3))

			(test (<= (+ ?z3 ?*side*) ?z))
		)
	)
	=>
	(retract ?s)
	(assert
		(stack $?stack_cubes ?top_cube ?name)
	)
)

(defrule get_cubes_stacks-stop_building_stacks
	(task (id ?t) (action_type get_cubes_stacks))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
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
	; There's still cube facts
	?c <-(cube $?)
	=>
	(retract ?c)
)

(defrule get_cubes_stacks-finish_building_stacks
	(task (id ?t) (action_type get_cubes_stacks))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
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
	; There are no more cube facts
	(not (cube $?) )
	=>
	(assert
		(task_status ?t successful)
	)
)

