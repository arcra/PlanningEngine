;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							PLANNING CONTROL RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					IMPORTANT NOTES (TO UNDERSTAND)
; - Only one top-level task (for each plan) is decomposed in smaller tasks
;	at a time. (Only one path from the root node to a lead node
;	of the task search tree)
;	i. e. The whole task is not "expanded" from the start.
;	UNLESS different steps can run in parallel.

; - A task fact can have an enabled_task fact or an active_task fact, but
;	not both.
; - Only the most detailed tasks (so far) (i. e. leaf nodes)
;	are either enabled or active. (i. e. parent tasks cannot be enabled,
;	and thus, cannot be discarded when activating tasks)
;
; - task_priority is a number. When two tasks are compared and one of them
;	does not have a task_priority, the other one will have prriority only
;	if its priority number is greater than zero.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;	GET READY TO START PLANNING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule NOT_allTasksEnabled-start_canceling
	(declare (salience 9800))

	?ate <-(PE-allTasksEnabled)
	(not (PE-ready_to_plan))
	(not (task_status ? ?))
	?t <-(task (plan ?planName) (action_type ?action_type1) (step ?step1 $?steps1) (params $?params1))
	(not (active_task ?t))
	; There's no other task of the same plan that should have been activated before this one. (i. e. this one should have been activated.)
	(not
		(and
			(task (plan ?planName) (action_type ?action_type2) (params $?params2) (step ?step2 $?steps2))
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
;			(not (can_run_in_parallel ?action_type1 ?action_type2))
;			(not (can_run_in_parallel ?action_type2 ?action_type1))
		)
	)
	; There's no other task from a different plan that should have been activated before this one. (i. e. this one should have been activated.)
	(not
		(and
			(task (plan ~?planName) (action_type ?action_type3))
			(task_priority ?action_type3 ?x)
			(or
				(and
					(not (task_priority ?action_type1 ?))
					(test (> ?x 0))
				)
				(and
					(task_priority ?action_type1 ?y)
					(test (> ?x ?y))
				)
			)
			(not (can_run_in_parallel ?action_type1 ?action_type3))
			(not (can_run_in_parallel ?action_type3 ?action_type1))
		)
	)
	=>
	(retract ?ate)
	(assert
		(cancel_active_tasks)
	)
)

(defrule NOT_allTasksEnabled-start_planning
	(declare (salience 9700))

	?ate <-(PE-allTasksEnabled)
	(not (PE-ready_to_plan))
	(not (task_status ? ?))
	?t <-(task (plan ?planName) (action_type ?action_type1) (step ?step1 $?steps1) (params $?params1))
	(not (active_task ?t))
	; There's no active task that cannot run in parallel with this one.
	(not
		(and
			(active_task ?t2)
			(not (can_run_in_parallel ?action_type1 =(fact-slot-value ?t2 action_type)))
			(not (can_run_in_parallel =(fact-slot-value ?t2 action_type) ?action_type1))
		)
	)
	=>
	(retract ?ate)
	(assert
		(PE-ready_to_plan)
	)
)

(defrule retract_active_tasks
	(declare (salience -9800))
	(cancel_active_tasks)
	?at <-(active_task ?)
	=>
	(retract ?at)
)

(defrule retract_cancel_tasks_flag
	?cat <-(cancel_active_tasks)
	(not (active_task ?))
	=>
	(retract ?cat)
)

(defrule set_ready_to_plan
	(not (active_task ?))
	(not (cancel_active_tasks))
	(not (PE-allTasksEnabled))
	(not (PE-ready_to_plan))
	=>
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

(defrule EnableMostDetailedTasksFromPlans
	(not (PE-allTasksEnabled))
	(PE-ready_to_plan)
	?t <-(task (plan ?planName) (action_type ?action_type) (params $?params1) (step ?step1 $?steps1))
	(not (PE-enabled_task ?t))
	(not
		(and
			(task (plan ?planName) (action_type ?action_type2) (params $?params2) (step ?step2 $?steps2))
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
;			(not (can_run_in_parallel ?action_type1 ?action_type2))
;			(not (can_run_in_parallel ?action_type2 ?action_type1))
		)
	)
	=>
	(assert
		(PE-enabled_task ?t)
	)
)

(defrule allTasksEnabled
	(declare (salience -9800))
	(not (PE-allTasksEnabled))
	(PE-ready_to_plan)
	=>
	(assert
		(PE-allTasksEnabled)
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

(defrule set_task_active-search_top_priority_task-start_comparing_tasks
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	(not (PE-comparing $?))
	(PE-enabled_task ?t1)
	(PE-enabled_task ?t2)
	(test
		(neq ?t1 ?t2)
	)
	(PE-discarded $?discarded)
	(not 
		(test
			(or
				(member$ ?t1 $?discarded)
				(member$ ?t2 $?discarded)
			)
		)
	)
	=>
	(assert
		(PE-comparing ?t1 nil ?t1 0 ?t2 nil ?t2 0)
	)
)

; FIRST REFERENCE
;;;;;;;;;;;;;;;;;;
(defrule set_task_active-search_top_priority_task-first_no_priority-no_parent-same_plan
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ? ?current1 ? ?t2 ? ? ?)
	(not
		(task_priority =(fact-slot-value ?current1 action_type) ?)
	)
	(test (eq (fact-slot-value ?current1 parent) nil) )
	(PE-last_plan ?planName)
	(test (eq ?planName (fact-slot-value ?current1 plan) ) )
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?d ?cmp)
	(assert
		(PE-discarded $?discarded ?t2)
	)
)

(defrule set_task_active-search_top_priority_task-first_no_priority-no_parent-different_plan
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ? ?current1 ? ?t2 ? ? ?)
	(not
		(task_priority =(fact-slot-value ?current1 action_type) ?)
	)
	(test (eq (fact-slot-value ?current1 parent) nil) )
	(PE-last_plan ?planName)
	(test (neq ?planName (fact-slot-value ?current1 plan) ) )
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?d ?cmp)
	(assert
		(PE-discarded $?discarded ?t1)
	)
)

(defrule set_task_active-search_top_priority_task-first_no_priority-parent
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	(not
		(task_priority =(fact-slot-value ?current1 action_type) ?)
	)
	(test (neq (fact-slot-value ?current1 parent) nil) )
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?t1 ?ref1 (fact-slot-value ?current1 parent) (+ ?d1 1) ?t2 ?ref2 ?current2 ?d2)
	)
)

(defrule set_task_active-search_top_priority_task-first_priority
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 nil ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	(task_priority =(fact-slot-value ?current1 action_type) ?)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?t1 ?current1 ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	)
)

; SECOND REFERENCE
;;;;;;;;;;;;;;;;;;

(defrule set_task_active-search_top_priority_task-second_no_priority-no_parent-same_plan
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ? ? ? ?t2 ? ?current2 ?)
	(not
		(task_priority =(fact-slot-value ?current2 action_type) ?)
	)
	(test (eq (fact-slot-value ?current2 parent) nil) )
	(PE-last_plan ?planName)
	(test (eq ?planName (fact-slot-value ?current2 plan) ) )
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?d ?cmp)
	(assert
		(PE-discarded $?discarded ?t1)
	)
)

(defrule set_task_active-search_top_priority_task-second_no_priority-no_parent-different_plan
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ? ? ? ?t2 ? ?current2 ?)
	(not
		(task_priority =(fact-slot-value ?current2 action_type) ?)
	)
	(test (eq (fact-slot-value ?current2 parent) nil) )
	(PE-last_plan ?planName)
	(test (neq ?planName (fact-slot-value ?current2 plan) ) )
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?d ?cmp)
	(assert
		(PE-discarded $?discarded ?t2)
	)
)

(defrule set_task_active-search_top_priority_task-second_no_priority-parent
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	(not
		(task_priority =(fact-slot-value ?current2 action_type) ?)
	)
	(test (neq (fact-slot-value ?current2 parent) nil) )
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 (fact-slot-value ?current2 parent) (+ ?d2 1))
	)
)

(defrule set_task_active-search_top_priority_task-second_priority
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 nil ?current2 ?d2)
	(task_priority =(fact-slot-value ?current2 action_type) ?)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?current2 ?current2 ?d2)
	)
)

; FIRST DIFFERENT
;;;;;;;;;;;;;;;;;;

(defrule set_task_active-search_top_priority_task-get_first_different-equal_priorities-no_parent-same_plan
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2&~nil ?current2 ?d2)
	(not (PE-getting_second_different) )
	(task_priority =(fact-slot-value ?current1 action_type) ?p1)
	(task_priority =(fact-slot-value ?ref2 action_type) ?p2)
	(test (= ?p1 ?p2))
	(test (eq (fact-slot-value ?current1 parent) nil) )
	(PE-last_plan ?planName)
	(test (eq ?planName (fact-slot-value ?current1 plan) ) )
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?d ?cmp)
	(assert
		(PE-discarded $?discarded ?t2)
	)
)

(defrule set_task_active-search_top_priority_task-get_first_different-equal_priorities-no_parent-different_plan
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2&~nil ?current2 ?d2)
	(not (PE-getting_second_different) )
	(task_priority =(fact-slot-value ?current1 action_type) ?p1)
	(task_priority =(fact-slot-value ?ref2 action_type) ?p2)
	(test (= ?p1 ?p2))
	(test (eq (fact-slot-value ?current1 parent) nil) )
	(PE-last_plan ?planName)
	(test (neq ?planName (fact-slot-value ?current1 plan) ) )
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?d ?cmp)
	(assert
		(PE-discarded $?discarded ?t1)
	)
)

(defrule set_task_active-search_top_priority_task-get_first_different-equal_priorities-parent
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2&~nil ?current2 ?d2)
	(not (PE-getting_second_different) )
	(task_priority =(fact-slot-value ?current1 action_type) ?p1)
	(task_priority =(fact-slot-value ?ref2 action_type) ?p2)
	(test (= ?p1 ?p2))
	(test (neq (fact-slot-value ?current1 parent) nil) )
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?t1 ?ref1 (fact-slot-value ?current1 parent) (+ ?d1 1) ?t2 ?ref2 ?current2 ?d2)
	)
)

(defrule set_task_active-search_top_priority_task-get_first_different-different_priorities
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2&~nil ?current2 ?d2)
	(not (PE-getting_second_different) )
	(task_priority =(fact-slot-value ?current1 action_type) ?p1)
	(task_priority =(fact-slot-value ?ref2 action_type) ?p2)
	(test (neq ?p1 ?p2))
	=>
	(assert
		(PE-getting_second_different)
	)
)

; SECOND DIFFERENT
;;;;;;;;;;;;;;;;;;

(defrule set_task_active-search_top_priority_task-get_second_different-equal_priorities-no_parent-same_plan
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1&~nil ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	(PE-getting_second_different)
	(task_priority =(fact-slot-value ?ref1 action_type) ?p1)
	(task_priority =(fact-slot-value ?current2 action_type) ?p2)
	(test (= ?p1 ?p2))
	(test (eq (fact-slot-value ?current2 parent) nil) )
	(PE-last_plan ?planName)
	(test (eq ?planName (fact-slot-value ?current2 plan) ) )
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?d ?cmp)
	(assert
		(PE-discarded $?discarded ?t1)
	)
)

(defrule set_task_active-search_top_priority_task-get_second_different-equal_priorities-no_parent-different_plan
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1&~nil ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	(PE-getting_second_different)
	(task_priority =(fact-slot-value ?ref1 action_type) ?p1)
	(task_priority =(fact-slot-value ?current2 action_type) ?p2)
	(test (= ?p1 ?p2))
	(test (eq (fact-slot-value ?current2 parent) nil) )
	(PE-last_plan ?planName)
	(test (neq ?planName (fact-slot-value ?current2 plan) ) )
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?d ?cmp)
	(assert
		(PE-discarded $?discarded ?t2)
	)
)

(defrule set_task_active-search_top_priority_task-get_second_different-equal_priorities-parent
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1&~nil ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	(PE-getting_second_different)
	(task_priority =(fact-slot-value ?ref1 action_type) ?p1)
	(task_priority =(fact-slot-value ?current2 action_type) ?p2)
	(test (= ?p1 ?p2))
	(test (neq (fact-slot-value ?current2 parent) nil) )
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 (fact-slot-value ?current2 parent) (+ ?d2 1))
	)
)

; GET WINNER
;;;;;;;;;;;;;;;;;;
(defrule set_task_active-search_top_priority_task-get_winner-different_winner-different_distances-first_wins
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	?gsd <-(PE-getting_second_different)
	(task_priority =(fact-slot-value ?current1 action_type) ?pc1)
	(task_priority =(fact-slot-value ?ref1 action_type) ?pr1)
	(task_priority =(fact-slot-value ?current2 action_type) ?pc2)
	(task_priority =(fact-slot-value ?ref2 action_type) ?pr2)
	(or
		(and
			(test (> ?pc1 ?pr2))
			(test (< ?pr1 ?pc2))
		)
		(and
			(test (< ?pc1 ?pr2))
			(test (> ?pr1 ?pc2))
		)
	)
	(test (< ?d1 ?d2))
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?gsd ?d)
	(assert
		(PE-discarded $?discarded ?t2)
	)
)

(defrule set_task_active-search_top_priority_task-get_winner-different_winner-different_distances-second_wins
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	?gsd <-(PE-getting_second_different)
	(task_priority =(fact-slot-value ?current1 action_type) ?pc1)
	(task_priority =(fact-slot-value ?ref1 action_type) ?pr1)
	(task_priority =(fact-slot-value ?current2 action_type) ?pc2)
	(task_priority =(fact-slot-value ?ref2 action_type) ?pr2)
	(or
		(and
			(test (> ?pc1 ?pr2))
			(test (< ?pr1 ?pc2))
		)
		(and
			(test (< ?pc1 ?pr2))
			(test (> ?pr1 ?pc2))
		)
	)
	(test (< ?d2 ?d1))
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?gsd ?d)
	(assert
		(PE-discarded $?discarded ?t1)
	)
)

(defrule set_task_active-search_top_priority_task-get_winner-different_winner-same_distances
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	?gsd <-(PE-getting_second_different)
	(task_priority =(fact-slot-value ?current1 action_type) ?pc1)
	(task_priority =(fact-slot-value ?ref1 action_type) ?pr1)
	(task_priority =(fact-slot-value ?current2 action_type) ?pc2)
	(task_priority =(fact-slot-value ?ref2 action_type) ?pr2)
	(or
		(and
			(test (> ?pc1 ?pr2))
			(test (< ?pr1 ?pc2))
		)
		(and
			(test (< ?pc1 ?pr2))
			(test (> ?pr1 ?pc2))
		)
	)
	(test (= ?d2 ?d1))
	=>
	(retract ?cmp ?gsd)
	(assert
		(PE-comparing ?t1 ?current1 ?current1 ?d1 ?t2 ?current2 ?current2 ?d2)
	)
)

(defrule set_task_active-search_top_priority_task-get_winner-same_winner-first_wins
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	?gsd <-(PE-getting_second_different)
	(task_priority =(fact-slot-value ?current1 action_type) ?pc1)
	(task_priority =(fact-slot-value ?ref2 action_type) ?pr2)
	(test (> ?pc1 ?pr2))
	(task_priority =(fact-slot-value ?ref1 action_type) ?pr1)
	(task_priority =(fact-slot-value ?current2 action_type) ?pc2)
	(test (> ?pr1 ?pc2))
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?gsd ?d)
	(assert
		(PE-discarded $?discarded ?t2)
	)
)

(defrule set_task_active-search_top_priority_task-get_winner-same_winner-second_wins
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	?gsd <-(PE-getting_second_different)
	(task_priority =(fact-slot-value ?current1 action_type) ?pc1)
	(task_priority =(fact-slot-value ?ref2 action_type) ?pr2)
	(test (< ?pc1 ?pr2))
	(task_priority =(fact-slot-value ?ref1 action_type) ?pr1)
	(task_priority =(fact-slot-value ?current2 action_type) ?pc2)
	(test (< ?pr1 ?pc2))
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?gsd ?d)
	(assert
		(PE-discarded $?discarded ?t1)
	)
)

; SET ACTIVE TASK
;;;;;;;;;;;;;;;;;;

(defrule set_task_active-search_top_priority_task-set_top_priority_task
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not
		(PE-activable_task ?)
	)
	?et <-(PE-enabled_task ?t)
	?d <-(PE-discarded $?discarded)
	; There's no other enabled task that is not discarded. (i. e. this is the only one activable.)
	(not
		(and
			(PE-enabled_task ?t2&~?t)
			(test
				(not
					(member$ ?t2 $?discarded)
				)
			)
		)
	)
	=>
	(retract ?et ?d)
	(assert
		(PE-activable_task ?t)
		(PE-activable_tasks ?t)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule set_task_active-search_parallel_tasks-discard_task
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	?et <-(PE-enabled_task ?t)
	(PE-activable_task ?at) ; Enabled tasks for activable tasks were already deleted.
	(not
		(or
			(can_run_in_parallel =(fact-slot-value ?t action_type) =(fact-slot-value ?at action_type))
			(can_run_in_parallel =(fact-slot-value ?at action_type) =(fact-slot-value ?t action_type))
		)
	)
	=>
	(retract ?et)
)

(defrule set_task_active-search_parallel_tasks-add_task
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	?et <-(PE-enabled_task ?t)
	(exists (PE-activable_task ?))
	(not
		(and
			(PE-activable_task ?at)
			(not
				(or
					(can_run_in_parallel =(fact-slot-value ?t action_type) =(fact-slot-value ?at action_type))
					(can_run_in_parallel =(fact-slot-value ?at action_type) =(fact-slot-value ?t action_type))
				)
			)
		)
	)
	?ats <-(PE-activable_tasks $?tasks)
	=>
	(retract ?ats ?et)
	(assert
		(PE-activable_task ?t)
		(PE-activable_tasks $?tasks ?t)
	)
)

(defrule set_task_active-search_parallel_tasks-delete_activable_task
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not
		(PE-enabled_task ?)
	)
	?at <-(PE-activable_task ?)
	=>
	(retract ?at)
)

(defrule set_task_active-search_parallel_tasks-delete_activable_tasks
	(PE-allTasksEnabled)
	?rtp <-(PE-ready_to_plan)
	(not
		(PE-activable_task ?)
	)
	?ats <-(PE-activable_tasks $?tasks)
	=>
	(retract ?ats ?rtp)
	(progn$ (?at $?tasks)
		(assert (active_task ?at))
	)
)
