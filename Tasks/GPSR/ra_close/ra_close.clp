################################
#         DEXEC RULES
################################

(defrule ra_close-disabled-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_close) (params "") (step $?pnpdt_steps__) )
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

(defrule ra_close-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_close) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(waiting (symbol ra_close))
	)
	(not
		(B_answer "ra_closegrip" ra_close ? ?)
	)
	(not
		(arm_info (side right) (enabled FALSE))
	)
	=>
	(send-command "ra_closegrip" ra_close "50" 15000 )
)

(defrule ra_close-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_close) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "ra_closegrip" ra_close 1 ?)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule ra_close-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ra_close) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(non-existent-fact)
	?pnpdt_f2__ <-(BB_answer "ra_closegrip" ra_close 0 ?)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
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

