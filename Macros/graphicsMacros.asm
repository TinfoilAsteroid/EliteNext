; General Graphics macros
DoubleBufferIfPossible: MACRO
                        IFDEF DOUBLEBUFFER
                            MMUSelectLayer2
                            call  l2_cls
                            call  l2_flip_buffers
                        ENDIF
                        ENDM