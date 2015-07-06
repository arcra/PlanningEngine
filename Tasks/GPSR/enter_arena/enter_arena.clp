################################
#         DEXEC RULES
################################

(defrule enter_arena-1-wait_door
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type enter_arena) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(enter_arena waiting_door)
	)
	=>
	(assert
		(enter_arena waiting_door)
		(task (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule enter_arena-2-getclose_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type enter_arena) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(enter_arena waiting_door)
	(not
		(enter_arena getting_close)
	)
	=>
	(assert
		(enter_arena getting_close)
		(task (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule enter_arena-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type enter_arena) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(enter_arena getting_close)
	?pnpdt_f2__ <-(enter_arena waiting_door)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule enter_arena-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type enter_arena) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(enter_arena $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

