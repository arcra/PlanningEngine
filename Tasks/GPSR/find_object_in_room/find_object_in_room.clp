################################
#         DEXEC RULES
################################

(defrule find_object_in_room-UOL-diff_room_or_unknown
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?loc))
	(test (neq ?room ?loc))
	(not
		(location (name ?loc))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?room) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object_in_room-UOL-location_not_in_room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?loc))
	(location (name ?loc) (room ?loc_room))
	(test (neq ?room ?loc_room))
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?room) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object_in_room-find_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?room))
	(find_object_in_room searching_location ?loc)
	(robot_info (location ?loc))
	(not
		(find_object_in_room searching)
	)
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(assert
		(find_object_in_room searching)
		(task (plan ?pnpdt_planName__) (action_type find_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object_in_room-getclose_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(find_object_in_room searching_location ?loc)
	(item (name ?object) (location ?room))
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

(defrule find_object_in_room-object_found
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(item (name ?object) (speech_name ?sp_name) (location ?room))
	?pnpdt_f2__ <-(find_object_in_room searching_location ?loc)
	?pnpdt_f3__ <-(find_object_in_room searching)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(error object_not_found ?object)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(item (name ?object) (speech_name ?sp_name) (location ?loc))
		(find_object_in_room location_searched ?loc)
	)
)

(defrule find_object_in_room-object_not_found
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?room))
	?pnpdt_f1__ <-(find_object_in_room searching_location ?loc)
	?pnpdt_f2__ <-(error object_not_found ?object)
	?pnpdt_f3__ <-(find_object_in_room searching)
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(find_object_in_room location_searched ?loc)
	)
)

(defrule find_object_in_room-start_search_location-room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(location (name ?loc) (room ?room))
	(item (name ?object) (location ?room))
	(test (neq ?room unknown))
	(not
		(find_object_in_room searching_location ?)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(find_object_in_room location_searched ?loc)
	)
	=>
	(assert
		(find_object_in_room searching_location ?loc)
	)
)

(defrule find_object_in_room-start_search_location-unknown_room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(location (name ?loc))
	(item (name ?object) (location ?room))
	(test (eq ?room unknown))
	(not
		(find_object_in_room searching_location ?)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(find_object_in_room location_searched ?loc)
	)
	=>
	(assert
		(find_object_in_room searching_location ?loc)
	)
)

(defrule find_object_in_room-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?loc))
	(or
		(and
			(test (neq ?room unknown))
			(location (name ?loc) (room ?room))
		)
		(arm_info (grabbing ?object))
		(and
			(location (name ?loc))
			(test (eq ?room unknown))
		)
	)
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule find_object_in_room-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_room) (params ?object ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(find_object_in_room $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

