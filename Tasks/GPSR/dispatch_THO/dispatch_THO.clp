################################
#         DEXEC RULES
################################

(defrule dispatch_THO-decompose
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_THO) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (action_type take_handover) (params ?object))
	(not
		(dispatch_THO decomposed)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(dispatch_THO decomposed)
		(task (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_THO-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_THO) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(dispatch_THO decomposed)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule dispatch_THO-clear-flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_THO) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(dispatch_THO $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

