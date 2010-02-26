(in-package :fork-future-test)

(in-suite root-suite)

(defsuite* unit-test)

(deftest 1+1-is-2 ()
  (assert-no-futures)
  (is (= 2 (touch (future (+ 1 1)))))
  (is (= 2 (touch (future (print 'hello) (+ 1 1)))))
  (assert-no-futures))

(deftest error-test ()
  (assert-no-futures)
  (signals error (touch (future (error "error test"))))
  (assert-no-futures))

(deftest future-test ()
  (assert-no-futures)
  (let ((f1 (future (sleep 0.1) (+ 1 1)))
        (f2 (future (sleep 0.2) (+ 1 1))))
    (is (= 2 (futures-count)))
    (is (= 4 (+ (touch f1) (touch f2)))))
  (assert-no-futures))

(deftest wait-for-future-test ()
  (assert-no-futures)
  (let ((f (future (sleep 0.1) (+ 1 1))))
    (is (= 1 (running-futures-count)))
    (is (= 0 (pending-futures-count)))
    (wait-for-future f)
    (assert-no-futures)
    (is (not (eq (fork-future::result-of f) 'fork-future::unbound)))
    (is (= 2 (touch f)))))

(deftest wait-for-all-futures-test ()
  (assert-no-futures) 
  (let ((f1 (future (sleep 0.1) (+ 1 1)))
        (f2 (future (sleep 0.2) (+ 1 1)))
        (f3 (future (+ 1 1))))
    (is (= 3 (futures-count)))
    (wait-for-all-futures)
    (assert-no-futures)
    (is (every (lambda (f) (not (eq (fork-future::result-of f) 'fork-future::unbound)))
               (list f1 f2 f3)))
    (is (= 6 (+ (touch f1) (touch f2) (touch f3))))))

(deftest kill-future-test ()
  (assert-no-futures)
  (let* ((f (future (+ 1 1)))
         (pid (fork-future::pid-of f)))
    (is (= 1 (running-futures-count)))
    (is (= 0 (pending-futures-count)))
    (sleep 0.5)
    (kill-future f)
    (assert-no-futures)
    (is (not (probe-file (format nil fork-future::*future-result-file-template* pid))))
    (is (> 0 (fork-future::wait)))
    (is (> 0 (fork-future::waitpid 0)))))

(deftest kill-future-force-test ()
  (assert-no-futures)
  (let* ((f (future (+ 1 1)))
         (pid (fork-future::pid-of f)))
    (is (= 1 (running-futures-count)))
    (is (= 0 (pending-futures-count)))
    (sleep 0.5)
    (kill-future f t)
    (assert-no-futures)
    (is (not (probe-file (format nil fork-future::*future-result-file-template* pid))))
    (is (> 0 (fork-future::wait)))
    (is (> 0 (fork-future::waitpid 0)))))

(deftest kill-all-futures-test ()
  (assert-no-futures)
  (let* ((f1 (future (+ 1 1)))
         (f2 (future (sleep 0.5) (+ 1 1)))
         (f3 (future (sleep 1) (+ 1 1))))
    (is (= 3 (futures-count)))
    (sleep 0.5)
    (kill-all-futures)
    (assert-no-futures)
    (is (every (lambda (f) (not (probe-file (format nil fork-future::*future-result-file-template*
                                                    (fork-future::pid-of f)))))
               (list f1 f2 f3)))
    (is (> 0 (fork-future::wait)))
    (is (> 0 (fork-future::waitpid 0)))))

(deftest kill-all-futures-force-test ()
  (assert-no-futures)
  (let* ((f1 (future (+ 1 1)))
         (f2 (future (sleep 0.5) (+ 1 1)))
         (f3 (future (sleep 1) (+ 1 1))))
    (is (= 3 (futures-count)))
    (sleep 0.5)
    (kill-all-futures t)
    (assert-no-futures) 
    (is (every (lambda (f) (not (probe-file (format nil fork-future::*future-result-file-template*
                                                    (fork-future::pid-of f)))))
               (list f1 f2 f3)))
    (is (> 0 (fork-future::wait)))
    (is (> 0 (fork-future::waitpid 0)))))


