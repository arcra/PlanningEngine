(defrule enter_arena-plan
	?p <-(plan (task ?taskName) (action_type enter_arena) (params ?entrance_location) (step $?steps))
	(active_plan ?p)
	(not 
		(plan_status ?p ?)
	)
	(not (executed))
	=>
	(assert
;		(executed)
;		(plan (task ?taskName) (action_type force_fail) (step 0 $?steps) (parent ?p) )
		(plan (task ?taskName) (action_type check_getclose_location) (params ?entrance_location) (step 1 $?steps) (parent ?p) )
		(plan (task ?taskName) (action_type wait_door) (params "door") (step 2 $?steps) (parent ?p) )
		(plan (task ?taskName) (action_type arms_goto) (params "navigation") (step 3 $?steps) (parent ?p) )
		(plan (task ?taskName) (action_type getclose_location) (params ?entrance_location) (step 4 $?steps) (parent ?p) )
	)
)
