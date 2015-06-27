################################
#         DEXEC RULES
################################

(defrule ra_open-disabled-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_open) (params ?percent) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side right) (enabled FALSE))
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule ra_open-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_open) (params ?percent) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(waiting (symbol ra_open))
	)
	(not
		(BB_answer "ra_opengrip" ra_open ? ?)
	)
	(not
		(arm_info (side right) (enabled FALSE))
	)
	=>
	(send-command "ra_opengrip" ra_open (str-cat "" ?percent) 15000 )
)

(defrule ra_open-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_open) (params ?percent) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "ra_opengrip" ra_open 1 ?)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule ra_open-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_open) (params ?percent) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "ra_opengrip" ra_open 0 ?)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_arm) (params right) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

################################
#      CANCELING RULES
################################

