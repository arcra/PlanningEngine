;		SUCCESSFUL
;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_for_user_instruction-successful
	(task (id ?t) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction finished)
	=>
	(assert
		(task_status ?t successful)
	)
)

;		CLEAN UP
;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_for_user_instruction-clean_up-executed
	(task (id ?t) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(task_status ?t successful)

	?f <-(wait_for_user_instruction finished)
	=>
	(retract ?f)
)

(defrule wait_for_user_instruction-clean_up-sv
	(task (id ?t) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(task_status ?t ?)

	?sp <-(BB_sv_updated "recognizedSpeech" $?)
	=>
	(retract ?sp)
)

(defrule wait_for_user_instruction-clean_up-speech
	(task (id ?t) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(task_status ?t ?)

	?sp <-(wait_for_user_instruction speech_sent)
	=>
	(retract ?sp)
)

(defrule wait_for_user_instruction-clean_up-user_task
	(task (id ?t) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(task_status ?t ?)

	?f <-(task (plan user_speech))
	=>
	(retract ?f)
)

;		EXECUTING
;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule wait_for_user_instruction-start_waiting
	(task (id ?t) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction speech_sent)
	(not (BB_sv_updated "recognizedSpeech" ? ? ? $?))
	(not (wait_for_user_instruction waiting))
	=>
	(assert
		(wait_for_user_instruction waiting)
	)
)

(defrule wait_for_user_instruction-stop_waiting
	(task (id ?t) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction speech_sent)
	(BB_sv_updated "recognizedSpeech" ? ? ? $?)
	?w <-(wait_for_user_instruction waiting)
	=>
	(retract ?w)
)

(defrule wait_for_user_instruction-send_phrase
	(task (id ?t) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction speech_sent)
	(not (wait_for_user_instruction waiting))
	?sp <-(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized)
	(test (neq (str-compare ?speech "robot that is all") 0))
	(test (neq (str-compare ?speech "robot never mind") 0))
	(test (neq (str-compare ?speech "that is all") 0))
	(test (neq (str-compare ?speech "never mind") 0))
	(not (waiting (cmd "process_string") (symbol parse_instruction)) )
	(or
		(not (BB_answer "process_string" parse_instruction ? ?))
		(BB_answer "process_string" parse_instruction 1 "try_again")
	)
	(not (task (plan user_speech)))
	(not (wait_for_user_instruction finished))
	=>
	(retract ?sp)
	(assert
		(BB_sv_updated "recognizedSpeech" (- ?count 1) $?recognized)
	)
	(send-command "process_string" parse_instruction ?speech)
)

(defrule wait_for_user_instruction-response_received
	(task (id ?t) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction speech_sent)
	(BB_answer "process_string" parse_instruction 1 ?response&~"try_again")
	(not (task (plan user_speech)))
	(not (wait_for_user_instruction finished))
	=>
	(eval (str-cat "(assert " (str-replace ?response "\\\"" "\"") ")"))
)

(defrule wait_for_user_instruction-instruction_received
	(task (id ?t) (plan ?planName) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction speech_sent)
	?task <-(task (id ?t2) (plan user_speech) (action_type ?action_type) (params $?params))
	(not (wait_for_user_instruction executed))
	(not (wait_for_user_instruction executing))
	(not (wait_for_user_instruction finished))
	=>
	(retract ?task)
	(assert
		(task (id ?t2) (plan ?planName) (action_type ?action_type) (params $?params) (step 1 $?steps) (parent ?t))
		(wait_for_user_instruction executing)
	)
)

(defrule wait_for_user_instruction-executed
	(task (id ?t) (plan ?planName) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction speech_sent)
	?f <-(wait_for_user_instruction executing)
	(children_status ?t ?)
	=>
	(retract ?f)
	(assert
		(task (plan ?planName) (action_type spg_say) (params "Let me know if you want me to do something else.") (step 1 $?steps) (parent ?t))
	)
	(setTimer 20000 wait_for_user_instruction_speech)
)

(defrule wait_for_user_instruction-task_dismissed
	(task (id ?t) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction speech_sent)
	(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized)
	(or
		(test (eq (str-compare ?speech "robot that is all") 0))
		(test (eq (str-compare ?speech "robot nevermind") 0))
		(test (eq (str-compare ?speech "that is all") 0))
		(test (eq (str-compare ?speech "nevermind") 0))
	)
	(not (wait_for_user_instruction finished))
	=>
	(assert
		(wait_for_user_instruction finished)
	)
)


;		SPEECH
;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule wait_for_user_instruction-send_first_speech
	(task (id ?t) (plan ?planName) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(not (wait_for_user_instruction speaking))
	(not (wait_for_user_instruction speech_sent))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm waiting for an instruction.")
			(step 1 $?steps) (parent ?t))
		(wait_for_user_instruction speaking)
	)
)

(defrule wait_for_user_instruction-first_speech_sent
	(task (id ?t) (plan ?planName) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	?f <-(wait_for_user_instruction speaking)
	(children_status ?t ?)
	(not (wait_for_user_instruction speech_sent))
	=>
	(retract ?f)
	(assert
		(wait_for_user_instruction speech_sent)
	)
	(setTimer 20000 wait_for_user_instruction_speech)
)

(defrule wait_for_user_instruction-send_speech
	(task (id ?t) (plan ?planName) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction speech_sent)
	(not (BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized))
	?f <-(BB_timer wait_for_user_instruction_speech)
	=>
	(retract ?f)
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm still waiting for an instruction.")
			(step 1 $?steps) (parent ?t))
		(wait_for_user_instruction speaking)
	)
)

(defrule wait_for_user_instruction-speech_sent
	(task (id ?t) (plan ?planName) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	?f <-(wait_for_user_instruction speaking)
	(children_status ?t ?)
	(wait_for_user_instruction speech_sent)
	=>
	(retract ?f)
	(setTimer 20000 wait_for_user_instruction_speech)
)

(defrule wait_for_user_instruction-response_received-try_again-speech-no_timer
	(task (id ?t) (plan ?planName) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction speech_sent)
	(not (BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized))
	?f <-(BB_answer "process_string" parse_instruction 1 "try_again")
	(not (timer_sent wait_for_user_instruction_speech))
	=>
	(retract ?f)
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I could not understand, please repeat the instruction.") (step 1 $?steps) (parent ?t))
		(wait_for_user_instruction speaking)
	)
)

(defrule wait_for_user_instruction-response_received-try_again-speech-reset_timer
	(task (id ?t) (plan ?planName) (action_type wait_for_user_instruction) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (canceling_active_tasks))

	(wait_for_user_instruction speech_sent)
	(not (BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized))
	?f <-(BB_answer "process_string" parse_instruction 1 "try_again")
	?ts <-(timer_sent wait_for_user_instruction_speech)
	=>
	(retract ?f ?ts)
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I could not understand, please repeat the instruction.") (step 1 $?steps) (parent ?t))
		(wait_for_user_instruction speaking)
	)
)
