################################
#         DEXEC RULES
################################

(defrule wait_for_user_instruction-dependencies
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction inexistent_fact)
	=>
)

(defrule wait_for_user_instruction-ex-1-clear_SV-clear
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" ? ? ? $?)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	)
)

(defrule wait_for_user_instruction-ex-1-clear_SV-cleared
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	(not
		(BB_sv_updated "recognizedSpeech" ? ? ? $?)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	)
	=>
	(assert
		(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	)
)

(defrule wait_for_user_instruction-ex-2-1-confirmed-no-first
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	?pnpdt_f1__ <-(confirmation_received no)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	?pnpdt_f2__ <-(wait_for_user_instruction ?pnpdt_task__ confirming_speech ?)
	(not
		(wait_for_user_instruction ?pnpdt_task__ first_no)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ confirmed ?)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(wait_for_user_instruction ?pnpdt_task__ first_no)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "Please tell me again what would you like me to do?") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-ex-2-1-confirmed-no-second
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	?pnpdt_f2__ <-(confirmation_received no)
	?pnpdt_f3__ <-(wait_for_user_instruction ?pnpdt_task__ first_no)
	?pnpdt_f4__ <-(wait_for_user_instruction ?pnpdt_task__ confirming_speech ?)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ confirmed ?)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__ ?pnpdt_f4__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "Please tell me again what would you like me to do?") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-ex-2-1-confirmed-yes
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ confirming_speech ?speech)
	?pnpdt_f2__ <-(confirmation_received yes)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ confirmed ?)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(wait_for_user_instruction ?pnpdt_task__ confirmed ?speech)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "Ok.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-ex-2-ask_for_confirmation
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized)
	(test (neq ?speech "robot that is all"))
	(test (neq ?speech "that is all"))
	(test (neq ?speech "robot yes"))
	(test (neq ?speech "robot no"))
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	(test (neq ?speech "robot never mind"))
	(test (neq ?speech "never mind"))
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ confirmed ?)
	)
	(not
		(confirmation_received ?)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ confirming_speech ?)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ parsing)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(BB_sv_updated "recognizedSpeech" (- ?count 1) $?recognized)
		(wait_for_user_instruction ?pnpdt_task__ confirming_speech ?speech)
		(task (plan ?pnpdt_planName__) (action_type ask_for_confirmation) (params (str-cat "Did you say: " ?speech "?")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-ex-2-task_dismissed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?)
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	(or
		(test (eq ?speech "robot that is all"))
		(test (eq ?speech "that is all"))
		(test (eq ?speech "robot never mind"))
		(test (eq ?speech "never mind"))
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(wait_for_user_instruction ?pnpdt_task__ fail)
		(wait_for_user_instruction ?pnpdt_task__ finished)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "Ok have a good day.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-ex-3-1-check_process_string
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "process_string" parse_instruction 0 ?speech)
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	?pnpdt_f2__ <-(wait_for_user_instruction ?pnpdt_task__ parsing)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(waiting (cmd "process_string") (symbol parse_instruction))
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_process_string) (params ?speech) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-ex-3-1-parse-failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "process_string" parse_instruction 1 "try_again")
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	?pnpdt_f2__ <-(wait_for_user_instruction ?pnpdt_task__ parsing)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(waiting (cmd "process_string") (symbol parse_instruction))
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "I could not process your request would you like me to do something else?") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-ex-3-parse
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ confirmed ?speech)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(waiting (cmd "process_string") (symbol parse_instruction))
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ parsing)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(wait_for_user_instruction ?pnpdt_task__ parsing)
	)
	(send-command "process_string" parse_instruction ?speech 5000 )
)

(defrule wait_for_user_instruction-ex-4-parse-succeeded
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	(BB_answer "process_string" parse_instruction 1 ?response)
	(test (neq ?response "try_again"))
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ parsing)
	?pnpdt_f2__ <-(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(eval (str-cat "(assert " (str-replace ?response "\\\"" "\"") ")"))
)

(defrule wait_for_user_instruction-ex-5-start_timer
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	(task (plan user_speech))
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	(not
		(timer_sent wait_user_speech)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(BB_timer wait_user_speech)
	)
	=>
	(retract ?pnpdt_f1__)
	(setTimer 2500 wait_user_speech)
)

(defrule wait_for_user_instruction-ex-6-start_executing
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	(task (plan user_speech))
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	?pnpdt_f1__ <-(BB_timer wait_user_speech)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ executing)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(wait_for_user_instruction ?pnpdt_task__ executing)
		(task (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-ex-7-1-execute_next
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	(task (plan user_speech))
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	(wait_for_user_instruction ?pnpdt_task__ executing)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type dispatch_user_instructions) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-ex-7-2-finished_executing
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ executing)
	(not
		(task (plan user_speech))
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(wait_for_user_instruction ?pnpdt_task__ finished)
		(wait_for_user_instruction ?pnpdt_task__ success)
	)
)

(defrule wait_for_user_instruction-fail
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ finished)
	?pnpdt_f2__ <-(wait_for_user_instruction ?pnpdt_task__ fail)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule wait_for_user_instruction-sp-first_speech_sent
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ speaking)
	(not
		(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	)
	(not
		(robot_info (status stand_by))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	)
	(setTimer 20000 wait_for_user_instruction_speech)
)

(defrule wait_for_user_instruction-sp-send_first_speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ speaking)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	)
	(not
		(robot_info (status stand_by))
	)
	=>
	(assert
		(wait_for_user_instruction ?pnpdt_task__ speaking)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "Im waiting for an instruction.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-sp-send_speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	?pnpdt_f1__ <-(BB_timer wait_for_user_instruction_speech)
	(not
		(robot_info (status stand_by))
	)
	(not
		(BB_sv_updated "recognizedSpeech" ? ? ? $?)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(wait_for_user_instruction ?pnpdt_task__ speaking)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "Im still waiting for an instruction.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_for_user_instruction-sp-set_speech_sent
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(robot_info (status stand_by))
	=>
	(assert
		(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	)
)

(defrule wait_for_user_instruction-sp-speech_sent
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ speaking)
	(not
		(robot_info (status stand_by))
	)
	=>
	(retract ?pnpdt_f1__)
	(setTimer 20000 wait_for_user_instruction_speech)
)

(defrule wait_for_user_instruction-sp-try_again
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	?pnpdt_f1__ <-(BB_answer "process_string" parse_instruction 1 "try_again")
	(not
		(BB_sv_updated "recognizedSpeech" ? ? ? $?)
	)
	(not
		(task (plan user_speech))
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(wait_for_user_instruction ?pnpdt_task__ speaking)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "I could not understand please repeat the instruction.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 20000 wait_for_user_instruction_speech)
)

(defrule wait_for_user_instruction-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ success)
	?pnpdt_f2__ <-(wait_for_user_instruction ?pnpdt_task__ finished)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule wait_for_user_instruction-timer-restart
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	?pnpdt_f1__ <-(BB_timer idle_timer)
	(not
		(wait_for_user_instruction ?pnpdt_task__ confirming_speech ?)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ confirmed ?)
	)
	(not
		(confirmation_received ?)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ parsing)
	)
	=>
	(retract ?pnpdt_f1__)
	(setTimer 20000 idle_timer)
)

(defrule wait_for_user_instruction-timer-start
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_for_user_instruction ?pnpdt_task__ sv_cleared)
	(wait_for_user_instruction ?pnpdt_task__ speech_sent)
	(not
		(wait_for_user_instruction ?pnpdt_task__ confirming_speech ?)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ confirmed ?)
	)
	(not
		(confirmation_received ?)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ finished)
	)
	(not
		(BB_timer idle_timer)
	)
	(not
		(wait_for_user_instruction ?pnpdt_task__ parsing)
	)
	=>
	(setTimer 20000 idle_timer)
)

################################
#      FINALIZING RULES
################################

(defrule wait_for_user_instruction-clear-SV
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" $?)
	=>
	(retract ?pnpdt_f1__)
)

(defrule wait_for_user_instruction-clear-flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(wait_for_user_instruction ?pnpdt_task__ $?)
	=>
	(retract ?pnpdt_f1__)
)

(defrule wait_for_user_instruction-clear-task
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(task (plan user_speech))
	=>
	(retract ?pnpdt_f1__)
)

(defrule wait_for_user_instruction-mark_finish_attending
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ failed)
	(attend_person ?task_id executing)
	=>
	(assert
		(attend_person ?task_id finished)
	)
)

################################
#      CANCELING RULES
################################

