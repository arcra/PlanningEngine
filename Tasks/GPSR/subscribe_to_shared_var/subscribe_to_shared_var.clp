################################
#         DEXEC RULES
################################

(defrule subscribe_to_shared_var-subscribe
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type subscribe_to_shared_var) (params ?name $?subscription_types) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(BB_subscribed_to_var ?name)
	)
	(not
		(BB_timer =(sym-cat stsv_ ?name))
	)
	(not
		(timer_sent =(sym-cat stsv_ ?name))
	)
	=>
	(if (neq (subscribe_to-shared_var ?name $?subscription_types) 1) then (setTimer 3000 (sym-cat stsv_ ?name)))
)

(defrule subscribe_to_shared_var-successful
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type subscribe_to_shared_var) (params ?name $?subscription_types) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_subscribed_to_var ?name)
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

