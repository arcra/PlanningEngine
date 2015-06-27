################################
#         DEXEC RULES
################################

(defrule handover_object-0-known_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (speech_name ?item_name))
	(not
		(handover_object object_name ?)
	)
	=>
	(assert
		(handover_object object_name ?item_name)
	)
)

(defrule handover_object-0-unknown_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(handover_object object_name ?)
	)
	(not
		(item (name ?object))
	)
	=>
	(assert
		(handover_object object_name ?object)
	)
)

(defrule handover_object-1-extend-left
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(handover_object object_name ?)
	(arm_info (side left) (grabbing ?object))
	(not
		(handover_object arm ?)
	)
	=>
	(assert
		(handover_object arm left)
		(task (plan ?pnpdt_planName__) (action_type la_goto) (params "deliver") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule handover_object-1-extend-right
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(handover_object object_name ?)
	(arm_info (side right) (grabbing ?object))
	(not
		(handover_object arm ?)
	)
	=>
	(assert
		(handover_object arm right)
		(task (plan ?pnpdt_planName__) (action_type ra_goto) (params "deliver") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule handover_object-2-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(handover_object arm ?side)
	(handover_object object_name ?item_name)
	(not
		(handover_object speech_sent)
	)
	=>
	(assert
		(handover_object speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "Please take the " ?item_name " from my " ?side " arm.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 8000 wait_handover)
)

(defrule handover_object-3-open-left
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(handover_object arm left)
	(handover_object speech_sent)
	?pnpdt_f1__ <-(BB_timer wait_handover)
	(not
		(handover_object opening)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(handover_object opening)
		(task (plan ?pnpdt_planName__) (action_type la_open) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule handover_object-3-open-right
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(handover_object arm right)
	(take_handover speech_sent)
	?pnpdt_f1__ <-(BB_timer wait_handover)
	(not
		(handover_object opening)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(handover_object opening)
		(task (plan ?pnpdt_planName__) (action_type ra_open) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule handover_object-4-retract-left
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(handover_object arm left)
	(handover_object speech_sent)
	?pnpdt_f1__ <-(handover_object opening)
	(not
		(arm_info (side left) (position "navigation"))
	)
	(not
		(handover_object retracting)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(handover_object retracting)
		(task (plan ?pnpdt_planName__) (action_type la_goto) (params "navigation") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule handover_object-4-retract-right
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(handover_object arm right)
	(handover_object speech_sent)
	?pnpdt_f1__ <-(handover_object opening)
	(not
		(arm_info (side right) (position "navigation"))
	)
	(not
		(handover_object retracting)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(handover_object retracting)
		(task (plan ?pnpdt_planName__) (action_type ra_goto) (params "navigation") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule handover_object-5-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(handover_object retracting)
	?pnpdt_f2__ <-(handover_object arm ?side)
	?pnpdt_f3__ <-(arm_info (side ?side) (enabled ?en))
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(arm_info (side ?side) (enabled ?en) (position "navigation") (grabbing nil))
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule handover_object-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(handover_object $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

