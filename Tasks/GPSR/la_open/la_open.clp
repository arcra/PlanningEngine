################################
#         DEXEC RULES
################################

(defrule la_open-disabled-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_open) (params ?percent) (step $?pnpdt_steps__) )
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

(defrule la_open-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_open) (params ?percent) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(waiting (symbol la_open))
	)
	(not
		(BB_answer "la_opengrip" la_open ? ?)
	)
	(not
		(arm_info (side left) (enabled FALSE))
	)
	=>
	(send-command "la_opengrip" la_open (str-cat "" ?percent) 15000 )
)

(defrule la_open-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_open) (params ?percent) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "la_opengrip" la_open 1 ?)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule la_open-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type la_open) (params ?percent) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(non-existent-fact)
	?pnpdt_f2__ <-(BB_answer "la_opengrip" la_open 0 ?)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
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

