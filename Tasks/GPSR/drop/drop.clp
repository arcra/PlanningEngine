################################
#         DEXEC RULES
################################

(defrule drop-drop
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type drop) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side ?side) (grabbing ?object))
	(not
		(BB_answer "drop" drop_object 1 =(str-cat "" ?side))
	)
	(not
		(waiting (symbol drop_object) (cmd "drop"))
	)
	(not
		(drop dropping)
	)
	=>
	(assert
		(drop dropping)
	)
	(send-command "drop" drop_object (str-cat "" ?side)  )
)

(defrule drop-drop-failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type drop) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side ?side) (grabbing ?object))
	?pnpdt_f1__ <-(drop dropping)
	(not
		(BB_answer "drop" drop_object 1 =(str-cat "" ?side))
	)
	(not
		(waiting (cmd "drop") (symbol drop_object))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule drop-drop-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type drop) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(robot_info (location ?loc))
	(BB_answer "drop" drop_object 1 ?)
	?pnpdt_f1__ <-(arm_info (side ?side) (grabbing ?object) (position ?position) (enabled ?enabled))
	?pnpdt_f2__ <-(item (name ?object))
	?pnpdt_f3__ <-(drop dropping)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(item (name ?object) (location ?loc))
		(arm_info (side ?side) (grabbing nil) (position "custom") (enabled ?enabled))
	)
)

(defrule drop-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type drop) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule drop-clean_dropping
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type drop) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(drop $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

