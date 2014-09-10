(defrule check_location_exists-send_command
	?p <-(plan (action_type check_location_exists) (params ?location))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (waiting (symbol check_location_exists)))
	(not (BB_answer "mp_position" check_location_exists 1 ?))
	=>
	(send-command "mp_position" check_location_exists ?location)
)

(defrule check_location_exists-does_NOT_exist
	?p <-(plan (task ?taskName) (action_type check_location_exists) (params ?location) (step ?step $?steps) )
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "mp_position" check_location_exists 0 ?)
	=>
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "I found the error, I do not know the location" ?location) (step ?step $?steps))
		(plan_status ?p successful)
	)
)

(defrule check_location_exists-exists
	?p <-(plan (action_type check_location_exists))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "mp_position" check_location_exists 1 ?)
	=>
	(assert
		(plan_status ?p failed)
	)
)

(defrule check_location_exists-finished
	?p <-(plan (action_type check_location_exists))
	(active_plan ?p)
	(plan_status ?p ?)
	=>
	(assert
		(checked_location_exists)
	)
)
