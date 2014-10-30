(defrule check_location_exists-send_command
	?t <-(task (action_type check_location_exists) (params ?location))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (waiting (symbol check_location_exists)))
	(not (BB_answer "mp_position" check_location_exists 1 ?))
	=>
	(send-command "mp_position" check_location_exists ?location)
)

(defrule check_location_exists-does_NOT_exist
	?t <-(task (plan ?planName) (action_type check_location_exists) (params ?location) (step $?steps) (parent ?pt) )
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_answer "mp_position" check_location_exists 0 ?)
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I found the error, I do not know the location" ?location) (step $?steps) (parent ?pt))
		(task_status ?t successful)
	)
)

(defrule check_location_exists-exists
	?t <-(task (action_type check_location_exists))
	(active_task ?t)
	(not
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(BB_answer "mp_position" check_location_exists 1 ?)
	=>
	(assert
		(task_status ?t failed)
	)
)

(defrule check_location_exists-finished
	?t <-(task (action_type check_location_exists))
	(active_task ?t)
	(task_status ?t ?)
	=>
	(assert
		(checked_location_exists)
	)
)
