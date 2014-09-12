(deftemplate plan
    (slot task
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
