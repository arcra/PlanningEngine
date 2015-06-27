################################
#         DEXEC RULES
################################

(defrule take_handover-0-known_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (speech_name ?item_name))
	(not
		(take_handover failed)
	)
	(not
		(take_handover object_name ?)
	)
	=>
	(assert
		(take_handover object_name ?item_name)
	)
)

(defrule take_handover-0-unknown_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(take_handover failed)
	)
	(not
		(take_handover object_name ?)
	)
	(not
		(item (name ?object))
	)
	=>
	(assert
		(take_handover object_name ?object)
	)
)

(defrule take_handover-1-1-failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(take_handover failed)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule take_handover-1-fail_speech-no_arm_available
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(take_handover object_name ?item_name)
	(or
		(not
			(arm_info (side left) (grabbing nil))
		)
		(arm_info (side left) (enabled FALSE))
	)
	(or
		(not
			(arm_info (side right) (grabbing nil))
		)
		(arm_info (side right) (enabled FALSE))
	)
	(not
		(take_handover failed)
	)
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(take_handover failed)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "None of my arms are available I cannot take the " ?item_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_handover-2-extend-left
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side left) (grabbing nil))
	(take_handover object_name ?item_name)
	(or
		(not
			(arm_info (side right) (grabbing nil))
		)
		(arm_info (side right) (enabled FALSE))
	)
	(not
		(take_handover arm ?)
	)
	(not
		(take_handover failed)
	)
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(assert
		(take_handover arm left)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "Please put the " ?item_name " in my left gripper so I can take it.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type la_goto) (params "deliver") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_handover-2-extend-right
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side right) (grabbing nil) (enabled TRUE))
	(take_handover object_name ?item_name)
	(not
		(take_handover failed)
	)
	(not
		(take_handover arm ?)
	)
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(assert
		(take_handover arm right)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "Please put the " ?item_name " in my right gripper so I can take it.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type ra_goto) (params "deliver") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_handover-3-open-left
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(take_handover arm left)
	(not
		(take_handover failed)
	)
	(not
		(take_handover retracting)
	)
	(not
		(BB_timer wait_handover)
	)
	(not
		(timer_sent wait_handover)
	)
	(not
		(take_handover closing)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type la_open) (params 80) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 5000 wait_handover)
)

(defrule take_handover-3-open-right
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(take_handover arm right)
	(not
		(take_handover failed)
	)
	(not
		(take_handover retracting)
	)
	(not
		(BB_timer wait_handover)
	)
	(not
		(timer_sent wait_handover)
	)
	(not
		(take_handover closing)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type ra_open) (params 80) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 5000 wait_handover)
)

(defrule take_handover-4-close-left
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(take_handover arm left)
	?pnpdt_f1__ <-(BB_timer wait_handover)
	(not
		(take_handover closing)
	)
	(not
		(take_handover failed)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(take_handover closing)
		(task (plan ?pnpdt_planName__) (action_type la_close) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_handover-4-close-right
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(take_handover arm right)
	?pnpdt_f1__ <-(BB_timer wait_handover)
	(not
		(take_handover closing)
	)
	(not
		(take_handover failed)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(take_handover closing)
		(task (plan ?pnpdt_planName__) (action_type ra_close) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_handover-5-retract-left
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(take_handover arm left)
	?pnpdt_f1__ <-(take_handover closing)
	(not
		(take_handover failed)
	)
	(not
		(take_handover retracting)
	)
	(not
		(arm_info (side left) (position "navigation"))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(take_handover retracting)
		(task (plan ?pnpdt_planName__) (action_type la_goto) (params "navigation") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_handover-5-retract-right
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(take_handover arm right)
	?pnpdt_f1__ <-(take_handover closing)
	(not
		(take_handover failed)
	)
	(not
		(take_handover retracting)
	)
	(not
		(arm_info (side right) (position "navigation"))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(take_handover retracting)
		(task (plan ?pnpdt_planName__) (action_type ra_goto) (params "navigation") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_handover-6-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(take_handover retracting)
	?pnpdt_f2__ <-(arm_info (side ?side) (enabled ?en))
	(take_handover arm ?side)
	(not
		(take_handover failed)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task_status ?pnpdt_task__ successful)
		(arm_info (side ?side) (position "navigation") (enabled ?en) (grabbing ?object))
	)
)

################################
#      FINALIZING RULES
################################

(defrule take_handover-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(take_handover $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

