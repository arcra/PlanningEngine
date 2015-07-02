################################
#         DEXEC RULES
################################

(defrule dispatch_user_instructions-APR-WFI-dispatch
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (id ?id2) (action_type ask_for_person_in_room) (params ?person ?room) (step ?step_1))
	?pnpdt_f2__ <-(task (plan user_speech) (id ?id1) (action_type wait_for_user_instruction) (step ?step_2))
	(room (name ?room))
	(test (> ?step_2 ?step_1))
	(not
		(and
			(task (plan user_speech) (id ?id3))
			(test (neq ?id1 ?id3))
			(test (neq ?id2 ?id3))
		)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type ask_for_person_in_room) (params ?person ?room) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step 2 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-DIP
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech) (id ?id) (action_type deliver_in_position) (params ?object ?position))
	(not
		(and
			(task (plan user_speech) (id ?id2))
			(test (neq ?id ?id2))
		)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type dispatch_DIP) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-GCL-GCL-GCL-dispatch
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(location (name ?loc2))
	?pnpdt_f1__ <-(task (plan user_speech) (id ?id1) (action_type getclose_location) (params ?loc1) (step ?step_1))
	?pnpdt_f2__ <-(task (plan user_speech) (id ?id3) (action_type getclose_location) (params ?loc3) (step ?step_3))
	?pnpdt_f3__ <-(task (plan user_speech) (id ?id2) (action_type getclose_location) (params ?loc2) (step ?step_2))
	(location (name ?loc3))
	(location (name ?loc1))
	(test (> ?step_3 ?step_2))
	(test (> ?step_2 ?step_1))
	(not
		(and
			(task (plan user_speech) (id ?id4))
			(test (neq ?id3 ?id4))
			(test (neq ?id1 ?id4))
			(test (neq ?id2 ?id4))
		)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type getclose_location) (params ?loc1) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type getclose_location) (params ?loc2) (step 2 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type getclose_location) (params ?loc3) (step 3 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-GO-APR-HOO-dispatch
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (id ?id1) (action_type get_object) (params ?object) (step ?step_1))
	?pnpdt_f2__ <-(task (plan user_speech) (id ?id2) (action_type ask_for_person_in_room) (params ?person ?room) (step ?step_2))
	(room (name ?room))
	?pnpdt_f3__ <-(task (plan user_speech) (id ?id3) (action_type handover_object) (params ?object) (step ?step_3))
	(test (> ?step_2 ?step_1))
	(test (> ?step_3 ?step_2))
	(not
		(and
			(task (plan user_speech) (id ?id4))
			(test (neq ?id1 ?id4))
			(test (neq ?id3 ?id4))
			(test (neq ?id2 ?id4))
		)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type ask_for_person_in_room) (params ?person ?room) (step 2 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step 3 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-GO-DIP-dispatch
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (id ?id2) (action_type get_object) (params ?object) (step ?step_1))
	?pnpdt_f2__ <-(task (plan user_speech) (id ?id) (action_type deliver_in_position) (params ?object ?position) (step ?step_2))
	(position (name ?position))
	(item (name ?object))
	(test (>= ?step_2 ?step_1))
	(not
		(and
			(task (plan user_speech) (id ?id3))
			(test (neq ?id ?id3))
			(test (neq ?id2 ?id3))
		)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type deliver_in_position) (params ?object ?position) (step 2 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-GO-POL-dispatch
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (id ?id2) (action_type get_object) (params ?object) (step ?step_1))
	?pnpdt_f2__ <-(task (plan user_speech) (id ?id1) (action_type put_object_in_location) (params ?object ?location) (step ?step_2))
	(location (name ?location))
	(item (name ?object))
	(test (> ?step_2 ?step_1))
	(not
		(and
			(task (plan user_speech) (id ?id3))
			(test (neq ?id1 ?id3))
			(test (neq ?id2 ?id3))
		)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type put_object_in_location) (params ?object ?location) (step 2 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-POL
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?location))
	(not
		(and
			(task (plan user_speech) (id ?id2))
			(test (neq ?id ?id2))
		)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type dispatch_POL) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-SAVE_POS
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (action_type save_position) (params ?symbol))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type save_position) (params ?symbol) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-SPG_SAY
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (id ?id) (action_type spg_say) (params ?speech))
	(not
		(and
			(task (plan user_speech) (id ?id2))
			(test (neq ?id2 ?id))
		)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params ?speech) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-THO
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech) (id ?id) (action_type take_handover) (params ?object))
	(not
		(and
			(task (plan user_speech) (id ?id2))
			(test (neq ?id ?id2))
		)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type dispatch_THO) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-THO-POL-dispatch
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(task (plan user_speech) (id ?id2) (action_type take_handover) (params ?object) (step ?step_1))
	?pnpdt_f2__ <-(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?location) (step ?step_2))
	(location (name ?location))
	(test (>= ?step_2 ?step_1))
	(not
		(and
			(task (plan user_speech) (id ?id3))
			(test (neq ?id ?id3))
			(test (neq ?id2 ?id3))
		)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
		(task (plan ?pnpdt_planName__) (action_type put_object_in_location) (params ?object ?location) (step 2 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-THO-POL-get_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(dispatch_user_instructions object_name ?item_name)
	(task (plan user_speech) (id ?id2) (action_type take_handover) (params ?object))
	(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?location))
	(not
		(and
			(task (plan user_speech) (id ?id3))
			(test (neq ?id ?id3))
			(test (neq ?id2 ?id3))
		)
	)
	(not
		(dispatch_user_instructions getting_location)
	)
	(not
		(location (name ?location))
	)
	=>
	(assert
		(dispatch_user_instructions getting_location)
		(task (plan ?pnpdt_planName__) (action_type ask_location) (params (str-cat "Where do you want me to take the " ?item_name "?")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-THO-POL-object_known
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (speech_name ?sp_name))
	(task (plan user_speech) (id ?id2) (action_type take_handover) (params ?object))
	(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?location))
	(not
		(and
			(task (plan user_speech) (id ?id3))
			(test (neq ?id ?id3))
			(test (neq ?id2 ?id3))
		)
	)
	(not
		(dispatch_user_instructions object_name ?)
	)
	=>
	(assert
		(dispatch_user_instructions object_name ?sp_name)
	)
)

(defrule dispatch_user_instructions-THO-POL-object_unknown
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?location))
	(task (plan user_speech) (id ?id2) (action_type take_handover) (params ?object))
	(not
		(and
			(task (plan user_speech) (id ?id3))
			(test (neq ?id2 ?id3))
			(test (neq ?id ?id3))
		)
	)
	(not
		(item (name ?object))
	)
	(not
		(dispatch_user_instructions object_name ?)
	)
	=>
	(assert
		(dispatch_user_instructions object_name ?object)
	)
)

(defrule dispatch_user_instructions-THO-POL-set_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech) (id ?id2) (action_type take_handover) (params ?object))
	?pnpdt_f1__ <-(dispatch_user_instructions getting_location)
	?pnpdt_f2__ <-(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?location) (step ?step))
	?pnpdt_f3__ <-(location_confirmed ?new_loc)
	(not
		(and
			(task (plan user_speech) (id ?id3))
			(test (neq ?id ?id3))
			(test (neq ?id2 ?id3))
		)
	)
	(not
		(location (name ?location))
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(task (plan user_speech) (id ?id) (action_type put_object_in_location) (params ?object ?new_loc) (step ?step))
	)
)

(defrule dispatch_user_instructions-UOL-known_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object))
	?pnpdt_f1__ <-(task (plan user_speech) (action_type update_object_location) (params ?object ?location))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type update_object_location) (params ?object ?location) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-fail
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(dispatch_user_instructions failed)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule dispatch_user_instructions-failed-speech
	(declare (salience -500))
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(task (plan user_speech))
	(not
		(dispatch_user_instructions failed)
	)
	=>
	(assert
		(dispatch_user_instructions failed)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "Im sorry I cannot accomplish the request.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule dispatch_user_instructions-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(task (plan user_speech))
	)
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule dispatch_user_instructions-clear-confirmation_received
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(confirmation_received ?)
	=>
	(retract ?pnpdt_f1__)
)

(defrule dispatch_user_instructions-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(dispatch_user_instructions $?)
	=>
	(retract ?pnpdt_f1__)
)

(defrule dispatch_user_instructions-clear-user_tasks
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(task (plan user_speech))
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

