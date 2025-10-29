(clear-all)

(define-model subtraction-model
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
              borrow-val  
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
    
    (m10-p0  isa count-step current zero  next nine  kind modulo10-pred) 
    (m10-p1  isa count-step current one   next zero  kind modulo10-pred)
    (m10-p2  isa count-step current two   next one   kind modulo10-pred)
    (m10-p3  isa count-step current three next two   kind modulo10-pred)
    (m10-p4  isa count-step current four  next three kind modulo10-pred)
    (m10-p5  isa count-step current five  next four  kind modulo10-pred)
    (m10-p6  isa count-step current six   next five  kind modulo10-pred)
    (m10-p7  isa count-step current seven next six   kind modulo10-pred)
    (m10-p8  isa count-step current eight next seven kind modulo10-pred)
    (m10-p9  isa count-step current nine  next eight kind modulo10-pred)
  )

  ;; ---------------------- GOAL -----------------------
          
   (goal-focus
     (isa math-task operation subtract
           num1-tens one num1-ones two
           num2-tens zero num2-ones eight
           state initialize-ones borrow-val zero))

  ;; ================== STEP 0: INITIALIZE ONES =================
       
  (p initialize-ones-subtraction
     =goal>
       isa math-task 
       operation subtract 
       state initialize-ones
       num1-ones =val1 
       num2-ones =val2
     ==>
     =goal>
       state        count-ones
       current-val  =val1   
       step-count   zero     
       target-steps =val2)    

  ;; ================== STEP 1: ONES COLUMN ===================

  (p sub-ones-handle-borrow-wrap
     =goal>
       isa math-task
       operation subtract
       state   count-ones
       current-val zero      
       step-count =s-val
       target-steps =t-steps
     - step-count =t-steps 
     ==>
     =goal>
       current-val nine      
       borrow-val one       
       state  increment-ones-stepper)

  (p sub-ones-request-prev-val
     =goal>
       isa math-task 
       operation subtract 
       state count-ones
       current-val =curr-v 
       step-count =s-val 
       target-steps =t-steps
     - step-count =t-steps
     - current-val zero     
     ==>
     +retrieval>            
       isa count-step
       current =curr-v
       kind modulo10-pred    
     =goal>
       state wait-ones-prev-val) 

  (p sub-ones-apply-prev-val
     =goal>
       isa math-task 
       operation subtract 
       state wait-ones-prev-val 
       borrow-val =bv 
     =retrieval>             
       isa count-step
       current =curr-v 
       next    =prev-v
       kind modulo10-pred
     ==>
     =goal>
       current-val =prev-v   
       borrow-val =bv       
       state  increment-ones-stepper)

  (p sub-ones-request-stepper-inc
     =goal>
       isa math-task 
       operation subtract 
       state increment-ones-stepper 
       step-count =s-val
     ==>
     +retrieval>             
       isa count-step
       current =s-val
       kind natural          
     =goal>
       state apply-ones-stepper-inc) 

  (p sub-ones-apply-stepper-inc
     =goal>
       isa math-task 
       operation subtract 
       state apply-ones-stepper-inc
     =retrieval>             
       isa count-step
       current =s-val 
       next    =s-next
       kind natural
     ==>
     =goal>
       step-count =s-next   
       state   count-ones)   

  (p sub-ones-finish
     =goal>
       isa math-task
       operation subtract
       state   count-ones
       current-val =final-ones-val
       step-count =t-steps
       target-steps =t-steps
     ==>
     =goal>
       result-ones =final-ones-val
       state    initialize-tens)
	  
  ;; ================== STEP 2: TENS COLUMN ===================

  (p initialize-tens-subtraction
     =goal>
       isa math-task 
       operation subtract
       state initialize-tens
       num1-tens =val1 
       num2-tens =val2 
       borrow-val =bv 
     ==>
     =goal>
       state   tens-consume-borrow 
       current-val  =val1
       target-steps  =val2
       step-count   zero
       borrow-val  =bv)

  (p sub-tens-apply-borrow
     =goal>
       isa math-task 
       operation subtract 
       state tens-consume-borrow
       borrow-val one         
       current-val =curr-v
     ==>
     +retrieval>           
       isa count-step
       current =curr-v
       kind modulo10-pred     
     =goal>
       state wait-tens-borrow-apply) 

  (p sub-tens-finish-borrow-apply
     =goal>
       isa math-task 
       operation subtract 
       state wait-tens-borrow-apply
     =retrieval>             
       isa count-step
       current =curr-v 
       kind modulo10-pred
     ==>
     =goal>
       current-val =prev-v    
       borrow-val zero        
       state  count-tens)    

  (p sub-tens-skip-borrow
     =goal>
       isa math-task 
       operation subtract 
       state tens-consume-borrow
       borrow-val zero        
     ==>
     =goal> 
       state count-tens)     

  (p sub-tens-request-prev-val
     =goal>
       isa math-task 
       operation subtract 
       state count-tens
       current-val =curr-v 
       step-count =s-val 
       target-steps =t-steps
       borrow-val zero        
     - step-count =t-steps
     ==>
     +retrieval>              
       isa count-step
       current =curr-v
       kind modulo10-pred      
     =goal>
       state wait-tens-prev-val) 

  (p sub-tens-apply-prev-val
     =goal>
       isa math-task 
       operation subtract 
       state wait-tens-prev-val
     =retrieval>              
       isa count-step
       current =curr-v 
       next    =prev-v
       kind modulo10-pred
     ==>
     =goal>
       current-val =prev-v    
       state  increment-tens-stepper) 

  (p sub-tens-request-stepper-inc
     =goal>
       isa math-task 
       operation subtract 
       state increment-tens-stepper 
       step-count =s-val
     ==>
     +retrieval>             
       isa count-step
       current =s-val
       kind natural
     =goal>
       state apply-tens-stepper-inc) 

  (p sub-tens-apply-stepper-inc
     =goal>
       isa math-task 
       operation subtract 
       state apply-tens-stepper-inc
     =retrieval>             
       isa count-step
       current =s-val 
       next    =s-next
       kind natural
     ==>
     =goal>
       step-count =s-next    
       state   count-tens)    
       
  (p sub-tens-finish
     =goal>
       isa math-task
       operation subtract
       state   count-tens      
       current-val =final-tens-val
       step-count =t-steps
       target-steps =t-steps
       result-ones =r-ones
     ==>
     =goal>
       result-tens =final-tens-val 
       state    report-result  
     !output! (The difference is =final-tens-val =r-ones))

  ;; ================== STEP 3: FINISH/REPORT ===================

  (p finish-task
     =goal>
       isa math-task 
       state report-result
     ==>
     -goal>) 
)