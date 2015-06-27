################################
#         DEXEC RULES
################################

(defrule la_close-disabled-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_close) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side left) (enabled FALSE))
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule la_close-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_close) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(waiting (symbol la_close))
	)
	(not
		(BB_answer "la_closegrip" la_close ? ?)
	)
	(not
		(arm_info (side left) (enabled FALSE))
	)
	=>
	(send-command "la_closegrip" la_close "50" 15000 )
)

(defrule la_close-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_close) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "la_closegrip" la_close 1 ?)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule la_close-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_close) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "la_closegrip" la_close 0 ?)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_arm) (params left) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

################################
#      CANCELING RULES
################################

