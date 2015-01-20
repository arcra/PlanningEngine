;				ENDING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule arms_goto-success
	(task (plan ?planName) (id ?t) (action_type arms_goto) (params ?position) (step $?steps) )
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (arm_info (position ~?position)))
	=>
	(assert
		(task_status ?t successful)
	)
)

;				EXECUTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule arms_goto-decompose
	(task (plan ?planName) (id ?t) (action_type arms_goto) (params ?position) (step $?steps) )
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(arm_info (position ~?position))
	=>
	(assert
		(task (plan ?planName) (action_type la_goto) (params ?position) (step 1 $?steps) (parent ?t))
		(task (plan ?planName) (action_type ra_goto) (params ?position) (step 1 $?steps) (parent ?t))
	)
)

; ; ADD CHECK_ARMS_GOTO
