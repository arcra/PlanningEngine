################################
#         DEXEC RULES
################################

(defrule update_object_location-no_item
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(update_object_location updated)
	)
	(not
		(item (name ?object))
	)
	=>
	(assert
		(update_object_location updated)
		(item (name ?object) (speech_name ?object) (location ?location))
	)
)

(defrule update_object_location-speech-location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(update_object_location updated)
	(item (name ?object) (speech_name ?item_name) (location ?loc))
	(location (name ?loc) (speech_name ?loc_name) (room unknown))
	(not
		(update_object_location speech_sent)
	)
	=>
	(assert
		(update_object_location speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I now know the " ?item_name " is in the " ?loc_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule update_object_location-speech-location-room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(update_object_location updated)
	(item (name ?object) (speech_name ?item_name) (location ?loc))
	(location (name ?loc) (speech_name ?loc_name) (room ?room))
	(room (name ?room) (speech_name ?room_name))
	(not
		(update_object_location speech_sent)
	)
	=>
	(assert
		(update_object_location speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I now know the " ?item_name " is in the " ?loc_name " in the " ?room_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule update_object_location-speech-room
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(update_object_location updated)
	(item (name ?object) (speech_name ?item_name) (location ?loc))
	(room (name ?loc) (speech_name ?room_name))
	(not
		(update_object_location speech_sent)
	)
	=>
	(assert
		(update_object_location speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I now know the " ?item_name " is in the " ?room_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule update_object_location-speech-unknown
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(update_object_location updated)
	(item (name ?object) (speech_name ?item_name) (location unknown))
	(not
		(update_object_location speech_sent)
	)
	=>
	(assert
		(update_object_location speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I dont know where the " ?item_name " is.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule update_object_location-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(update_object_location speech_sent)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule update_object_location-update
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(item (name ?object) (speech_name ?item_name))
	(not
		(update_object_location updated)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(update_object_location updated)
		(item (name ?object) (speech_name ?item_name) (location ?location))
	)
)

################################
#      FINALIZING RULES
################################

(defrule update_object_location-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(update_object_location $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

