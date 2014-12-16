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

(defrule NOT_allTasksEnabled-retract_higher_hierarchy_tasks
	(declare (salience 9800))

	(PE-allTasksEnabled)
	(not (PE-ready_to_plan))
	(not (task_status ? ?))
	(task (id ?t) (plan ?planName) (action_type ?action_type1) (step ?step1 $?steps1) (params $?params1))
	?at <-(active_task ?t)
	; There's another task of the same plan that should have been activated before this one.
	(task (id ?t2) (plan ?planName) (step ?step2 $?steps2))
	(test (neq ?t ?t2) )
	(test
		(or
			(> (length$ $?steps2) (length$ $?steps1))
			(and
				(eq $?steps2 $?steps1)
				(< ?step2 ?step1)
			)
		)
	)
;	(not (can_run_in_parallel ?action_type1 ?action_type2))
;	(not (can_run_in_parallel ?action_type2 ?action_type1))
	=>
	(retract ?at)
)

(defrule NOT_allTasksEnabled-start_canceling
	(declare (salience 9700))

	(PE-allTasksEnabled)
	(not (PE-ready_to_plan))
	(not (task_status ? ?))
	(task (id ?t) (plan ?planName) (action_type ?action_type1) (step ?step1 $?steps1) (params $?params1))
	(active_task ?t)
	; There's another task from a different plan that should have been activated before this one.
	(task (plan ~?planName) (action_type ?action_type2))
	(not (can_run_in_parallel ?action_type1 ?action_type2))
	(not (can_run_in_parallel ?action_type2 ?action_type1))
	(task_priority ?action_type2 ?x)
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
	=>
	(assert
		(cancel_active_tasks)
	)
)

(defrule NOT_allTasksEnabled-start_planning
	(declare (salience 9500))

	?ate <-(PE-allTasksEnabled)
	(not (PE-ready_to_plan))
	(not (task_status ? ?))
	(task (id ?t) (plan ?planName) (action_type ?action_type1) (step ?step1 $?steps1) (params $?params1))
	(not (active_task ?t))
	; There's no active task that cannot run in parallel with this one.
	(not
		(and
			(task (id ?t2) (action_type ?action_type2))
			(active_task ?t2)
			(not (can_run_in_parallel ?action_type1 ?action_type2))
			(not (can_run_in_parallel ?action_type2 ?action_type1))
		)
	)
	=>
	(retract ?ate)
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
;	(not (active_task ?))
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
	(task (id ?t) (plan ?planName) (action_type ?action_type) (params $?params1) (step ?step1 $?steps1))
	(not (PE-enabled_task ?t))
	(not (active_task ?t))
	(not
		(and
			(task (id ?t2) (step ?step2 $?steps2))
			(test (neq ?t ?t2) )
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
	(not (PE-allTasksEnabled))
	(PE-ready_to_plan)
	(not
		(and
			(task (id ?t) (plan ?planName) (action_type ?action_type) (params $?params1) (step ?step1 $?steps1))
			(not (PE-enabled_task ?t))
			(not (active_task ?t))
			(not
				(and
					(task (id ?t2) (step ?step2 $?steps2))
					(test (neq ?t ?t2) )
					(test
						(or
							(> (length$ $?steps2) (length$ $?steps1))
							(and
								(eq $?steps2 $?steps1)
								(< ?step2 ?step1)
							)
						)
					)
;					(not (can_run_in_parallel ?action_type1 ?action_type2))
;					(not (can_run_in_parallel ?action_type2 ?action_type1))
				)
			)
		)
	)
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
	(task (id ?current1) (plan ?planName) (action_type ?action_type1) (parent nil))
	(task (id ?t2) (action_type ?action_type2))
	(not
		(task_priority ?action_type1 ?)
	)
	(PE-last_plan ?planName)
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
	(PE-last_plan ?planName)
	(task (id ?current1) (plan ~?planName) (action_type ?action_type1) (parent nil))
	(not
		(task_priority ?action_type1 ?)
	)
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
	(task (id ?current1) (action_type ?action_type1) (parent ?parent1))
	(not
		(task_priority ?action_type1 ?)
	)
	(test (neq ?parent1 nil) )
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?t1 ?ref1 ?parent1 (+ ?d1 1) ?t2 ?ref2 ?current2 ?d2)
	)
)

(defrule set_task_active-search_top_priority_task-first_priority
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 nil ?current1 ?d1 ?t2 ?ref2 ?current2 ?d2)
	(task (id ?current1) (action_type ?action_type1))
	(task_priority ?action_type1 ?)
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
	(task (id ?current2) (plan ?planName2) (action_type ?action_type2) (parent ?parent2))
	(not
		(task_priority ?action_type2 ?)
	)
	(test (eq ?parent2 nil) )
	(PE-last_plan ?planName)
	(test (eq ?planName ?planName2 ) )
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
	(task (id ?current2) (plan ?planName2) (action_type ?action_type2) (parent ?parent2))
	(not
		(task_priority ?action_type2 ?)
	)
	(test (eq ?parent2 nil) )
	(PE-last_plan ?planName)
	(test (neq ?planName ?planName2) )
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
	(task (id ?current2) (action_type ?action_type2) (parent ?parent2))
	(not
		(task_priority ?action_type2 ?)
	)
	(test (neq ?parent2 nil) )
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 ?parent2 (+ ?d2 1))
	)
)

(defrule set_task_active-search_top_priority_task-second_priority
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 nil ?current2 ?d2)
	(task (id ?current2) (action_type ?action_type2))
	(task_priority ?action_type2 ?)
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
	(task (id ?current1) (plan ?planName1) (action_type ?action_type1) (parent ?parent1))
	(task (id ?ref2) (action_type ?action_type2))
	(not (PE-getting_second_different) )
	(task_priority ?action_type1 ?p1)
	(task_priority ?action_type2 ?p2)
	(test (= ?p1 ?p2))
	(test (eq ?parent1 nil) )
	(PE-last_plan ?planName)
	(test (eq ?planName ?planName1 ) )
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
	(task (id ?current1) (plan ?planName1) (action_type ?action_type1) (parent ?parent1))
	(task (id ?ref2) (action_type ?action_type2))
	(not (PE-getting_second_different) )
	(task_priority ?action_type1 ?p1)
	(task_priority ?action_type2 ?p2)
	(test (= ?p1 ?p2))
	(test (eq ?parent1 nil) )
	(PE-last_plan ?planName)
	(test (neq ?planName ?planName1 ) )
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
	(task (id ?current1) (plan ?planName1) (action_type ?action_type1) (parent ?parent1))
	(task (id ?ref2) (action_type ?action_type2))
	(task_priority ?action_type1 ?p1)
	(task_priority ?action_type2 ?p2)
	(test (= ?p1 ?p2))
	(test (neq ?parent1 nil) )
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?t1 ?ref1 ?parent1 (+ ?d1 1) ?t2 ?ref2 ?current2 ?d2)
	)
)

(defrule set_task_active-search_top_priority_task-get_first_different-different_priorities
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2&~nil ?current2 ?d2)
	(not (PE-getting_second_different) )
	(task (id ?current1) (action_type ?action_type1))
	(task (id ?ref2) (action_type ?action_type2))
	(task_priority ?action_type1 ?p1)
	(task_priority ?action_type2 ?p2)
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
	(task (id ?current2) (plan ?planName2) (action_type ?action_type2) (parent ?parent2))
	(task (id ?ref1) (action_type ?action_type1))
	(task_priority ?action_type1 ?p1)
	(task_priority ?action_type2 ?p2)
	(test (= ?p1 ?p2))
	(test (eq ?parent2 nil) )
	(PE-last_plan ?planName)
	(test (eq ?planName ?planName2 ) )
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
	(task (id ?current2) (plan ?planName2) (action_type ?action_type2) (parent ?parent2))
	(task (id ?ref1) (action_type ?action_type1))
	(task_priority ?action_type1 ?p1)
	(task_priority ?action_type2 ?p2)
	(test (= ?p1 ?p2))
	(test (eq ?parent2 nil) )
	(PE-last_plan ?planName)
	(test (neq ?planName ?planName2 ) )
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
	(task (id ?current2) (action_type ?action_type2) (parent ?parent2))
	(task (id ?ref1) (action_type ?action_type1))
	(task_priority ?action_type1 ?p1)
	(task_priority ?action_type2 ?p2)
	(test (= ?p1 ?p2))
	(test (neq ?parent2 nil) )
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?t1 ?ref1 ?current1 ?d1 ?t2 ?ref2 ?parent2 (+ ?d2 1))
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
	(task (id ?current1) (action_type ?action_type1))
	(task (id ?ref1) (action_type ?action_type_ref1))
	(task (id ?current2) (action_type ?action_type2))
	(task (id ?ref2) (action_type ?action_type_ref2))
	(task_priority ?action_type1 ?pc1)
	(task_priority ?action_type_ref1 ?pr1)
	(task_priority ?action_type2 ?pc2)
	(task_priority ?action_type_ref2 ?pr2)
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
	(task (id ?current1) (action_type ?action_type1))
	(task (id ?ref1) (action_type ?action_type_ref1))
	(task (id ?current2) (action_type ?action_type2))
	(task (id ?ref2) (action_type ?action_type_ref2))
	(task_priority ?action_type1 ?pc1)
	(task_priority ?action_type_ref1 ?pr1)
	(task_priority ?action_type2 ?pc2)
	(task_priority ?action_type_ref2 ?pr2)
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
	(task (id ?current1) (action_type ?action_type1))
	(task (id ?ref1) (action_type ?action_type_ref1))
	(task (id ?current2) (action_type ?action_type2))
	(task (id ?ref2) (action_type ?action_type_ref2))
	(task_priority ?action_type1 ?pc1)
	(task_priority ?action_type_ref1 ?pr1)
	(task_priority ?action_type2 ?pc2)
	(task_priority ?action_type_ref2 ?pr2)
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
	(task (id ?current1) (action_type ?action_type1))
	(task (id ?ref1) (action_type ?action_type_ref1))
	(task (id ?current2) (action_type ?action_type2))
	(task (id ?ref2) (action_type ?action_type_ref2))
	(task_priority ?action_type1 ?pc1)
	(task_priority ?action_type_ref2 ?pr2)
	(test (> ?pc1 ?pr2))
	(task_priority ?action_type_ref1 ?pr1)
	(task_priority ?action_type2 ?pc2)
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
	(task (id ?current1) (action_type ?action_type1))
	(task (id ?ref1) (action_type ?action_type_ref1))
	(task (id ?current2) (action_type ?action_type2))
	(task (id ?ref2) (action_type ?action_type_ref2))
	(task_priority ?action_type1 ?pc1)
	(task_priority ?action_type_ref2 ?pr2)
	(test (< ?pc1 ?pr2))
	(task_priority ?action_type_ref1 ?pr1)
	(task_priority ?action_type2 ?pc2)
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
	(task (id ?t) (action_type ?action_type1))
	(task (id ?at) (action_type ?action_type2))
	(not
		(or
			(can_run_in_parallel ?action_type1 ?action_type2)
			(can_run_in_parallel ?action_type2 ?action_type1)
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
			(task (id ?t) (action_type ?action_type1))
			(task (id ?at) (action_type ?action_type2))
			(not
				(or
					(can_run_in_parallel ?action_type1 ?action_type2)
					(can_run_in_parallel ?action_type2 ?action_type1)
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
