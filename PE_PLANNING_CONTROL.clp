;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							PLANNING CONTROL RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					IMPORTANT NOTES (TO UNDERSTAND)
; - Only one top-level plan (for each task) is decomposed in smaller plans
;	at a time. (Only one path from the root node to a lead node
;	of the plan search tree)
;	i. e. The whole plan is not "expanded" from the start.
;	UNLESS different steps can run in parallel.

; - A plan fact can have an enabled_plan fact or an active_plan fact, but
;	not both.
; - Only the most detailed plans (so far) (i. e. leaf nodes)
;	are either enabled or active.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;	GET READY TO START PLANNING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule NOT_allPlansEnabled
	(declare (salience 10000))

	?ape <-(PE-allPlansEnabled)
	?p <-(plan (task ?taskName) (action_type ?action_type1) (step ?step1 $?steps1) (params $?params1))
	(not (enabled_plan ?p))
	(not (active_plan ?p))
	(not
		(and
			?p2 <-(plan (task ?taskName) (action_type ?action_type2) (params $?params2) (step ?step2 $?steps2))
			(test
				(neq ?p ?p2)
			)
			(test
				(or
					(> (length$ $?steps2) (length$ $?steps1))
					(and
						(eq $?steps2 $?steps1)
						(< ?step2 ?step1)
					)
				)
			)
			(not (can_run_in_parallel ?action_type1 ?action_type2))
			(not (can_run_in_parallel ?action_type2 ?action_type1))
		)
	)
	=>
	(retract ?ape)
)

(defrule retract_active
	; Executes after running al plan_outcome handling rules, before starting re-planning
;	(declare (salience 10000)) ; I think salience should not be necessary
	?ap <-(active_plan ?)
	(not (PE-allPlansEnabled))
	(not (PE-ready_to_plan))
	(not (plan_status ? ?))
	=>
	(retract ?ap)
)

(defrule retract_enabled
	; Executes after running al plan_outcome handling rules, before starting re-planning
;	(declare (salience 10000)) ; I think salience should not be necessary
	?ep <-(enabled_plan ?)
	(not (PE-allPlansEnabled))
	(not (PE-ready_to_plan))
	(not (plan_status ? ?))
	=>
	(retract ?ep)
)

(defrule set_ready_to_plan
;	(declare (salience 10000))
	(not (enabled_plan ?))
	(not (active_plan ?))
	(not (PE-allPlansEnabled))
	(not (PE-ready_to_plan))
	=>
	(assert
		(PE-ready_to_plan)
	)
)

;	ENABLE PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule EnableMostDetailedPlansFromTasks
;	(declare (salience -10000)) ; So plan_status can propagate before enabling new plans.
	(not (PE-allPlansEnabled))
	(PE-ready_to_plan)
	(not (plan_status ? ?)) ; So plan_status can propagate before enabling new plans.
	?p <-(plan (task ?taskName) (action_type ?action_type) (step ?step1 $?steps1) (params $?params))
	(not (enabled_plan ?p))
	(not
		(and
			?p2 <-(plan (task ?taskName) (action_type ?action_type2) (params $?params2) (step ?step2 $?steps2))
			(test
				(neq ?p ?p2)
			)
			(test
				(or
					(> (length$ $?steps2) (length$ $?steps1))
					(and
						(eq $?steps2 $?steps1)
						(< ?step2 ?step1)
					)
				)
			)
			(not (can_run_in_parallel ?action_type1 ?action_type2))
			(not (can_run_in_parallel ?action_type2 ?action_type1))
		)
	)
	=>
	(assert
		(enabled_plan ?p)
	)
)

(defrule allPlansEnabled
	(not (PE-allPlansEnabled) )
;	?rtp <-(ready_to_plan)
	?p <-(plan (task ?taskName) (action_type ?action_type1) (step ?step1 $?steps1) (params $?params1))
	(or
		(enabled_plan ?p)
		(and
			?p2 <-(plan (task ?taskName) (action_type ?action_type2) (params $?params2) (step ?step2 $?steps2))
			(test
				(neq ?p ?p2)
			)
			(test
				(or
					(> (length$ $?steps2) (length$ $?steps1))
					(and
						(eq $?steps2 $?steps1)
						(< ?step2 ?step1)
					)
				)
			)
			(not (can_run_in_parallel ?action_type1 ?action_type2))
			(not (can_run_in_parallel ?action_type2 ?action_type1))
		)
	)
	=>
;	(retract ?rtp)
	(assert
		(PE-allPlansEnabled)
		(PE-discarded)
	)
)

;	CREATE PLAN TREE FACTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule create_plan_children
	(declare (salience 10000))
	(active_plan ?p)
	?p <-(plan (task ?taskName) (action_type ?action_type) (params $?params) (step $?steps))
	(not (PE-plan_children ?p $?))
	=>
	(assert
		(PE-plan_children ?p)
	)
)

(defrule set_plan_children
	(declare (salience 10000))
	(active_plan ?p)
	?p <-(plan (task ?taskName) (action_type ?action_type) (params $?params) (step $?steps))
	?pch <-(PE-plan_children ?p $?children)
	?cp <-(plan (task ?taskName) (step ?step $?steps))
	(not
		(and
			(PE-plan_children ? $?children2)
			(test
				(member$ ?cp $?children2)
			)
		)
	)
	=>
	(retract ?pch)
	(assert
		(PE-plan_children ?p $?children ?cp)
	)
)

(defrule delete_plan_children
	(declare (salience 10000))
	?pch <-(PE-plan_children ?p $?)
	(not
		?p <-(plan (task ?taskName) (action_type ?action_type) (params $?params) (step $?steps))
	)
	=>
	(retract ?pch)
)

;	ACTIVATE PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule set_plan_active-no_other_enabled_plans
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	?p <-(plan (task ?taskName1) (action_type ?action_type1) (params $?params1) (step $?steps1))
	?ep <-(enabled_plan ?p)
	(not
		(and
			?p2 <-(plan (task ?taskName2) (action_type ?action_type2) (params $?params2) (step $?steps2))
			(enabled_plan ?p2)
			(test
				(neq ?p ?p2)
			)
		)
	)
	(not (active_plan ?))
	?d <-(PE-discarded)
	=>
	(retract ?ep ?d)
	(assert
		(active_plan ?p)
	)
)

(defrule set_plan_active-search_top_priority_plan-start_comparing_plans
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-top_priority_plan ?))
	(not (PE-comparing $?))
	?ep1<-(enabled_plan ?p1)
	?p1 <-(plan (task ?taskName1) (action_type ?action_type1) (params $?params1) (step $?steps1))
	?ep2<-(enabled_plan ?p2)
	?p2 <-(plan (task ?taskName2) (action_type ?action_type2) (params $?params2) (step $?steps2))
	(test
		(neq ?p1 ?p2)
	)
	(PE-discarded $?discarded)
	(not 
		(test
			(or
				(member$ ?p1 $?discarded)
				(member$ ?p2 $?discarded)
			)
		)
	)
	=>
	(assert
		(PE-comparing ?p1 ?p1 ?p2 ?p2)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_not_upgraded-wins_first
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-top_priority_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(plan_priority (fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority (fact-slot-value ?p2 action_type) ?priority2)
	(test
		(> ?priority1 ?priority2)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d)
	(assert
		(PE-discarded $?discarded ?ep2)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_not_upgraded-wins_second
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-top_priority_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(plan_priority (fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority (fact-slot-value ?p2 action_type) ?priority2)
	(test
		(> ?priority2 ?priority1)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d)
	(assert
		(PE-discarded $?discarded ?ep1)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_not_upgraded-draw
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-top_priority_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(plan_priority (fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority (fact-slot-value ?p2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	?p1 <-(plan (task ?taskName1) (step ?step1 $?steps1))
	?pp1 <-(plan (task ?taskName1) (step $?steps1))
	(PE-plan_children ?pp1 $? ?p1 $?)
	(PE-discarded $?discarded)
	(test
		(not
			(member$ ?pp1 $?discarded)
		)
	)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
		(PE-upgraded_first ?p1)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_upgraded_first-wins_first
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-top_priority_plan ?))
	?cmp <-(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
	?uf <-(PE-upgraded_first ?)
	(not (PE-upgraded_second ?))
	(plan_priority (fact-slot-value ?pp1 action_type) ?priority1)
	(plan_priority (fact-slot-value ?p2 action_type) ?priority2)
	(test
		(> ?priority1 ?priority2)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d ?uf)
	(assert
		(PE-discarded $?discarded ?ep2)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_upgraded_first-wins_second
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-top_priority_plan ?))
	?cmp <-(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
	?uf <-(PE-upgraded_first ?)
	(not (PE-upgraded_second ?))
	(plan_priority (fact-slot-value ?pp1 action_type) ?priority1)
	(plan_priority (fact-slot-value ?p2 action_type) ?priority2)
	(test
		(> ?priority2 ?priority1)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d ?uf)
	(assert
		(PE-discarded $?discarded ?ep1)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_upgraded_first-draw
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-top_priority_plan ?))
	?cmp <-(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
	(PE-upgraded_first ?p1)
	(not (PE-upgraded_second ?))
	(plan_priority (fact-slot-value ?pp1 action_type) ?priority1)
	(plan_priority (fact-slot-value ?p2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	?p2 <-(plan (task ?taskName2) (step ?step2 $?steps2))
	?pp2 <-(plan (task ?taskName2) (step $?steps2))
	(PE-plan_children ?pp2 $? ?p2 $?)
	(PE-discarded $?discarded)
	(test
		(not
			(member$ ?pp2 $?discarded)
		)
	)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?ep1 ?p1 ?ep2 ?pp2)
		(PE-upgraded_second ?pp1)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_upgraded_second-wins_first
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-top_priority_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?pp2)
	?uf <-(PE-upgraded_first ?p1)
	?us <-(PE-upgraded_second ?pp1)
	(plan_priority (fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority (fact-slot-value ?pp2 action_type) ?priority2)
	(test
		(> ?priority1 ?priority2)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d ?uf ?us)
	(assert
		(PE-discarded $?discarded ?ep2)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_upgraded_second-wins_second
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-top_priority_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?pp2)
	?uf <-(PE-upgraded_first ?p1)
	?us <-(PE-upgraded_second ?pp1)
	(plan_priority (fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority (fact-slot-value ?pp2 action_type) ?priority2)
	(test
		(> ?priority2 ?priority1)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d ?uf ?us)
	(assert
		(PE-discarded $?discarded ?ep1)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_upgraded_second-draw
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-top_priority_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?pp2)
	?uf <-(PE-upgraded_first ?p1)
	?us <-(PE-upgraded_second ?pp1)
	(plan_priority (fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority (fact-slot-value ?pp2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	=>
	(retract ?cmp ?uf ?us)
	(assert
		(PE-comparing ?ep1 ?pp1 ?ep2 ?pp2)
	)
)
