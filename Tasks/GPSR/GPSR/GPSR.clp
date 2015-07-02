################################
#         DEXEC RULES
################################

(defrule GPSR-0-subscribe_to_sv
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type GPSR) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(BB_subscribed_to_var "recognizedSpeech")
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type subscribe_to_shared_var) (params "recognizedSpeech") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule GPSR-1-enter_arena
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type GPSR) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_subscribed_to_var "recognizedSpeech")
	(not
		(robot_info (location gpsr_pos))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type getclose_location) (params gpsr_pos) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule GPSR-2-wait_for_user_instruction
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type GPSR) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(robot_info (location gpsr_pos))
	(BB_subscribed_to_var "recognizedSpeech")
	(not
		(GPSR executed)
	)
	=>
	(assert
		(GPSR executed)
		(task (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule GPSR-3-leave_arena
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type GPSR) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(GPSR executed)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type getclose_location) (params exit) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

(defrule GPSR-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type GPSR) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(GPSR $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

