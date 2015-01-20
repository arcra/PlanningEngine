(defrule la_goto-send_command
	(task (id ?t) (action_type la_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(arm_info (side left) (position ~?position) (enabled TRUE))
	(not (waiting (symbol la_goto)))
	(not (BB_answer "la_goto" la_goto ? ?))
	=>
	(send-command "la_goto" la_goto ?position 35000)
)

(defrule la_goto-failed_or_timedout
	(task (id ?t) (action_type la_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(arm_info (side left) (position ~?position) (enabled TRUE))
	(BB_answer "la_goto" la_goto 0 ?)
	=>
	(send-command "la_goto" la_goto ?position 35000)
)

(defrule la_goto-new_position
	(task (id ?t) (action_type la_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	?a <-(arm_info (side left) (grabbing ?obj) (position ~?position))
	(BB_answer "la_goto" la_goto 1 ?)
	=>
	(retract ?a)
	(assert
		(arm_info (side left) (position ?position) (grabbing ?obj))
	)
)

(defrule la_goto-disabled-new_position
	(task (id ?t) (action_type la_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	?a <-(arm_info (side left) (grabbing ?obj) (position ~?position) (enabled FALSE))
	=>
	(retract ?a)
	(assert
		(arm_info (side left) (position ?position) (grabbing ?obj) (enabled FALSE))
	)
)

(defrule la_goto-succeeded
	(task (id ?t) (action_type la_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(arm_info (side left) (position ?position))
	=>
	(assert
		(task_status ?t successful)
	)
)


