;-Camera Position of Ship----------------------------------------------------------------------------------------------------------
UBnKxlo                     DB  0                       ; INWK+0
UBnKxhi                     DB  0                       ; there are hi medium low as some times these are 24 bit
UBnKxsgn                    DB  0                       ; INWK+2
UBnKylo                     DB  0                       ; INWK+3 \ ylo
UbnKyhi                     DB  0                       ; INWK+4 \ yHi
UBnKysgn                    DB  0                       ; INWK +5
UBnKzlo                     DB  0                       ; INWK +6
UBnKzhi                     DB  0                       ; INWK +7
UBnKzsgn                    DB  0                       ; INWK +8

INWKxlo                     equ UBnKxlo
INWKxhi                     equ UBnKxhi                 ; there are hi medium low as some times these are 24 bit
INWKxsgn                    equ UBnKzsgn                ; INWK+2
INWKyLo                     equ UBnKylo                 ; INWK+3 \ ylo
INWKyhi                     equ UbnKyhi                 ; Y Hi???
INWKysgn                    equ UBnKysgn                ; INWK +5
INWKzlo                     equ UBnKzlo                 ; INWK +6
INWKzhi                     equ UBnKzhi                 ; INWK +7
INWKzsgn                    equ UBnKzsgn                ; INWK +8