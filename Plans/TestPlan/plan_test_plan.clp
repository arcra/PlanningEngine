(defrule test_plan-plan
	?p <-(plan (task ?taskName) (action_type test_plan) (params ?entrance_location) (step $?steps))
	(active_plan ?p)
	(not 
		(plan_status ?p ?)
	)
	=>
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "I'm going to execute the task:" ?taskName)
			(step 1 $?steps) )
		(plan (task ?taskName) (action_type enter_arena) (params ?entrance_location)
			(step 2 $?steps) )
	)
)
