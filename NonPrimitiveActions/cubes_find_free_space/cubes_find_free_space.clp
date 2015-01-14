(defglobal ?*side_offset* = 1.3)
(defglobal ?*mv_offset* = 1.6)

(defrule cubes_find_free_space-right-start_finding
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params right) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (finding_free_space right ?))
	=>
	(assert
		(finding_free_space right -0.15)
	)

)

(defrule cubes_find_free_space-left-start_finding
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params left) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (finding_free_space left ?))
	=>
	(assert
		(finding_free_space left 0.15)
	)
)

(defrule cubes_find_free_space-free_space_found
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params ?side) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space ?side ?y)
	(or
		(and
			(test (eq ?side left))
			(test (<= ?y 0.5))
			(test (>= ?y (- 0 ?*cube_side*)))
		)
		(and
			(test (eq ?side right))
			(test (>= ?y -0.5))
			(test (<= ?y ?*cube_side*))
		)
	)
	(not
		(and
			(stack ?base1 $?)
			(cube ?base1 ? ?y1 ?)
			(test (< ?y1 (+ ?y (* ?*side_offset* ?*cube_offset*))))
			(test (> ?y1 (- ?y (* ?*side_offset* ?*cube_offset*))))
		)
	)
	; Find the ?x ad ?z of any base cube
	(stack ?base $?)
	(cube ?base ?x ? ?z)
	=>
	(retract ?ffs)
	(assert
		(cubes_free_space ?side (min ?x 18.0) ?y (max ?z 65.0)
		(task_status ?t successful)
	)
)

;		LEFT ARM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_find_free_space-no_free_space-left-search_right
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params left) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space left ?y)
	(stack ?base1 $?)
	(cube ?base1 ? ?y1 ?)
	(test (< ?y1 (+ ?y (* ?*side_offset* ?*cube_offset*))))
	(test (> ?y1 (- ?y (* ?*side_offset* ?*cube_offset*))))

	(not (cubes_searched_first_side left))
	=>
	(retract ?ffs)
	(assert
		(finding_free_space left (- ?y1 (* ?*mv_offset* ?*cube_offset*)))
	)
)

(defrule cubes_find_free_space-no_free_space-left-search_left
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params left) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space left ?y)

	(stack ?base1 $?)
	(cube ?base1 ? ?y1 ?)
	(test (< ?y1 (+ ?y (* ?*side_offset* ?*cube_offset*))))
	(test (> ?y1 (- ?y (* ?*side_offset* ?*cube_offset*))))

	(cubes_searched_first_side left)
	=>
	(retract ?ffs)
	(assert
		(finding_free_space left (+ ?y1 (* ?*mv_offset* ?*cube_offset*)))
	)
)

(defrule cubes_find_free_space-no_free_space-left-clip_right
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params left) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space left ?y)
	(test (< ?y (- 0 ?*cube_side*)))

	(not (cubes_searched_first_side left))
	=>
	(retract ?ffs)
	(assert
		(finding_free_space left (- 0 ?*cube_side*))
	)
)

(defrule cubes_find_free_space-no_free_space-left-start_search_left
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params left) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space left ?y)
	(test (= ?y (- 0 ?*cube_side*)))

	(stack ?base1 $?)
	(cube ?base1 ? ?y1 ?)
	(test (< ?y1 (+ ?y (* ?*side_offset* ?*cube_offset*))))
	(test (> ?y1 (- ?y (* ?*side_offset* ?*cube_offset*))))

	(not (cubes_searched_first_side left))
	=>
	(retract ?ffs)
	(assert
		(cubes_searched_first_side left)
		(finding_free_space left 0.15)
	)
)

(defrule cubes_find_free_space-no_free_space-left-clip_left
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params left) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space left ?y)
	(test (> ?y 0.47))

	(cubes_searched_first_side left)
	=>
	(retract ?ffs)
	(assert
		(finding_free_space left 0.47)
	)
)

(defrule cubes_find_free_space-no_free_space-left-failed
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params left) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space left ?y)
	(test (= ?y 0.47))

	(cubes_searched_first_side left)
	=>
	(retract ?ffs)
	(assert
		(task_status ?t failed)
	)
)

;		RIGHT ARM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_find_free_space-no_free_space-right-search_left
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params right) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space right ?y)
	(stack ?base1 $?)
	(cube ?base1 ? ?y1 ?)
	(test (< ?y1 (+ ?y (* ?*side_offset* ?*cube_offset*))))
	(test (> ?y1 (- ?y (* ?*side_offset* ?*cube_offset*))))

	(not (cubes_searched_first_side right))
	=>
	(retract ?ffs)
	(assert
		(finding_free_space right (+ ?y1 (* ?*mv_offset* ?*cube_offset*)))
	)
)

(defrule cubes_find_free_space-no_free_space-right-search_right
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params right) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space right ?y)

	(stack ?base1 $?)
	(cube ?base1 ? ?y1 ?)
	(test (< ?y1 (+ ?y (* ?*side_offset* ?*cube_offset*))))
	(test (> ?y1 (- ?y (* ?*side_offset* ?*cube_offset*))))

	(cubes_searched_first_side right)
	=>
	(retract ?ffs)
	(assert
		(finding_free_space right (- ?y1 (* ?*mv_offset* ?*cube_offset*)))
	)
)

(defrule cubes_find_free_space-no_free_space-right-clip_left
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params right) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space right ?y)
	(test (> ?y ?*cube_side*))

	(not (cubes_searched_first_side right))
	=>
	(retract ?ffs)
	(assert
		(finding_free_space right ?*cube_side*)
	)
)

(defrule cubes_find_free_space-no_free_space-right-start_search_right
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params right) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space right ?y)
	(test (= ?y ?*cube_side*))

	(not (cubes_searched_first_side right))
	=>
	(retract ?ffs)
	(assert
		(cubes_searched_first_side right)
		(finding_free_space right -0.15)
	)
)

(defrule cubes_find_free_space-no_free_space-right-clip_right
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params right) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space right ?y)
	(test (< ?y -0.47))

	(cubes_searched_first_side right)
	=>
	(retract ?ffs)
	(assert
		(finding_free_space right -0.47)
	)
)

(defrule cubes_find_free_space-no_free_space-right-failed
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params right) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space right ?y)
	(test (= ?y -0.47))

	(cubes_searched_first_side right)
	=>
	(retract ?ffs)
	(assert
		(task_status ?t failed)
	)
)


;			CLEAN UP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule cubes_find_free_space-clean_first_search
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params ?) (step $?steps))
	(active_task ?t)
	(task_status ?t ?)
	(not (cancel_active_tasks))

	?csf <-(cubes_searched_first_side ?)
	=>
	(retract ?csf)
)

(defrule cubes_find_free_space-clean_finding
	(task (id ?t) (plan ?planName) (action_type cubes_find_free_space) (params ?) (step $?steps))
	(active_task ?t)
	(task_status ?t ?)
	(not (cancel_active_tasks))

	?ffs <-(finding_free_space ? ?)
	=>
	(retract ?ffs)
)
