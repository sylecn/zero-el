;; -*- lexical-binding: t -*-
;; provide emacs interface for zero-pinyin-service dbus service.

;;================
;; implementation
;;================

(require 'dbus)

(defun zero-pinyin-service-error-handler (event error)
  "handle dbus errors"
  (when (or (string-equal "com.emacsos.zero.ZeroPinyinService1"
			  (dbus-event-interface-name event))
	    (s-contains-p "com.emacsos.zero.ZeroPinyinService1" (cadr error)))
    (error "zero-pinyin-service dbus failed: %S" (cadr error))))

(add-hook 'dbus-event-error-functions 'zero-pinyin-service-error-handler)

(defun zero-pinyin-service-async-call (method handler &rest args)
  "call Method on zero-pinin-service asynchronously. This is a wrapper around `dbus-call-method-asynchronously'"
  (apply 'dbus-call-method-asynchronously
	 :session "com.emacsos.zero.ZeroPinyinService1"
	 "/com/emacsos/zero/ZeroPinyinService1"
	 "com.emacsos.zero.ZeroPinyinService1.ZeroPinyinServiceInterface"
	 method handler :timeout 1000 args))

(defun zero-pinyin-service-call (method &rest args)
  "call Method on zero-pinin-service synchronously. This is a wrapper around `dbus-call-method'"
  (apply 'dbus-call-method
	 :session "com.emacsos.zero.ZeroPinyinService1"
	 "/com/emacsos/zero/ZeroPinyinService1"
	 "com.emacsos.zero.ZeroPinyinService1.ZeroPinyinServiceInterface"
	 method :timeout 1000 args))

;;============
;; public API
;;============

(defun zero-pinyin-service-get-candidates (preedit-str fetch-size)
  "get candidates for pinyin in preedit-str synchronously.

preedit-str the preedit-str, should be pure pinyin string
fetch-size try to fetch this many candidates or more"
  (zero-pinyin-service-call "GetCandidates" :string preedit-str :uint32 fetch-size))

(defun zero-pinyin-service-get-candidates-async (preedit-str fetch-size get-candidates-complete)
  "get candidates for pinyin in preedit-str asynchronously.

preedit-str the preedit-str, should be pure pinyin string
fetch-size try to fetch this many candidates or more"
  (zero-pinyin-service-async-call
   "GetCandidates" get-candidates-complete :string preedit-str :uint32 fetch-size))

(defun zero-pinyin-candidate-pinyin-indices-to-dbus-format (candidate_pinyin_indices)
  (let (result)
    (push :array result)
    ;; (push :signature result)
    ;; (push "(ii)" result)
    (dolist (pypair candidate_pinyin_indices)
      (push (list :struct :int32 (first pypair) :int32 (second pypair)) result))
    (reverse result)))

(ert-deftest zero-pinyin-candidate-pinyin-indices-to-dbus-format ()
  (should (equal (zero-pinyin-candidate-pinyin-indices-to-dbus-format '((22 31)))
		 '(:array (:struct :int32 22 :int32 31))))
  (should (equal (zero-pinyin-candidate-pinyin-indices-to-dbus-format
		  '((17 46) (7 55)))
		 '(:array (:struct :int32 17 :int32 46)
			  (:struct :int32 7 :int32 55)))))

(defun zero-pinyin-service-commit-candidate-async (candidate candidate_pinyin_indices)
  "commit candidate asynchronously"
  ;; don't care about the result, so no callback.
  (zero-pinyin-service-async-call
   "CommitCandidate" nil
   :string candidate
   (zero-pinyin-candidate-pinyin-indices-to-dbus-format candidate_pinyin_indices)))

(defun zero-pinyin-service-delete-candidates-async (candidate delete-candidate-complete)
  "delete candidate asynchronously"
  (zero-pinyin-service-async-call
   "DeleteCandidate" delete-candidate-complete :string candidate))

(defun zero-pinyin-service-quit ()
  "quit panel application"
  (zero-pinyin-service-async-call "Quit" nil))

;;================
;; some app test
;;================

(ert-deftest zero-pinyin-service-get-candidates ()
  (destructuring-bind (cs ls &rest rest)
      (zero-pinyin-service-get-candidates "liyifeng" 1)
    (should (equal (first cs) "李易峰"))
    (should (= (first ls) 8)))
  (destructuring-bind (cs ls &rest rest)
      (zero-pinyin-service-get-candidates "wenti" 1)
    (should (equal (first cs) "问题"))
    (should (= (first ls) 5)))
  (destructuring-bind (cs ls &rest rest)
      (zero-pinyin-service-get-candidates "meiyou" 1)
    (should (equal (first cs) "没有"))
    (should (= (first ls) 6)))
  (destructuring-bind (cs ls &rest rest)
      (zero-pinyin-service-get-candidates "shi" 1)
    (should (equal (first cs) "是"))
    (should (= (first ls) 3)))
  (destructuring-bind (cs ls &rest rest)
      (zero-pinyin-service-get-candidates "de" 1)
    (should (equal (first cs) "的"))
    (should (= (first ls) 2))))

(provide 'zero-pinyin-service)