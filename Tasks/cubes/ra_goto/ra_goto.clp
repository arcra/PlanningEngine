(defrule ra_goto-send_command
	(task (id ?t) (action_type ra_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(arm_info (side right) (position ~?position) (enabled TRUE))
	(not (waiting (symbol ra_goto)))
	(not (BB_answer "ra_goto" ra_goto ? ?))
	=>
	(send-command "ra_goto" ra_goto ?position 35000)
)

(defrule ra_goto-failed_or_timedout
	(task (id ?t) (action_type ra_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(arm_info (side right) (position ~?position) (enabled TRUE))
	(BB_answer "ra_goto" ra_goto 0 ?)
	=>
	(send-command "ra_goto" ra_goto ?position 35000)
)

(defrule ra_goto-new_position
	(task (id ?t) (action_type ra_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	?a <-(arm_info (side right) (grabbing ?obj) (position ~?position))
	(BB_answer "ra_goto" ra_goto 1 ?)
	=>
	(retract ?a)
	(assert
		(arm_info (side right) (position ?position) (grabbing ?obj))
	)
)

(defrule ra_goto-disabled-new_position
	(task (id ?t) (action_type ra_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	?a <-(arm_info (side right) (grabbing ?obj) (position ~?position) (enabled FALSE))
	=>
	(retract ?a)
	(assert
		(arm_info (side right) (position ?position) (grabbing ?obj) (enabled TRUE))
	)
)

(defrule ra_goto-succeeded
	(task (id ?t) (action_type ra_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(arm_info (side right) (position ?position))
	=>
	(assert
		(task_status ?t successful)
	)
)
