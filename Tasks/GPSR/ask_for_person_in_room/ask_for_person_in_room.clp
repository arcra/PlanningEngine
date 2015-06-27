################################
#         DEXEC RULES
################################

(defrule ask_for_person_in_room-fail
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_for_person_in_room) (params ?person ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(ask_for_person_in_room failed)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule ask_for_person_in_room-getclose_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_for_person_in_room) (params ?person ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(location (name ?loc2) (room ?room))
	(robot_info (location ?loc))
	(not
		(location (name ?loc) (room ?room))
	)
	(not
		(ask_for_person_in_room failed)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type getclose_location) (params ?loc2) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule ask_for_person_in_room-no_location_available
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_for_person_in_room) (params ?person ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(robot_info (location ?loc))
	(not
		(location (name ?loc) (room ?room))
	)
	(not
		(ask_for_person_in_room failed)
	)
	(not
		(location (name ?loc2) (room ?room))
	)
	=>
	(assert
		(ask_for_person_in_room failed)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I don't know any locations in room: " ?room)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule ask_for_person_in_room-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_for_person_in_room) (params ?person ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(location (name ?loc) (room ?room))
	(robot_info (location ?loc))
	(not
		(ask_for_person_in_room failed)
	)
	(not
		(ask_for_person_in_room speech_sent)
	)
	=>
	(assert
		(ask_for_person_in_room speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat ?person " please get in front of me.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 10000 wait_for_person_in_front)
)

(defrule ask_for_person_in_room-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_for_person_in_room) (params ?person ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_timer wait_for_person_in_front)
	(ask_for_person_in_room speech_sent)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule ask_for_person_in_room-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_for_person_in_room) (params ?person ?room) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(ask_for_person_in_room $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

