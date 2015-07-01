################################
#         DEXEC RULES
################################

(defrule get_close_to_table-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type get_close_to_table) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(BB_answer "alignedge" align_edge 1 ?)
	)
	(not
		(waiting (symbol align_edge))
	)
	=>
	(send-command "alignedge" align_edge "" 15000 )
)

(defrule get_close_to_table-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type get_close_to_table) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "alignedge" align_edge 1 ?)
	=>
	(retract ?pnpdt_f1__)
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

