;			SUCCESSFUL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule cubes_clear_cube-successful
	(task (id ?t) (plan ?planName) (action_type cubes_clear_cube) (params ?cube))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube)
	=>
	(assert
		(task_status ?t successful)
	)
)

;			EXECUTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule cubes_clear_cube-speech
	(task (id ?t) (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube $? ?top_cube)
	(not (cubes_clear_cube speech_sent))
	(not (cubes_clear_cube speaking))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I will clear cube " ?cube) (step 1 $?steps) (parent ?t))
		(cubes_clear_cube speaking)
	)
)

(defrule cubes_clear_cube-speech-finished
	(task (id ?t) (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(children_status ?t ?)
	?f <-(cubes_clear_cube speaking)
	(not (cubes_clear_cube speech_sent))
	=>
	(retract ?f)
	(assert
		(cubes_clear_cube speech_sent)
	)
)

(defrule cubes_clear_cube-take_cube
	(task (id ?t) (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(cubes_clear_cube speech_sent)
	(stack $? ?cube $? ?top_cube)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_take_cube) (params ?top_cube) (step 1 $?steps) (parent ?t))
	)
)

;			FAILED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule cubes_clear_cube-failed-speech
	(task (id ?t) (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(children_status ?t failed)
	(cubes_clear_cube speech_sent)
	(stack $? ?cube $? ?top_cube)
	(not (cubes_clear_cube failed_speaking))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I could not clear the cube " ?cube) (step 1 $?steps) (parent ?t))
		(cubes_clear_cube failed_speaking)
	)
)

(defrule cubes_clear_cube-failed-speech-finish
	(task (id ?t) (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(children_status ?t ?)
	(cubes_clear_cube speech_sent)
	?f <-(cubes_clear_cube failed_speaking)
	=>
	(retract ?f)
	(assert
		(task_status ?t failed)
	)
)

;			CLEAN UP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule cubes_clear_cube-clean_speech
	(task (id ?t) (plan ?planName) (action_type cubes_clear_cube) (params ?cube))
	(active_task ?t)
	(task_status ?t ?)

	?sp <-(cubes_clear_cube speech_sent)
	=>
	(retract ?sp)
)
