(defrule cubes_clear_cube-speech_notification
	(task (id ?t) (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(stack $? ?cube $? ?top_cube)
	(not (speech_notification_sent clear_cube))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I will clear cube " ?cube) (step (- ?step 1) $?steps) (parent ?pt))
		(speech_notification_sent clear_cube)
	)
)

(defrule cubes_clear_cube-take_cube
	(task (id ?t) (plan ?planName) (action_type cubes_clear_cube) (params ?cube) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(speech_notification_sent clear_cube)
	(stack $? ?cube $? ?top_cube)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_take_cube) (params ?top_cube) (step (- ?step 1) $?steps) (parent ?pt))
	)
)

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

(defrule cubes_clear_cube-finished
	(task (id ?t) (plan ?planName) (action_type cubes_clear_cube) (params ?cube))
	(active_task ?t)
	(task_status ?t ?)
	(not (cancel_active_tasks))

	?sp <-(speech_notification_sent clear_cube)
	=>
	(retract ?sp)
)
