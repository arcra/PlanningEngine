################################
#         DEXEC RULES
################################

(defrule find_object-check_find_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(find_object finding)
	?pnpdt_f2__ <-(find_object speech_sent)
	?pnpdt_f3__ <-(find_object failed_speech_sent)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_find_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object-failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(find_object speech_sent)
	?pnpdt_f2__ <-(find_object failed_speech_sent)
	(not
		(find_object finding)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(error object_not_found ?object)
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule find_object-object_not_found
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(find_object speech_sent)
	?pnpdt_f1__ <-(find_object finding)
	?pnpdt_f2__ <-(BB_answer "fashionfind_object" find_object 1 ?found_list)
	(test (eq FALSE (member$ ?object (explode$ ?found_list))))
	(item (name ?object) (speech_name ?item_name))
	(not
		(find_object failed_speech_sent)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(find_object failed_speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I could not find the " ?item_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(find_object speech_sent)
	(not
		(find_object finding)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(waiting (symbol find_object) (args ?object))
	)
	(not
		(BB_answer "fashionfind_object" find_object ? ?)
	)
	=>
	(assert
		(find_object finding)
	)
	(send-command "fashionfind_object" find_object ?object 180000 )
)

(defrule find_object-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (speech_name ?sp_name) (location ?loc))
	(robot_info (location ?loc))
	(test (neq ?loc unknown))
	(not
		(find_object speech_sent)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(error object_not_found ?object)
	)
	=>
	(assert
		(find_object speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I will look for the " ?sp_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(find_object speech_sent)
	?pnpdt_f1__ <-(find_object finding)
	?pnpdt_f2__ <-(BB_answer "fashionfind_object" find_object 1 ?found_list)
	(test (neq FALSE (member$ ?object (explode$ ?found_list))))
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule find_object-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer "fashionfind_object" find_object 0 ?)
	(find_object finding)
	(find_object speech_sent)
	(item (name ?object) (speech_name ?sp_name))
	(not
		(find_object failed_speech_sent)
	)
	=>
	(assert
		(find_object failed_speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I could not find the " ?sp_name " I will check what's wrong.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

(defrule find_object-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(find_object $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

