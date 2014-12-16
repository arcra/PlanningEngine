(deftemplate task
    (slot id
        (default-dynamic (gensym*))
    )
    (slot plan
        (type LEXEME)
        (default ?NONE)
    )
    (slot action_type
        (type SYMBOL)
        (default ?NONE)
    )
    (multislot params
        (default "")
    )
    (multislot step
        (type INTEGER)
        (default 0)
    )
    (slot parent
        (default nil)
    )
)

(deffacts PE-init_facts
    (PE-last_plan nil)
)
