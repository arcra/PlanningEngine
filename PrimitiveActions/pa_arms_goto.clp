(defrule arms_goto-send_command
	(task (id ?t) (action_type arms_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(not (waiting (symbol arms_goto)))
	(not (BB_answer "arms_goto" arms_goto ? ?))
	=>
	(send-command "arms_goto" arms_goto ?position 10000)
)

(defrule arms_goto-failed_or_timedout
	(task (id ?t) (action_type arms_goto) (params ?position))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(BB_answer "arms_goto" arms_goto 0 ?)
	=>
	(send-command "arms_goto" arms_goto ?position 10000)
)

(defrule arms_goto-succeeded
	(task (id ?t) (action_type arms_goto))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(BB_answer "arms_goto" arms_goto 1 ?)
	=>
	(assert
		(task_status ?t successful)
	)
)

