(clear-all)

(define-model unit2
   
(sgp :v t :show-focus t)

(chunk-type read-letters step)
(chunk-type array letter1 letter2 letter3)

(add-dm 
 (start isa chunk) (find isa chunk) (attend isa chunk) (encode isa chunk)
 (compare isa chunk) (done isa chunk))

(P find-letter
   =goal>
     ISA   read-letters
     step  find
 ==>
   +visual-location>
     :attended  nil
   =goal>
     step  attend
)

(P attend-letter
   =goal>
     ISA   read-letters
     step  attend
   =visual-location>
   ?visual>
     state free
 ==>
   +visual>
     cmd        move-attention
     screen-pos =visual-location
   =goal>
     step  encode
)


(P encode-letter-1
   =goal>
     ISA   read-letters
     step  encode
   =visual>
     ISA   visual-object
     value =L
   ?imaginal>
     buffer empty
     state  free
 ==>
   +imaginal>
     ISA     array
     letter1 =L
   =goal>
     step  find
)

(P encode-letter-2
   =goal>
     ISA   read-letters
     step  encode
   =visual>
     ISA   visual-object
     value =L
   =imaginal>
     ISA     array
     letter1 =L1
     letter2 nil
 ==>
   =imaginal>
     letter2 =L
   =goal>
     step  find
)

(P encode-letter-3
   =goal>
     ISA   read-letters
     step  encode
   =visual>
     ISA   visual-object
     value =L
   =imaginal>
     ISA     array
     letter1 =L1
   - letter1 nil
     letter2 =L2
   - letter2 nil
     letter3 nil
 ==>
   =imaginal>
     letter3 =L
   =goal>
     step  compare
)


(P respond-if-L1-diff
   =goal>
     ISA   read-letters
     step  compare
   =imaginal>
     ISA     array
     letter1 =L1
     letter2 =L2
     letter3 =L2 
   - letter1 =L2 
   ?manual>
     state free
 ==>
   +manual>
     cmd press-key
     key =L1
   =goal>
     step done
)

(P respond-if-L2-diff
   =goal>
     ISA   read-letters
     step  compare
   =imaginal>
     ISA     array
     letter1 =L1
     letter2 =L2
     letter3 =L1 
   - letter2 =L1  
   ?manual>
     state free
 ==>
   +manual>
     cmd press-key
     key =L2
   =goal>
     step done
)

(P respond-if-L3-diff
   =goal>
     ISA   read-letters
     step  compare
   =imaginal>
     ISA     array
     letter1 =L1
     letter2 =L1
     letter3 =L3
   - letter3 =L1 
   ?manual>
     state free
 ==>
   +manual>
     cmd press-key
     key =L3
   =goal>
     step done
)
   
(goal-focus (isa read-letters step find))

)