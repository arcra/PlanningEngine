################################
#         DEXEC RULES
################################

(defrule dispatch_DIP-ask_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_DIP) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech) (action_type deliver_in_position) (params ?object ?position))
	(position (name ?position))
	(not
		(item (name ?object))
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(dispatch_DIP decomposed)
	)
	(not
		(object_confirmed ?)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type ask_location) (params (str-cat "Which " ?object " would you like me to deliver?" op2)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_DIP-ask_object_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_DIP) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (action_type deliver_in_position) (params ?object ?position))
	(position (name ?position))
	(item (name ?object) (location unknown) (speech_name ?item_name))
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(dispatch_DIP decomposed)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type ask_location) (params (str-cat "Where is the " ?item_name "?")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_DIP-decompose
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_DIP) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (action_type deliver_in_position) (params ?object ?position))
	(position (name ?position))
	(or
		(and
			(item (name ?object) (location ?loc))
			(test (neq ?loc unknown))
		)
		(arm_info (grabbing ?object))
	)
	(not
		(dispatch_DIP decomposed)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(dispatch_DIP decomposed)
		(task (plan ?pnpdt_planName__) (action_type deliver_in_position) (params ?object ?position) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_DIP-fail
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_DIP) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(dispatch_DIP failed)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule dispatch_DIP-failed-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_DIP) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (action_type deliver_in_position) (params ?object ?position))
	(not
		(position (name ?position))
	)
	(not
		(dispatch_DIP failed)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(dispatch_DIP failed)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "I'm sorry I don't know the location where to deliver the object. I cannot accomplish your request.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_DIP-set_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_DIP) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (id ?id) (plan user_speech) (action_type deliver_in_position) (params ?object ?position) (step $?step))
	?pnpdt_f2__ <-(object_confirmed ?new_obj)
	(not
		(item (name ?object))
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(dispatch_DIP decomposed)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (id ?id) (plan user_speech) (action_type deliver_in_position) (params ?new_obj ?position) (step $?step))
	)
)

(defrule dispatch_DIP-set_object_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_DIP) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (id ?id) (plan user_speech) (action_type deliver_in_position) (params ?object ?position))
	?pnpdt_f1__ <-(location_confirmed ?new_loc)
	?pnpdt_f2__ <-(item (name ?object) (speech_name ?sp_name) (location unknown))
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(dispatch_DIP decomposed)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(item (name ?object) (speech_name ?sp_name) (location ?new_loc))
	)
)

################################
#      FINALIZING RULES
################################

(defrule dispatch_DIP-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_DIP) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(dispatch_DIP $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

