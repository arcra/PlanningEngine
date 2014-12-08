;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							GETCLOSE_LOCATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; First plan: Check if MVN-PLN is connected
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule check_failure-check_getclose_location-check_module_is_connected
	?t <-(task (plan ?planName) (action_type check_getclose_location) (params ?location) (step $?steps))
	(active_task ?t)
	(not 
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(not (checked_module_is_connected MVN-PLN))
	=>
	(assert
		(task (plan ?planName) (action_type check_module_is_connected) (params "MVN-PLN") (step 1 $?steps) (parent ?t))
	)
)

; Second plan: Check if location exists in MVN-PLN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule check_failure-check_getclose_location-check_location_exists
	?t <-(task (plan ?planName) (action_type check_getclose_location) (params ?location) (step $?steps))
	(active_task ?t)
	(not 
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	(checked_module_is_connected "MVN-PLN")
	(not (checked_location_exists))
	=>
	(assert
		(task (plan ?planName) (action_type check_location_exists) (params ?location) (step 1 $?steps) (parent ?t))
	)
)

; Last plan available, i. e. all other plans failed. All tests failed to find the cause of failure, everything is working as it should... mark as successful to try again.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule check_failure-check_getclose_location-is_working_correctly
	?t <-(task (plan ?planName) (action_type check_getclose_location) (params ?location) (step $?steps) (parent ?pt))
	(active_task ?t)
	(not 
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))
	?cle <-(checked_location_exists)
	?cmc <-(checked_module_is_connected "MVN-PLN")
	=>
	(retract ?cle ?cmc)
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I could not find the reason why I couldn't get close to a specified location, I will try again.") (step $?steps) (parent ?pt))
		(task_status ?t successful)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			FOLLOW UP: CLEAN-UP / FIXING PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Successful to find the cause of failure.
; Failure was: MVN-PLN was not connected
(defrule check_failure-check_getclose_location-detected-not_connected-MVN-PLN
	?t <-(task (plan ?planName) (action_type check_getclose_location) (params ?location) (step $?steps) (parent ?pt))
	(active_task ?t)
	(task_status ?t successful)
	(not (checked_location_exists))
	?cmc <-(checked_module_is_connected "MVN-PLN")
	=>
	(retract ?cmc)
	(assert
		(task (plan ?planName) (action_type wait_user_start_module) (params "MVN-PLN") (step $?steps) (parent ?pt))
	)
)

; Successful to find the cause of failure.
; Failure was: location is not set in the MVN-PLN
(defrule check_failure-check_getclose_location-detected-location_does_NOT_exist
	?t <-(task (plan ?planName) (action_type check_getclose_location) (params ?location) (step $?steps) (parent ?pt))
	(active_task ?t)
	(task_status ?t successful)
	?cle <-(checked_location_exists)
	?cmc <-(checked_module_is_connected "MVN-PLN")
	=>
	(retract ?cmc ?cle)
	(assert
		(task (plan ?planName) (action_type wait_user_set_location) (params ?location) (step $?steps) (parent ?pt))
	)
)
