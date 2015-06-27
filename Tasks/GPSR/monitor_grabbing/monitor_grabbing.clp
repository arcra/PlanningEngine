################################
#         DEXEC RULES
################################

(defrule monitor_grabbing-recover_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type monitor_grabbing) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer ? =(sym-cat monitor_grabbing_ ?object) 0 ?)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type recover_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule monitor_grabbing-succeeded
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type monitor_grabbing) (params ?object) (step $?pnpdt_steps__) )
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

(defrule monitor_grabbing-timer-start_timer
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type monitor_grabbing) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (grabbing ?object))
	(not
		(waiting (symbol =(sym-cat monitor_grabbing_ ?object)))
	)
	(not
		(BB_answer ? =(sym-cat monitor_grabbing_ ?object) 0 ?)
	)
	(not
		(timer_sent =(sym-cat monitor_grabbing_ ?object) $?)
	)
	(not
		(BB_timer =(sym-cat monitor_grabbing_ ?object))
	)
	=>
	(setTimer 1500 (sym-cat monitor_grabbing_ ?object))
)

(defrule monitor_grabbing-timer-timer_alarm-left
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type monitor_grabbing) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side left) (grabbing ?object))
	?pnpdt_f1__ <-(BB_timer =(sym-cat monitor_grabbing_ ?object))
	=>
	(retract ?pnpdt_f1__)
	(send-command "la_checkobject" (sym-cat monitor_grabbing_ ?object) "" 5000 )
)

(defrule monitor_grabbing-timer-timer_alarm-right
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type monitor_grabbing) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side right) (grabbing ?object))
	?pnpdt_f1__ <-(BB_timer =(sym-cat monitor_grabbing_ ?object))
	=>
	(retract ?pnpdt_f1__)
	(send-command "ra_checkobject" (sym-cat monitor_grabbing_ ?object) "" 3000 )
)

################################
#      FINALIZING RULES
################################

################################
#      CANCELING RULES
################################

