################################
#         DEXEC RULES
################################

(defrule wait_for_confirmation-clear_SV-clear
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_confirmation) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" $?)
	(not
		(wait_for_confirmation sv_cleared)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(wait_for_confirmation sv_cleared)
	)
)

(defrule wait_for_confirmation-clear_SV-cleared
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_confirmation) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(BB_sv_updated "recognizedSpeech" $?)
	)
	(not
		(wait_for_confirmation sv_cleared)
	)
	=>
	(assert
		(wait_for_confirmation sv_cleared)
	)
)

(defrule wait_for_confirmation-received_no
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_confirmation) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_confirmation sv_cleared)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?)
	(or
		(test (eq (lowcase ?speech) "robot no"))
		(test (eq (lowcase ?speech) "robot, no"))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(confirmation_received no)
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule wait_for_confirmation-received_something_else
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_confirmation) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_confirmation sv_cleared)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized)
	(test (neq (lowcase ?speech) "robot yes"))
	(test (neq (lowcase ?speech) "robot no"))
	(test (neq (lowcase ?speech) "robot, yes"))
	(test (neq (lowcase ?speech) "robot, no"))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(BB_sv_updated "recognizedSpeech" (- ?count 1) $?recognized)
	)
)

(defrule wait_for_confirmation-received_yes
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_confirmation) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_confirmation sv_cleared)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?)
	(or
		(test (eq (lowcase ?speech) "robot yes"))
		(test (eq (lowcase ?speech) "robot, yes"))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(confirmation_received yes)
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule wait_for_confirmation-start_timer
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_confirmation) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_confirmation sv_cleared)
	(not
		(timer_sent wait_for_confirmation_timeout)
	)
	(not
		(BB_timer wait_for_confirmation_timeout)
	)
	=>
	(setTimer 8000 wait_for_confirmation_timeout)
)

(defrule wait_for_confirmation-timedout
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_confirmation) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(wait_for_confirmation sv_cleared)
	?pnpdt_f2__ <-(BB_timer wait_for_confirmation_timeout)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

################################
#      FINALIZING RULES
################################

(defrule wait_for_confirmation-clear-flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_confirmation) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(wait_for_confirmation $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

