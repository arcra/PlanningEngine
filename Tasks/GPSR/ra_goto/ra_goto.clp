################################
#         DEXEC RULES
################################

(defrule ra_goto-disabled-new_position
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(arm_info (side right) (position ?pos) (grabbing ?obj) (enabled FALSE))
	(test (neq ?pos ?position))
	(test (neq ?pos "disabled"))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(arm_info (side right) (position "disabled") (grabbing ?obj) (enabled FALSE))
	)
)

(defrule ra_goto-new_position
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(arm_info (side right) (position ?pos) (grabbing ?obj))
	(BB_answer "ra_goto" ra_goto 1 ?)
	(test (neq ?pos ?position))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(arm_info (side right) (position ?position) (grabbing ?obj))
	)
)

(defrule ra_goto-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side right) (position ?pos) (enabled TRUE))
	(test (neq ?pos ?position))
	(not
		(waiting (symbol ra_goto))
	)
	(not
		(BB_answer "ra_goto" ra_goto ? ?)
	)
	=>
	(send-command "ra_goto" ra_goto ?position 35000 )
)

(defrule ra_goto-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(or
		(arm_info (side right) (position ?position) (enabled TRUE))
		(arm_info (side right) (position "disabled") (enabled FALSE))
	)
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule ra_goto-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side right) (position ?pos) (enabled TRUE))
	(BB_answer "ra_goto" ra_goto 0 ?)
	(test (neq ?pos ?position))
	=>
	(send-command "ra_goto" ra_goto ?position 35000 )
)

################################
#      FINALIZING RULES
################################

################################
#      CANCELING RULES
################################

