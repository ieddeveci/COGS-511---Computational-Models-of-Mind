(clear-all)

(define-model addition-model
  (sgp :esc t :lf .05 :trace-detail low) 

  ;; ---------------------- CHUNK TYPES ------------------------
  (chunk-type number number-value) 
  (chunk-type count-step current next kind) 
  
  (chunk-type math-task
              operation 
              num1-tens num1-ones 
              num2-tens num2-ones 
              state 
              current-val 
              step-count  
              target-steps
              carry-val           ; Carry FROM Ones to Tens
              carry-hundreds-val  ; Carry FROM Tens to Hundreds 
              result-ones result-tens) 

  ;; ---------------------- DECLARATIVE MEMORY ----------------
  (add-dm
    (n0 isa number number-value zero) (n1 isa number number-value one) 
    (n2 isa number number-value two) (n3 isa number number-value three)
    (n4 isa number number-value four) (n5 isa number number-value five) 
    (n6 isa number number-value six) (n7 isa number number-value seven)
    (n8 isa number number-value eight) (n9 isa number number-value nine) 
    (n10 isa number number-value ten) 

    (cs0  isa count-step current zero  next one   kind natural)
    (cs1  isa count-step current one   next two   kind natural)
    (cs2  isa count-step current two   next three kind natural)
    (cs3  isa count-step current three next four  kind natural)
    (cs4  isa count-step current four  next five  kind natural)
    (cs5  isa count-step current five  next six   kind natural)
    (cs6  isa count-step current six   next seven kind natural)
    (cs7  isa count-step current seven next eight kind natural)
    (cs8  isa count-step current eight next nine  kind natural)
    (cs9  isa count-step current nine  next ten   kind natural)

    (m10-s0  isa count-step current zero  next one   kind modulo10-succ)
    (m10-s1  isa count-step current one   next two   kind modulo10-succ)
    (m10-s2  isa count-step current two   next three kind modulo10-succ)
    (m10-s3  isa count-step current three next four  kind modulo10-succ)
    (m10-s4  isa count-step current four  next five  kind modulo10-succ)
    (m10-s5  isa count-step current five  next six   kind modulo10-succ)
    (m10-s6  isa count-step current six   next seven kind modulo10-succ)
    (m10-s7  isa count-step current seven next eight kind modulo10-succ)
    (m10-s8  isa count-step current eight next nine  kind modulo10-succ)
    (m10-s9  isa count-step current nine  next zero  kind modulo10-succ)
  )

  ;; ---------------------- GOAL -----------------------
  
   (goal-focus
     (isa math-task operation add
           num1-tens zero num1-ones seven  
           num2-tens zero num2-ones two
           state initialize-ones 
           carry-val zero 
           carry-hundreds-val zero)) 
		   
  ;; ================== STEP 0: INITIALIZE ONES =================
  
  (p initialize-ones-addition
     =goal>
       isa math-task operation add state initialize-ones
       num1-ones =val1 num2-ones =val2
     ==>
     =goal>
       state        count-ones 
       current-val  =val1      
       step-count   zero       
       target-steps =val2)     

  ;; ================== STEP 1: ONES COLUMN ===================
  
  (p add-ones-handle-carry-wrap 
     =goal>
       isa math-task operation add state count-ones
       current-val nine step-count =s-val target-steps =t-steps
     - step-count =t-steps  
     ==>
     =goal>
       current-val zero      
       carry-val  one       
       state  increment-ones-stepper) 

  (p add-ones-request-next-val 
     =goal>
       isa math-task operation add state count-ones
       current-val =curr-v step-count =s-val target-steps =t-steps
     - step-count =t-steps
     - current-val nine      
     ==>
     +retrieval>             
       isa count-step
       current =curr-v
       kind modulo10-succ    
     =goal>
       state wait-ones-next-val) 

  (p add-ones-apply-next-val 
     =goal>
       isa math-task operation add state wait-ones-next-val
     =retrieval>             
       isa count-step
       current =curr-v 
       next    =next-v
       kind modulo10-succ
     ==>
     =goal>
       current-val =next-v   
       state  increment-ones-stepper) 

  (p add-ones-request-stepper-inc 
     =goal>
       isa math-task operation add state increment-ones-stepper
       step-count =s-val
     ==>
     +retrieval>             
       isa count-step
       current =s-val
       kind natural          
     =goal>
       state apply-ones-stepper-inc) 

  (p add-ones-apply-stepper-inc 
     =goal>
       isa math-task operation add state apply-ones-stepper-inc
     =retrieval>             
       isa count-step
       current =s-val 
       next    =s-next
       kind natural
     ==>
     =goal>
       step-count =s-next    
       state   count-ones)   

  (p add-ones-finish 
     =goal>
       isa math-task operation add state count-ones
       current-val =final-ones-val step-count =t-steps target-steps =t-steps 
     ==>
     =goal>
       result-ones =final-ones-val 
       state    initialize-tens)  

  ;; ================== STEP 2: TENS COLUMN ===================

  (p initialize-tens-addition 
     =goal>
       isa math-task operation add state initialize-tens
       num1-tens =val1 num2-tens =val2 carry-val =cv 
     ==>
     =goal>
       state   check-tens-initial-carry 
       current-val  =val1      
       step-count   zero       
       target-steps =val2      
       carry-val    =cv)       

  (p add-tens-initial-carry-request 
     =goal>
       isa math-task operation add state check-tens-initial-carry
       carry-val one current-val =curr-v         
     ==>
     +retrieval>              
       isa count-step
       current =curr-v    
       kind modulo10-succ 
     =goal>
       state wait-tens-initial-carry-apply) 

  (p add-tens-initial-carry-apply
     =goal>
       isa math-task operation add state wait-tens-initial-carry-apply
     =retrieval>              
       isa count-step
       current =curr-v 
       next    =next-v
       kind modulo10-succ 
     ==>
     =goal>             
       current-val =next-v    
       carry-val  zero 
       state  count-tens)  

  (p add-tens-skip-initial-carry
     =goal>
       isa math-task operation add state check-tens-initial-carry
       carry-val zero        
     ==>
     =goal>
       state count-tens) 

  (p add-tens-handle-carry-wrap
     =goal>
       isa math-task operation add state count-tens
       current-val nine 
       step-count =s-val target-steps =t-steps
       carry-hundreds-val zero 
     - step-count =t-steps  
     ==>
     =goal>
       current-val zero      
       carry-hundreds-val  one
       state  increment-tens-stepper) 

  (p add-tens-request-next-val
     =goal>
       isa math-task operation add state count-tens
       current-val =curr-v 
       step-count =s-val target-steps =t-steps
       carry-val zero         
     - step-count =t-steps
     - current-val nine      
     ==>
     +retrieval>              
       isa count-step
       current =curr-v
       kind modulo10-succ           
     =goal>
       state wait-tens-next-val) 

  (p add-tens-apply-next-val
     =goal>
       isa math-task operation add state wait-tens-next-val
     =retrieval>              
       isa count-step
       current =curr-v 
       next    =next-v
       kind modulo10-succ 
     ==>
     =goal>
       current-val =next-v    
       state  increment-tens-stepper) 

  (p add-tens-request-stepper-inc
     =goal>
       isa math-task operation add state increment-tens-stepper
       step-count =s-val
     ==>
     +retrieval>              
       isa count-step
       current =s-val
       kind natural
     =goal>
       state apply-tens-stepper-inc) 

  (p add-tens-apply-stepper-inc
     =goal>
       isa math-task operation add state apply-tens-stepper-inc
     =retrieval>              
       isa count-step
       current =s-val 
       next    =s-next
       kind natural
     ==>
     =goal>
       step-count =s-next     
       state   count-tens)    
       
  (p add-tens-finish 
     =goal>
       isa math-task operation add state count-tens       
       current-val =final-tens-val 
       step-count =t-steps          
       target-steps =t-steps
       carry-val zero              
     ==>
     =goal>
       result-tens =final-tens-val 
       state    report-result)   

  ;; ================== STEP 3: FINISH/REPORT ===================

  (p report-2-digit-sum
     =goal>
       isa math-task state report-result
       operation add
       carry-hundreds-val zero 
       result-tens =rt
       result-ones =ro
     ==>
     !output! (The sum is =rt =ro)
     -goal>) 

  (p report-3-digit-sum
     =goal>
       isa math-task state report-result
       operation add
       carry-hundreds-val one 
       result-tens =rt        
       result-ones =ro
     ==>
     !output! (The sum is one =rt =ro) 
     -goal>)
)