################################
#         DEXEC RULES
################################

(defrule confirm_POL-ask_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type confirm_POL) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?location))
	(confirm_POL speech_repr ?object ?item_name)
	(not
		(location (name ?location))
	)
	(not
		(location_confirmed $?)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type ask_location) (params (str-cat "Where would you like me to take the " ?item_name "?")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule confirm_POL-ask_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type confirm_POL) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech) (action_type put_object_in_location) (params ?object ?location))
	(location (name ?location) (speech_name ?loc_name))
	(not
		(object_confirmed $?)
	)
	(not
		(item (name ?object))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type ask_object) (params (str-cat "Which " ?object " would you like me to take to the " ?loc_name "?")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule confirm_POL-decompose
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type confirm_POL) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(location (name ?location))
	?pnpdt_f1__ <-(task (plan user_speech) (action_type put_object_in_location) (params ?object ?location))
	(item (name ?object))
	(not
		(confirm_POL decomposed)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(confirm_POL decomposed)
		(task (plan ?pnpdt_planName__) (action_type put_object_in_location) (params ?object ?location) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule confirm_POL-set_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type confirm_POL) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?location) (step $?step))
	?pnpdt_f2__ <-(location_confirmed ?new_loc)
	(not
		(location (name ?location))
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?new_loc) (step $?step))
	)
)

(defrule confirm_POL-set_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type confirm_POL) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?new_obj))
	?pnpdt_f1__ <-(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?location) (step $?step))
	?pnpdt_f2__ <-(object_confirmed ?new_obj)
	?pnpdt_f3__ <-(confirm_POL speech_repr ?object ?)
	(not
		(item (name ?object))
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?new_obj ?location) (step $?step))
	)
)

(defrule confirm_POL-set_object_text-known_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type confirm_POL) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech) (action_type put_object_in_location) (params ?object ?location))
	(item (name ?object) (speech_name ?item_name))
	(not
		(confirm_POL speech_repr ?object ?)
	)
	(not
		(confirm_POL decomposed)
	)
	=>
	(assert
		(confirm_POL speech_repr ?object ?item_name)
	)
)

(defrule confirm_POL-set_object_text-unknown_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type confirm_POL) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech) (action_type put_object_in_location) (params ?object ?location))
	(not
		(confirm_POL speech_repr ?object ?)
	)
	(not
		(confirm_POL decomposed)
	)
	(not
		(item (name ?object))
	)
	=>
	(assert
		(confirm_POL speech_repr ?object ?object)
	)
)

(defrule confirm_POL-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type confirm_POL) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(confirm_POL decomposed)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule confirm_POL-clear_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type confirm_POL) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(confirm_POL $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

