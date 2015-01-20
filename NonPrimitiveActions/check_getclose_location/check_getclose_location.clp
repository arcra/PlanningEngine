;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							GETCLOSE_LOCATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; First: Check if MVN-PLN is connected
; Second: Check if location exists in MVN-PLN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule check_getclose_location-decompose
	(task (id ?t) (plan ?planName) (action_type check_getclose_location) (params ?location) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (checked_location_exists ?location))
	(not (checked_module_is_connected "MVN-PLN"))
	=>
	(assert
		(task (plan ?planName) (action_type check_module_is_connected) (params "MVN-PLN") (step 1 $?steps) (parent ?t))
		(task (plan ?planName) (action_type check_location_exists) (params ?location) (step 2 $?steps) (parent ?t))
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			FOLLOW UP: FIXING PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Successful to find the cause of failure.
; Failure was: MVN-PLN was not connected
(defrule check_getclose_location-detected-not_connected-MVN-PLN
	(task (id ?t) (plan ?planName) (action_type check_getclose_location) (params ?location) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(children_status ?t failed)
	(not (checked_location_exists ?location))
	?cmc <-(checked_module_is_connected "MVN-PLN")
	=>
	(retract ?cmc)
	(assert
		(task (plan ?planName) (action_type wait_user_start_module) (params "MVN-PLN") (step 1 $?steps) (parent ?t))
	)
)

; Successful to find the cause of failure.
; Failure was: location is not set in the MVN-PLN
(defrule check_getclose_location-detected-location_does_NOT_exist
	(task (id ?t) (plan ?planName) (action_type check_getclose_location) (params ?location) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(children_status ?t failed)
	?cle <-(checked_location_exists)
	?cmc <-(checked_module_is_connected "MVN-PLN")
	=>
	(retract ?cmc ?cle)
	(assert
		(task (plan ?planName) (action_type wait_user_set_location) (params ?location) (step 1 $?steps) (parent ?t))
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			CLEAN-UP PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule check_getclose_location-finished
	(task (id ?t) (plan ?planName) (action_type check_getclose_location) (params ?location) (step ?step $?steps) (parent ?pt))
	(active_task ?t)
	(not (task_status ?t ?))

	(children_status ?t successful)
	?cle <-(checked_location_exists)
	?cmc <-(checked_module_is_connected "MVN-PLN")
	=>
	(retract ?cmc ?cle)
	(assert
		(task_status ?t successful)
	)
)
