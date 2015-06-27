################################
#         DEXEC RULES
################################

(defrule check_location_exists-location_does_not_exist
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_location_exists) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer "mp_position" =(sym-cat check_location_exists_ ?location) 0 ?)
	=>
	(assert
		(task_status ?pnpdt_task__ failed)
		(error location_does_not_exist ?location)
	)
)

(defrule check_location_exists-location_exists
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_location_exists) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer "mp_position" =(sym-cat check_location_exists_ ?location) 1 ?)
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule check_location_exists-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_location_exists) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(waiting (cmd "mp_position") (symbol =(sym-cat check_location_exists_ ?location)))
	)
	(not
		(BB_answer "mp_position" =(sym-cat check_location_exists_ ?location) 1 ?)
	)
	=>
	(send-command "mp_position" (sym-cat check_location_exists_ ?location) ?location  )
)

################################
#      FINALIZING RULES
################################

(defrule check_location_exists-create_flag
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type check_location_exists) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	=>
	(assert
		(checked location_exists ?location)
	)
)

################################
#      CANCELING RULES
################################

