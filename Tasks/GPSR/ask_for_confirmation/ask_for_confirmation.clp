################################
#         DEXEC RULES
################################

(defrule ask_for_confirmation-confirmation_received
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_for_confirmation) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(confirmation_received ?)
	?pnpdt_f1__ <-(ask_for_confirmation waiting_for_confirmation)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule ask_for_confirmation-confirmation_timed_out
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_for_confirmation) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(ask_for_confirmation waiting_for_confirmation)
	(not
		(confirmation_received ?)
	)
	=>
	(retract ?pnpdt_f1__)
)

(defrule ask_for_confirmation-send_speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_for_confirmation) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(ask_for_confirmation speaking)
	)
	(not
		(ask_for_confirmation waiting_for_confirmation)
	)
	=>
	(assert
		(ask_for_confirmation speaking)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params ?question) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule ask_for_confirmation-wait_for_confirmation
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_for_confirmation) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(ask_for_confirmation speaking)
	(not
		(ask_for_confirmation waiting_for_confirmation)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(ask_for_confirmation waiting_for_confirmation)
		(task (plan ?pnpdt_planName__) (action_type wait_for_confirmation) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

################################
#      CANCELING RULES
################################

