(defrule spg_say-send_command
	(task (id ?t) (action_type spg_say) (params $?speech))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (waiting (symbol spg_say)))
	(not (BB_answer "spg_say" spg_say 1 ?))
	=>
	(spg_say spg_say $?speech)
)

(defrule spg_say-command_succeeded
	(task (id ?t) (action_type spg_say))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))
	
	(BB_answer "spg_say" spg_say 1 ?)
	=>
	(assert
		(task_status ?t successful)
	)
)

; ADD CHECK_SPG_SAY
