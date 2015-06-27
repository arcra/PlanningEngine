################################
#         DEXEC RULES
################################

(defrule la_goto-disabled-new_position
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(arm_info (side left) (position ?pos) (grabbing ?obj) (enabled FALSE))
	(test (neq ?pos ?position))
	(test (neq ?pos "disabled"))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(arm_info (side left) (position "disabled") (grabbing ?obj) (enabled FALSE))
	)
)

(defrule la_goto-new_position
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(arm_info (side left) (position ?pos) (grabbing ?obj))
	(BB_answer "la_goto" la_goto 1 ?)
	(test (neq ?pos ?position))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(arm_info (side left) (position ?position) (grabbing ?obj))
	)
)

(defrule la_goto-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side left) (position ?pos) (enabled TRUE))
	(test (neq ?pos ?position))
	(not
		(waiting (symbol la_goto))
	)
	(not
		(BB_answer "la_goto" la_goto ? ?)
	)
	=>
	(send-command "la_goto" la_goto ?position 35000 )
)

(defrule la_goto-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(or
		(arm_info (side left) (position ?position) (enabled TRUE))
		(arm_info (side left) (position "disabled") (enabled FALSE))
	)
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule la_goto-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side left) (position ?pos) (enabled TRUE))
	(BB_answer "la_goto" la_goto 0 ?)
	(test (neq ?pos ?position))
	=>
	(send-command "la_goto" la_goto ?position 35000 )
)

################################
#      FINALIZING RULES
################################

################################
#      CANCELING RULES
################################

