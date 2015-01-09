(defrule ra_goto-send_command
	(task (id ?t) (action_type ra_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(not (waiting (symbol ra_goto)))
	(not (BB_answer "ra_goto" ra_goto ? ?))
	=>
	(send-command "ra_goto" ra_goto ?position 10000)
)

(defrule ra_goto-failed_or_timedout
	(task (id ?t) (action_type ra_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(BB_answer "ra_goto" ra_goto 0 ?)
	=>
	(send-command "ra_goto" ra_goto ?position 10000)
)

(defrule ra_goto-succeeded
	(task (id ?t) (action_type ra_goto))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(BB_answer "ra_goto" ra_goto 1 ?)
	=>
	(assert
		(task_status ?t successful)
	)
)
