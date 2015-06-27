################################
#         DEXEC RULES
################################

(defrule take_object-check_take_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(take_object taking)
	?pnpdt_f2__ <-(take_object speech_sent)
	?pnpdt_f3__ <-(take_object failed_speech_sent)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_take_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_object-find
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?loc))
	(robot_info (location ?loc))
	(test (neq ?loc unknown))
	(not
		(take_object finding)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(take_object speech_sent)
	)
	(not
		(error object_not_found ?object)
	)
	=>
	(assert
		(take_object finding)
		(task (plan ?pnpdt_planName__) (action_type find_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_object-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(take_object speech_sent)
	(item (name ?object) (location ?loc))
	(robot_info (location ?loc))
	(test (neq ?loc unknown))
	(not
		(take_object taking)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(waiting (symbol take_object) (args ?object))
	)
	(not
		(BB_answer "take" take_object ? ?)
	)
	=>
	(assert
		(take_object taking)
	)
	(send-command "take" take_object ?object 180000 )
)

(defrule take_object-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (speech_name ?sp_name) (location ?loc))
	?pnpdt_f1__ <-(take_object finding)
	(robot_info (location ?loc))
	(test (neq ?loc unknown))
	(not
		(take_object speech_sent)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(error object_not_found ?object)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(take_object speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I will take the " ?sp_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_object-succeeded
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(take_object taking)
	?pnpdt_f2__ <-(take_object speech_sent)
	(arm_info (grabbing ?object))
	?pnpdt_f3__ <-(take_object succeeded)
	(not
		(task (action_type monitor_grabbing) (params ?object))
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule take_object-succeeded-left
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(take_object taking)
	?pnpdt_f1__ <-(arm_info (side left))
	(take_object speech_sent)
	(BB_answer "take" take_object 1 ?objs_str)
	(test (eq 1 (member$ ?object (explode$ ?objs_str))))
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(arm_info (side left) (position "navigation") (enabled TRUE) (grabbing ?object))
	)
)

(defrule take_object-succeeded-right
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(take_object taking)
	?pnpdt_f1__ <-(arm_info (side right))
	(take_object speech_sent)
	(BB_answer "take" take_object 1 ?objs_str)
	(test (eq 2 (member$ ?object (explode$ ?objs_str))))
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(arm_info (side right) (position "navigation") (enabled TRUE) (grabbing ?object))
	)
)

(defrule take_object-succeeded-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(take_object taking)
	(arm_info (grabbing ?object))
	(take_object speech_sent)
	(item (name ?object) (speech_name ?sp_name))
	(not
		(take_object succeeded)
	)
	=>
	(assert
		(take_object succeeded)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I have taken the " ?sp_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule take_object-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer "take" take_object 0 ?)
	(take_object taking)
	(take_object speech_sent)
	(item (name ?object) (speech_name ?sp_name))
	(not
		(take_object failed_speech_sent)
	)
	=>
	(assert
		(take_object failed_speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I could not take the " ?sp_name " I will check what's wrong.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

(defrule take_object-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(take_object $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

