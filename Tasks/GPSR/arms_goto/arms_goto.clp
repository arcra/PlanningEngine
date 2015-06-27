################################
#         DEXEC RULES
################################

(defrule arms_goto-decompose
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type arms_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (position ?pos))
	(test (neq ?pos disabled))
	(test (neq ?pos ?position))
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type ra_goto) (params ?position) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type la_goto) (params ?position) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule arms_goto-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type arms_goto) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(and
			(arm_info (position ?pos))
			(or
				(test (neq ?pos ?position))
				(test (neq ?pos disabled))
			)
		)
	)
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

