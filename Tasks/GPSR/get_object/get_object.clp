################################
#         DEXEC RULES
################################

(defrule get_object-loc_known-rbot_NOT_lctd-get_close
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?loc))
	(location (name ?loc))
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(robot_info (location ?loc))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type getclose_location) (params ?loc) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule get_object-loc_known-rbot_lctd-delete_error
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(robot_info (location ?loc))
	?pnpdt_f1__ <-(error object_not_found ?object)
	(item (name ?object) (location ?loc))
	(location (name ?loc))
	(not
		(get_object not_found_once)
	)
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(get_object not_found_once)
	)
)

(defrule get_object-loc_known-rbot_lctd-take_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(robot_info (location ?loc))
	(item (name ?object) (location ?loc))
	(location (name ?loc))
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(error object_not_found ?object)
	)
	(not
		(get_object not_found_once)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type take_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule get_object-loc_unknown
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?room))
	(not
		(room (name ?room))
	)
	(not
		(location (name ?room))
	)
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object unknown) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule get_object-loc_unknown-room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?room))
	(room (name ?room))
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule get_object-not_found-make_loc_unknown
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(robot_info (location ?loc))
	?pnpdt_f1__ <-(error object_not_found ?object)
	(test (neq ?loc unknown))
	?pnpdt_f2__ <-(item (name ?object) (speech_name ?sp_name) (location ?loc))
	?pnpdt_f3__ <-(get_object not_found_once)
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(item (name ?object) (speech_name ?sp_name) (location unknown))
	)
)

(defrule get_object-succeeded
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (grabbing ?object))
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

################################
#      CANCELING RULES
################################

