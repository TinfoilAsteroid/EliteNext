; General Graphics macros
DoubleBufferIfPossible: MACRO
                        IFDEF DOUBLEBUFFER
                            MMUSelectLayer2
                            call  l2_cls
                            call  l2_flip_buffers
                        ENDIF
                        ENDM

DoubleBuffer320IfPossible: MACRO
                        IFDEF DOUBLEBUFFER
                            MMUSelectLayer2
                            call  l2_320_cls
                            call  l2_flip_buffers
                        ENDIF
                        ENDM                        
                        
DoubleBuffer640IfPossible: MACRO
                        IFDEF DOUBLEBUFFER
                            MMUSelectLayer2
                            call  l2_640_cls
                            call  l2_flip_buffers
                        ENDIF
                        ENDM                        
                        