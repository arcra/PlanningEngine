(defrule enter_arena-plan
	?p <-(plan (task ?taskName) (action_type enter_arena) (params ?entrance_location) (step $?steps))
	(active_plan ?p)
	(not 
		(plan_status ?p ?)
	)
	=>
	(plan (task ?taskName) (action_type wait_door) (params "door") (step 1 $?steps) )
	(plan (task ?taskName) (action_type arms_goto) (params "navigation") (step 2 $?steps) )
	(plan (task ?taskName) (action_type getclose_location) (params ?entrance_location) (step 3 $?steps) )
)
