(defrule subscribte_to_shared_var-successful
	(task (id ?t) (action_type subscribe_to_shared_var) (params ?name $?) )
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(BB_subscribed_to_var ?name)
	=>
	(assert
		(task_status ?t successful)
	)
)

(defrule subscribte_to_shared_var
	(task (action_type subscribe_to_shared_var) (params ?name $?subscription_types) )
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))
	
	(not (BB_subscribed_to_var ?name))
	(not (timer_sent =(sym-cat stsv_ ?name)))
	(not (BB_timer =(sym-cat stsv_ ?name)))
	=>
	(if (neq (subscribe_to-shared_var ?name $?subscription_types) 1) then
		(setTimer 3000 (sym-cat stsv_ ?name))
	)
)
