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
;	are either enabled or active. (i. e. parent plans cannot be enabled,
;	and thus, cannot be discarded when activating plans)
; - There should only be one parent plan for each plan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;	GET READY TO START PLANNING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule NOT_allPlansEnabled
	(declare (salience 9800))

	?ape <-(PE-allPlansEnabled)
	(not (PE-ready_to_plan))
	?p <-(plan (task ?taskName) (action_type ?action_type1) (step ?step1 $?steps1) (params $?params1))
	(not (PE-enabled_plan ?p))
	(not (active_plan ?p))
	(not
		(and
			(plan (task ?taskName) (action_type ?action_type2) (params $?params2) (step ?step2 $?steps2))
			(test
				(or
					(neq ?action_type1 ?action_type2)
					(neq $?params1 $?params2)
					(neq (create$ ?step1 $?steps1) (create$ ?step2 $?steps2))
				)
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
	?ap <-(active_plan ?)
	(not (PE-allPlansEnabled))
	(not (PE-ready_to_plan))
	(not (plan_status ? ?))
	=>
	(retract ?ap)
)

(defrule retract_enabled
	; Executes after running al plan_outcome handling rules, before starting re-planning
	; Shouldn't be necessary, as enabeld plans are deleted when activating plans.
	?ep <-(PE-enabled_plan ?)
	(not (PE-allPlansEnabled))
	(not (PE-ready_to_plan))
	(not (plan_status ? ?))
	=>
	(retract ?ep)
)

(defrule set_ready_to_delete_plan_children_facts
	(not (PE-enabled_plan ?))
	(not (active_plan ?))
	(not (PE-allPlansEnabled))
	(not (PE-ready_to_delete_plan_tree))
	(not (PE-ready_to_plan))
	=>
	(assert
		(PE-ready_to_delete_plan_tree)
;		(PE-ready_to_plan)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	CREATE PLAN TREE FACTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule create_plan_children
	(declare (salience 9800))
	?p <-(plan (task ?taskName) (action_type ?action_type) (params $?params) (step $?steps))
	(active_plan ?p)
	(not (PE-plan_children ?p $?))
	=>
	(assert
		(PE-plan_children ?p)
		(PE-current_parent ?p)
	)
)

(defrule set_plan_children
	(declare (salience 9800))
	?pch <-(PE-plan_children ?pp $?children)
	(PE-current_parent ?pp)
	(not
		(active_plan ?pp)
	)
	?cp <-(plan (task ?taskName) (step ?step ?next_step $?steps))
	(test
		(neq ?cp ?pp)
	)
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
		(PE-plan_children ?pp $?children ?cp)
	)
)

(defrule disable_plan_children
	(declare (salience 9500))
	(PE-plan_children ?pp $?)
	?current <-(PE-current_parent ?pp)
	(not
		(active_plan ?pp)
	)
	=>
	(retract ?current)
)

(defrule create_plan_children_do_not_delete_flags
	(declare (salience 9800))
;	?pch <-(PE-plan_children ?p&:(not (fact-existp ?p)) $? )
	(PE-ready_to_delete_plan_tree)
	?pp <-(plan)
	(PE-plan_children ?pp $?)
	=>
	(assert (PE-do_not_delete_plan ?pp))
)

(defrule delete_plan_children_facts
	(declare (salience 9500))
	(PE-ready_to_delete_plan_tree)
	?pch <-(PE-plan_children ?pp $?)
	(not
		(PE-do_not_delete_plan ?pp)
	)
	=>
	(retract ?pch)
)

(defrule stop_deleting_plan_children_facts
	(declare (salience 9500))
	?rdpt <-(PE-ready_to_delete_plan_tree)
	(not
		(and
			(PE-plan_children ?pp $?)
			(not
				(PE-do_not_delete_plan ?pp)
			)
		)
	)
	=>
	(retract ?rdpt)
	(assert (PE-done_deleting_plan_tree))
)

(defrule delete_flags
	(declare (salience 9500))
	(PE-done_deleting_plan_tree)
	?flag <-(PE-do_not_delete_plan ?)
	=>
	(retract ?flag)
)

(defrule set_ready_to_plan
	(declare (salience 9500))
	?ddpt <-(PE-done_deleting_plan_tree)
	(not (PE-do_not_delete_plan ?))
	=>
	(retract ?ddpt)
	(assert
		(PE-ready_to_plan)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	ENABLE PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule EnableMostDetailedPlansFromTasks
	(not (PE-allPlansEnabled))
	(PE-ready_to_plan)
;	(not (plan_status ? ?)) ; So plan_status can propagate before enabling new plans.
	?p <-(plan (task ?taskName) (action_type ?action_type) (params $?params1) (step ?step1 $?steps1))
	(not (PE-enabled_plan ?p))
	(not
		(and
			(plan (task ?taskName) (action_type ?action_type2) (params $?params2) (step ?step2 $?steps2))
			(test
				(or
					(neq ?action_type ?action_type2)
					(neq $?params1 $?params2)
					(neq (create$ ?step1 $?steps1) (create$ ?step2 $?steps2))
				)
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
		(PE-enabled_plan ?p)
	)
)

(defrule allPlansEnabled
	(declare (salience -9800))
	(not (PE-allPlansEnabled))
	(PE-ready_to_plan)
	=>
	(assert
		(PE-allPlansEnabled)
		(PE-discarded)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	ACTIVATE PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule set_plan_active-search_top_priority_plan-start_comparing_plans
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	(not (PE-comparing $?))
	?ep1<-(PE-enabled_plan ?p1)
	?ep2<-(PE-enabled_plan ?p2)
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

(defrule set_plan_active-search_top_priority_plan-no_priority_first-no_parent
	(declare (salience 9900))
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not
		(plan_priority =(fact-slot-value ?p1 action_type) ?)
	)
	(not
		(PE-plan_children ? $? ?p1 $?)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d)
	(assert
		(PE-discarded $?discarded ?ep1)
	)
)

(defrule set_plan_active-search_top_priority_plan-no_priority_second-no_parent
	(declare (salience 9900))
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(plan_priority =(fact-slot-value ?p1 action_type) ?)
	(not
		(plan_priority =(fact-slot-value ?p2 action_type) ?)
	)
	(not
		(PE-plan_children ? $? ?p2 $?)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d)
	(assert
		(PE-discarded $?discarded ?ep2)
	)
)

(defrule set_plan_active-search_top_priority_plan-no_priority_first
	(declare (salience 9800))
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not
		(plan_priority =(fact-slot-value ?p1 action_type) ?)
	)
	(PE-plan_children ?pp1 $? ?p1 $?) ; Notice there should only be one parent plan for each plan
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
	)
)

(defrule set_plan_active-search_top_priority_plan-no_priority_second
	(declare (salience 9800))
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not
		(plan_priority =(fact-slot-value ?p2 action_type) ?)
	)
	(PE-plan_children ?pp2 $? ?p2 $?)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?ep1 ?p1 ?ep2 ?pp2)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_not_upgraded-wins_first
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(plan_priority =(fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?p2 action_type) ?priority2)
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
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(plan_priority =(fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?p2 action_type) ?priority2)
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
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(plan_priority =(fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?p2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	(PE-plan_children ?pp1 $? ?p1 $?)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
		(PE-upgraded_first ?p1)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_not_upgraded-draw-no_parent-second_parent
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(plan_priority =(fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?p2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	(not
		(PE-plan_children ? $? ?p1 $?)
	)
	(PE-plan_children ?pp2 $? ?p2 $?)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?ep1 ?p1 ?ep2 ?pp2)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_not_upgraded-draw-no_parents
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?p2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(plan_priority =(fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?p2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	(not
		(PE-plan_children ? $? ?p1 $?)
	)
	(not
		(PE-plan_children ? $? ?p2 $?)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d)
	(assert
		(PE-discarded $?discarded ?ep2)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_upgraded_first-wins_first
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
	?uf <-(PE-upgraded_first ?)
	(not (PE-upgraded_second ?))
	(plan_priority =(fact-slot-value ?pp1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?p2 action_type) ?priority2)
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
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
	?uf <-(PE-upgraded_first ?)
	(not (PE-upgraded_second ?))
	(plan_priority =(fact-slot-value ?pp1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?p2 action_type) ?priority2)
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
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
	(PE-upgraded_first ?p1)
	(not (PE-upgraded_second ?))
	(plan_priority =(fact-slot-value ?pp1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?p2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	(PE-plan_children ?pp2 $? ?p2 $?)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?ep1 ?p1 ?ep2 ?pp2)
		(PE-upgraded_second ?pp1)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_upgraded_first-draw-no_second_parent-first_parent

	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
	?uf <-(PE-upgraded_first ?)
	(not (PE-upgraded_second ?))
	(plan_priority =(fact-slot-value ?pp1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?p2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	(not
		(PE-plan_children ? $? ?p2 $?)
	)
	(PE-plan_children ?pp3 $? ?pp1 $?)
	=>
	(retract ?cmp ?uf)
	(assert
		(PE-comparing ?ep1 ?pp3 ?ep2 ?p2)
		(PE-upgraded_first ?pp1)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_upgraded_first-draw-no_parents

	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?pp1 ?ep2 ?p2)
	?uf <-(PE-upgraded_first ?)
	(not (PE-upgraded_second ?))
	(plan_priority =(fact-slot-value ?pp1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?p2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	(not
		(PE-plan_children ?pp2 $? ?p2 $?)
	)
	(not
		(PE-plan_children ?pp3 $? ?pp1 $?)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?uf ?d)
	(assert
		(PE-discarded $?discarded ?ep2)
	)
)

(defrule set_plan_active-search_top_priority_plan-comparing_upgraded_second-wins_first
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?pp2)
	?uf <-(PE-upgraded_first ?p1)
	?us <-(PE-upgraded_second ?pp1)
	(plan_priority =(fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?pp2 action_type) ?priority2)
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
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?pp2)
	?uf <-(PE-upgraded_first ?p1)
	?us <-(PE-upgraded_second ?pp1)
	(plan_priority =(fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?pp2 action_type) ?priority2)
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
	(not (PE-activable_plan ?))
	?cmp <-(PE-comparing ?ep1 ?p1 ?ep2 ?pp2)
	?uf <-(PE-upgraded_first ?p1)
	?us <-(PE-upgraded_second ?pp1)
	(plan_priority =(fact-slot-value ?p1 action_type) ?priority1)
	(plan_priority =(fact-slot-value ?pp2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	=>
	(retract ?cmp ?uf ?us)
	(assert
		(PE-comparing ?ep1 ?pp1 ?ep2 ?pp2)
	)
)

(defrule set_plan_active-search_top_priority_plan-set_top_priority_plan
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not
		(PE-activable_plan ?)
	)
	?ep <-(PE-enabled_plan ?p)
	?d <-(PE-discarded $?discarded)
	(not
		(and
			(PE-enabled_plan ?p2)
			(test
				(and
					(neq ?p ?p2)
					(not
						(member$ ?p2 $?discarded)
					)
				)
			)
		)
	)
	=>
	(retract ?ep ?d)
	(assert
		(PE-activable_plan ?p)
		(PE-activable_plans ?p)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule set_plan_active-search_parallel_plans-discard_plan
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	?ep <-(PE-enabled_plan ?p)
	(PE-activable_plan ?ap)
	(not
		(or
			(can_run_in_parallel =(fact-slot-value ?p action_type) =(fact-slot-value ?ap action_type))
			(can_run_in_parallel =(fact-slot-value ?ap action_type) =(fact-slot-value ?p action_type))
		)
	)
	=>
	(retract ?ep)
)

(defrule set_plan_active-search_parallel_plans-add_plan
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	?ep <-(PE-enabled_plan ?p)
	(exists (PE-activable_plan ?))
	(not
		(and
			(PE-activable_plan ?ap)
			(not
				(or
					(can_run_in_parallel =(fact-slot-value ?p action_type) =(fact-slot-value ?ap action_type))
					(can_run_in_parallel =(fact-slot-value ?ap action_type) =(fact-slot-value ?p action_type))
				)
			)
		)
	)
	?aps <-(PE-activable_plans $?plans)
	=>
	(retract ?aps ?ep)
	(assert
		(PE-activable_plan ?p)
		(PE-activable_plans $?plans ?p)
	)
)

(defrule set_plan_active-search_parallel_plans-delete_activable_plan
	(PE-allPlansEnabled)
	(PE-ready_to_plan)
	(not
		(PE-enabled_plan ?)
	)
	?ap <-(PE-activable_plan ?)
	=>
	(retract ?ap)
)

(defrule set_plan_active-search_parallel_plans-delete_activable_plans
	(PE-allPlansEnabled)
	?rtp <-(PE-ready_to_plan)
	(not
		(PE-activable_plan ?)
	)
	?aps <-(PE-activable_plans $?plans)
	=>
	(retract ?aps ?rtp)
	(progn$ (?ap $?plans)
		(assert (active_plan ?ap))
	)
)
