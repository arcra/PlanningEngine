################################
#         DEXEC RULES
################################

(defrule spg_say-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type spg_say) (params $?speech) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(waiting (symbol spg_say))
	)
	(not
		(BB_answer "spg_say" spg_say 1 ?)
	)
	=>
	(spg_say spg_say $?speech)
)

(defrule spg_say-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type spg_say) (params $?speech) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer "spg_say" spg_say 1 ?)
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

################################
#      CANCELING RULES
################################

