;			SUCCESSFUL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule cubes_move_cube-successful-cubestable
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube cubestable))
	(active_task ?t)
	(not (task_status ?t ?))

	(stack ?cube $?)
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_move_cube-successful-not_cubestable
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube))
	(active_task ?t)
	(not (task_status ?t ?))

	(stack $? ?top_cube ?cube)
	=>
	(assert
		(task_status ?t successful)
	)
)

;			EXECUTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_move_cube-spoken
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?sp <-(cubes_move_cube speaking_move_cube)
	?cs <-(children_status ?t ?)
	=>
	(retract ?sp ?cs)
	(assert
		(cubes_move_cube speech_sent_move_cube)
	)
)


;		CUBESTABLE
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_move_cube-cubestable-speak
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack ?cube $?))
	(not (cubes_move_cube speaking_move_cube))
	(not (cubes_move_cube speech_sent_move_cube))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I will put cube " ?cube " on the table.")
			(step 1 $?steps) (parent ?t))
		(cubes_move_cube speaking_move_cube)
	)
)

(defrule cubes_move_cube-cubestable-clear_cube
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack ?cube $?))
	(stack $? ?cube $? ?)
	(cubes_move_cube speech_sent_move_cube)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step 1 $?steps) (parent ?t))
		(cubes_move_cube clearing_cube)
	)
)

(defrule cubes_move_cube-cubestable-take_cube
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack ?cube $?))
	(stack $? ?cube)
	(cubes_move_cube speech_sent_move_cube)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_move_cube-cubestable-move_cube-cube_taken
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(or
		(arm_info (side right) (grabbing ?cube))
		(arm_info (side left) (grabbing ?cube))
	)
	(cubes_move_cube speech_sent_move_cube)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?cube cubestable) (step 1 $?steps) (parent ?t))
	)
)

;	   NOT CUBESTABLE
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_move_cube-not_cubestable-speak
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube&~cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack $? ?top_cube ?cube))
	(not (cubes_move_cube speaking_move_cube))
	(not (cubes_move_cube speech_sent_move_cube))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I will move cube " ?cube " on top of cube " ?top_cube)
			(step 1 $?steps) (parent ?t))
		(cubes_move_cube speaking_move_cube)
	)
)

(defrule cubes_move_cube-not_cubestable-clear_cube
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube&~cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack $? ?top_cube ?cube))
	(stack $? ?cube $? ?)
	(cubes_move_cube speech_sent_move_cube)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step 1 $?steps) (parent ?t))
		(cubes_move_cube clearing_cube)
	)
)

(defrule cubes_move_cube-not_cubestable-clear_top_cube
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube&~cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack $? ?top_cube ?cube))
	(stack $? ?top_cube $? ?)
	(cubes_move_cube speech_sent_move_cube)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_clear_cube) (params ?top_cube) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_move_cube-not_cubestable-take_cube
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube&~cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(stack $? ?top_cube)
	(cubes_move_cube speech_sent_move_cube)
	(not (switching_sides))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_take_cube) (params ?cube) (step 1 $?steps) (parent ?t))
	)
)

;		SAME SIDE
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_move_cube-cube_taken-same_side
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(cubes_move_cube speech_sent_move_cube)
	(stack $? ?top_cube)
	(cube ?top_cube ? ?y ?)

	(or
		(and
			(arm_info (side right) (grabbing ?cube))
			(test (< ?y ?*cube_side*))
		)
		(and
			(arm_info (side left) (grabbing ?cube))
			(test (> ?y (- 0 ?*cube_side*)))
		)
	)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?cube ?top_cube) (step 1 $?steps) (parent ?t))
	)
)

;	   DIFFERENT SIDE
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_move_cube-different_side
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(cubes_move_cube speech_sent_move_cube)
	(stack $? ?top_cube)
	(cube ?top_cube ? ?y ?)

	(or
		(arm_info (side right) (grabbing ?cube))
		(arm_info (side left) (grabbing ?cube))
	)

	(not
		(and
			(arm_info (side right) (grabbing ?cube))
			(test (< ?y ?*cube_side*))
		)
	)
	(not
		(and
			(arm_info (side left) (grabbing ?cube))
			(test (> ?y (- 0 ?*cube_side*)))
		)
	)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?cube center) (step 1 $?steps) (parent ?t))
		(switching_sides)
	)
)

(defrule cubes_move_cube-different_side-right
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(switching_sides)
	(children_status ?t successful)
	(cube ?cube ?x1 ?y1 ?z1)
	(cube ?top_cube ? ?y2 ?)
	(test (< ?y2 ?*cube_side*))
	=>
	(assert
		(send-command "takexyz" switch_cube (str-cat "right " ?x1 " " ?y1 " " (+ ?z1 ?*cube_side*)) 50000 2)
	)
)

(defrule cubes_move_cube-different_side-left
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(switching_sides)
	(children_status ?t successful)
	(cube ?cube ?x1 ?y1 ?z1)
	(cube ?top_cube ? ?y2 ?)
	(test (> ?y2 (- 0 ?*cube_side*)))
	=>
	(assert
		(send-command "takexyz" switch_cube (str-cat "left " ?x1 " " ?y1 " " (+ ?z1 ?*cube_side*)) 50000 2)
	)
)

(defrule cubes_move_cube-different_side-success
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ss <-(switching_sides)
	(BB_answer "takexyz" switch_cube 1 ?)
	=>
	(retract ?ss)
	(assert
		(task (plan ?planName) (action_type cubes_put_cube) (params ?cube ?top_cube) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_move_cube-different_side-failure
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?ss <-(switching_sides)
	(BB_answer "takexyz" switch_cube 0 ?)
	=>
	(retract ?ss)
	(assert
		(task (plan ?planName) (action_type spg_say)
			(params "I could not take the cube " ?cube ". I will try again.") (step 1 $?steps) (parent ?t))
	)
)

;			CLEAN UP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_move_cube-finished-clean_switching_sides
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?))
	(active_task ?t)
	(task_status ?t ?)

	?ss <-(switching_sides)
	=>
	(retract ?ss)
)

(defrule cubes_move_cube-finished-clean_speech_notification
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?))
	(active_task ?t)
	(task_status ?t ?)

	?sp <-(cubes_move_cube speech_sent_move_cube)
	=>
	(retract ?sp)
)

(defrule cubes_move_cube-finished-clean_clearing_cube
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?))
	(active_task ?t)
	(task_status ?t ?)

	?cc <-(cubes_move_cube clearing_cube)
	=>
	(retract ?cc)
)

;			FAILED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_move_cube-failed-cube_not_clear
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube $? ?)
	(cubes_move_cube clearing_cube)
	(cubes_move_cube speech_sent_move_cube)
	(children_status ?t failed)
	=>
	(assert
		(task_status ?t failed)
	)
)

(defrule cubes_move_cube-not_cubestable-failed-top_cube_not_clear
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?top_cube&~cubestable) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack $? ?top_cube ?cube))
	(not
		(cubes_move_cube clearing_cube)
	)
	(stack $? ?top_cube $? ?)
	(cubes_move_cube speech_sent_move_cube)
	(children_status ?t ?)
	=>
	(assert
		(task_status ?t failed)
	)
)

(defrule cubes_move_cube-failed-cube_not_taken
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	(cubes_move_cube speech_sent_move_cube)
	(children_status ?t failed)
	=>
	(assert
		(task_status ?t failed)
	)
)

(defrule cubes_move_cube-failed-cube_taken
	(task (id ?t) (plan ?planName) (action_type cubes_move_cube) (params ?cube ?) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (stack $? ?cube $?))
	(cubes_move_cube speech_sent_move_cube)
	(children_status ?t ?)
	=>
	(assert
		(task_status ?t failed)
	)
)
