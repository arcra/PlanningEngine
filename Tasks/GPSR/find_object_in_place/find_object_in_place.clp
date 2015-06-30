################################
#         DEXEC RULES
################################

(defrule find_object_in_place-UOL-diff_loc_or_not_in_room_or_unknown
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?loc))
	(location (name ?loc) (room ?loc_room))
	(test (neq ?place ?loc))
	(test (neq ?place unknown))
	(test (neq ?place ?loc_room))
	=>
	(assert
		(find_object_in_place ready)
		(task (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?place) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object_in_place-UOL-diff_room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?room))
	(room (name ?room))
	(test (neq ?place unknown))
	(test (neq ?room ?place))
	=>
	(assert
		(find_object_in_place ready)
		(task (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?place) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object_in_place-failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(find_object_in_room failed)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule find_object_in_place-failed-speech-location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (speech_name ?item_name) (location ?place))
	(find_object_in_room location_searched ?place)
	(location (name ?place) (speech_name ?loc_name))
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(find_object_in_room object_found)
	)
	(not
		(find_object_in_room searching_location ?)
	)
	(not
		(find_object_in_room failed)
	)
	=>
	(assert
		(find_object_in_room failed)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I did not find the " ?item_name " in the " ?loc_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object_in_place-failed-speech-room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (speech_name ?item_name) (location ?place))
	(room (name ?place) (speech_name ?room_name))
	(not
		(find_object_in_room searching_location ?)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(find_object_in_room object_found)
	)
	(not
		(and
			(location (name ?loc) (room ?place))
			(not
				(find_object_in_room location_searched ?loc)
			)
		)
	)
	(not
		(find_object_in_room failed)
	)
	=>
	(assert
		(find_object_in_room failed)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I did not find the " ?item_name " in the " ?room_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object_in_place-failed-speech-unknown_room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (speech_name ?item_name))
	(test (eq ?place unknown))
	(not
		(find_object_in_room searching_location ?)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(and
			(location (name ?loc))
			(not
				(find_object_in_room location_searched ?loc)
			)
		)
	)
	(not
		(find_object_in_room failed)
	)
	(not
		(find_object_in_room object_found)
	)
	=>
	(assert
		(find_object_in_room failed)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I did not find the " ?item_name " anywhere!")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object_in_place-find_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object))
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

(defrule find_object_in_place-getclose_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(find_object_in_room searching_location ?loc)
	(item (name ?object))
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

(defrule find_object_in_place-object_found
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(item (name ?object) (speech_name ?sp_name))
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
		(find_object_in_room object_found)
		(find_object_in_room location_searched ?loc)
	)
)

(defrule find_object_in_place-object_not_found-presumed_loc
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(item (name ?object) (speech_name ?item_name) (location ?loc))
	?pnpdt_f2__ <-(find_object_in_room searching_location ?loc)
	?pnpdt_f3__ <-(error object_not_found ?object)
	?pnpdt_f4__ <-(find_object_in_room searching)
	(room (name ?room))
	(location (name ?loc) (room ?room))
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(location (name ?place))
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__ ?pnpdt_f4__)
	(assert
		(item (name ?object) (speech_name ?item_name) (location ?room))
		(find_object_in_room location_searched ?loc)
	)
)

(defrule find_object_in_place-object_not_found-room_or_unknown
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?loc))
	?pnpdt_f1__ <-(find_object_in_room searching_location ?loc)
	?pnpdt_f2__ <-(error object_not_found ?object)
	?pnpdt_f3__ <-(find_object_in_room searching)
	(test (eq ?loc ?place))
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(location (name ?loc))
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(find_object_in_room location_searched ?loc)
	)
)

(defrule find_object_in_place-ready_to_search
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(or
		(and
			(room (name ?place))
			(item (name ?object) (location ?loc))
			(location (name ?loc) (room ?place))
		)
		(item (name ?object) (location ?place))
		(test (eq ?place unknown))
	)
	=>
	(assert
		(find_object_in_place ready)
	)
)

(defrule find_object_in_place-start_search-presumed_loc
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?loc))
	(location (name ?loc))
	(find_object_in_place ready)
	(not
		(find_object_in_room searching_location ?)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(find_object_in_room location_searched ?loc)
	)
	(not
		(find_object_in_room object_found)
	)
	=>
	(assert
		(find_object_in_room searching_location ?loc)
	)
)

(defrule find_object_in_place-start_search-presumed_room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?room))
	(location (name ?loc) (room ?room))
	(find_object_in_place ready)
	(room (name ?room))
	(not
		(find_object_in_room searching_location ?)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(find_object_in_room location_searched ?loc)
	)
	(not
		(find_object_in_room object_found)
	)
	=>
	(assert
		(find_object_in_room searching_location ?loc)
	)
)

(defrule find_object_in_place-start_search-unknown_room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(location (name ?loc))
	(item (name ?object) (location ?place))
	(test (eq ?place unknown))
	(find_object_in_place ready)
	(not
		(find_object_in_room searching_location ?)
	)
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(find_object_in_room location_searched ?loc)
	)
	(not
		(find_object_in_room object_found)
	)
	=>
	(assert
		(find_object_in_room searching_location ?loc)
	)
)

(defrule find_object_in_place-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(find_object_in_room succeeded)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule find_object_in_place-success-speech-arm
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (side ?side) (grabbing ?object))
	(item (name ?object) (speech_name ?item_name))
	(not
		(find_object_in_room succeeded)
	)
	=>
	(assert
		(find_object_in_room succeeded)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "The " ?item_name " is in my " ?side " arm.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule find_object_in_place-success-speech-location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(find_object_in_room object_found)
	(location (name ?loc) (speech_name ?loc_name))
	(item (name ?object) (speech_name ?item_name) (location ?loc))
	(not
		(arm_info (grabbing ?object))
	)
	(not
		(find_object_in_room succeeded)
	)
	=>
	(assert
		(find_object_in_room succeeded)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I found the " ?item_name " in the " ?loc_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

(defrule find_object_in_place-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type find_object_in_place) (params ?object ?place) (step $?pnpdt_steps__) )
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

