(defrule la_goto-send_command
	(task (id ?t) (action_type la_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(not (waiting (symbol la_goto)))
	(not (BB_answer "la_goto" la_goto ? ?))
	=>
	(send-command "la_goto" la_goto ?position 10000)
)

(defrule la_goto-failed_or_timedout
	(task (id ?t) (action_type la_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(BB_answer "la_goto" la_goto 0 ?)
	=>
	(send-command "la_goto" la_goto ?position 10000)
)

(defrule la_goto-succeeded
	(task (id ?t) (action_type la_goto))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(BB_answer "la_goto" la_goto 1 ?)
	=>
	(assert
		(task_status ?t successful)
	)
)
