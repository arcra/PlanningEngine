;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							HANDLE PLAN OUTCOMES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule delete_plan_status
	(declare (salience 10000))
	?ps <-(plan_status ?p)
	?ap <-(active_plan ?p)
	(not
		(fact-existp ?p)
	)
	=>
	(retract ?ps ?ap)
	(log-message INFO "Deleted plan_status.")
)

; SUCCESSFUL PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; When a plan was successful, the planner must delete all plans up to some point where it can continue the execution of the task.

(defrule successful_plan-delete_successful_plan ; There is a plan with same hierarchy (unordered or successor) that should be executed. Delete this (successful) plan so the others can be activated.
	(declare (salience -10000))
	?ps <-(plan_status ?p successful)
	?ap <-(active_plan ?p)
	?p <-(plan (task ?taskName) (step ?step $?steps) (params $?params) (action_type ?action_type))
	?p2 <-(plan (task ?taskName) (step ? $?steps))
	(test
		(neq ?p ?p2)
	)
	=>
	(retract ?ps ?ap ?p)
	(log-message INFO "Successful plan of task '" ?taskName "' with action_type: '" ?action_type "' and params: '" $?params "' was deleted. Other plans of same hierarchy (unordered or successors) exist.")
)

(defrule successful_plan-make_parent_successful ; When there are no plans with same hierarchy (unordered or successors), make parent plan active (and successful)
	(declare (salience -10000))
	?ps <-(plan_status ?p successful)
	?ap <-(active_plan ?p)
	?p <-(plan (task ?taskName) (step ?step $?steps) (params $?params) (action_type ?action_type))
	(not
		(and
			(plan (task ?taskName) (step ? $?steps) (params $?params2) (action_type ?action_type2))
			(test
				(or
					(neq $?params $?params2)
					(neq ?action_type ?action_type2)
				)
			)
		)
	)
	?pp <-(plan (params $?params_PP) (action_type ?action_type_PP) )
	(PE-plan_children ?pp $? ?p $?)
	=>
	(retract ?ps ?ap ?p)
	(assert
		(plan_status ?pp successful)
		(active_plan ?pp)
	)
	(log-message INFO "Successful plan of task '" ?taskName "' with action_type: '" ?action_type "' and params: '" $?params "' was deleted with no other plans of same hierarchy. Parent plan with action_type: '" ?action_type_PP "' and params: '" $?params_PP "' is now active (and successful).")
)

(defrule successful_plan-top_level_succeeded ; Top-level plan was successful
	(declare (salience -10000))
	?ps <-(plan_status ?p successful)
	?ap <-(active_plan ?p)
	?p <-(plan (task ?taskName) (step ?step) (action_type ?action_type) (params $?params))
	(not
		(and
			(plan (task ?taskName) (step ?) (action_type ?action_type2) (params $?params2))
			(test
				(neq ?action_type ?action_type2)
				(neq $?params $?params2)
			)
		)
	)
	=>
	(retract ?ps ?ap ?p)
	(log-message INFO "Top level plan of task '" ?taskName "' with action_type: '" ?action_type "' and params: '" $?params "' succeeded!")
	(send-command "spg_say" top_level_succeeded (str-cat "I have finished the task " ?taskName) 10000)
)

; UNSUCCESSFUL PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; When a leaf node was unsuccessful, the planner must delete all plans up to some point where it can (replan and) manage to accomplish the task.

(defrule failed_plan-mark_plan_without_rules_as_failed ; When a plan has no rules (either to assert new sub-plans or perform an action) it is either an incomplete design or (most likely) a plan set to re-plan but with no more alternatives, which should be marked as failed.
	(declare (salience -10000))
	(active_plan ?p)
	?p <-(plan (task ?taskName) (step ?step $?steps) (action_type ?action_type))
	(not (waiting))
	(not (timer_sent $?))
	(not (plan_status ?p ?) )
	=>
	(assert
		(plan (task ?taskName) (action_type spg_say) (params "I don't know how to perform action:" ?action_type ".") (step (- ?step 1) $?steps))
		(plan_status ?p failed)
	)
	(log-message WARNING "No alternatives left to perform action " ?action_type)
)

(defrule failed_plan-delete_plans_with_same_hierarchy ; Other plans with same hierarchy (unordered or successors) must be cleared out.
	(declare (salience -10000))
	(active_plan ?p)
	(plan_status ?p failed)
	?p <-(plan (task ?taskName) (step ?step $?steps) (params $?params) (action_type ?action_type))
	?p2 <-(plan (task ?taskName) (step ?step2 $?steps) (params $?params2) (action_type ?action_type2))
	(test
		(neq ?p ?p2)
	)
	=>
	(retract ?p2)
	(log-message WARNING "Plan with steps: '" ?step " " $?steps "' failed. Deleted same hierarchy plan for task '" ?taskName "' with action_type: '" ?action_type2 "' and params: '" $?params2 "'.")
)

(defrule failed_plan-delete_failed_plan ; After removing all other same-hierarchy plans, remove this plan and let the engine replan. (this rule applies to non-top-level plans)
	(declare (salience -10000))
	?ps <-(plan_status ?p failed)
	?ap <-(active_plan ?p)
	?p <-(plan (task ?taskName) (step ?step ?next_step $?steps) (params $?params) (action_type ?action_type))
	(not
		(and
			(plan (task ?taskName) (step ? ?next_step $?steps) (params $?params2) (action_type ?action_type2))
			(test
				(neq ?action_type ?action_type2)
				(neq $?params $?params2)
			)
		)
	)
	=>
	(retract ?ps ?ap ?p)
	(log-message WARNING "Failed plan of task '" ?taskName "' with action_type: '" ?action_type "' and params: '" $?params "' was deleted. Parent plan should be activated for replanning.")
)

(defrule failed_plan-top_level_failed ; After removing all other same-hierarchy plans, remove this plan.
	(declare (salience -10000))
	?ps <-(plan_status ?p failed)
	?ap <-(active_plan ?p)
	?p <-(plan (task ?taskName) (step ?step) (params $?params) (action_type ?action_type))
	(not
		(and
			(plan (task ?taskName) (step ?) (params $?params2) (action_type ?action_type2))
			(test
				(neq ?action_type ?action_type2)
				(neq $?params $?params2)
			)
		)
	)
	=>
	(retract ?ps ?ap ?p)
	(log-message ERROR "Top level plan failed without alternative plan!")
	(send-command "spg_say" (str-cat "The plan for the task " ?taskName " failed and I don't have an alternative plan. I cannot accomplish the task." 10000)
)
