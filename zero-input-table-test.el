;;; zero-input-table-test.el --- tests for zero-input-table.el -*- no-byte-compile: t; lexical-binding: t -*-

;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

;;; Commentary:

;;

;;; Code:

(require 'zero-input-table)
(require 'ert)

(ert-deftest zero-input-table-build-candidates ()
  (should (equal (zero-input-table-build-candidates "ph") '("18612345678")))
  (should (equal (zero-input-table-build-candidates "m")
		 '("https://msdn.microsoft.com/en-us"
		   "foo@example.com"
		   "https://ditu.amap.com/"))))

(ert-deftest zero-input-table-can-start-sequence ()
  (should (zero-input-table-can-start-sequence ?a))
  (should (zero-input-table-can-start-sequence ?m))
  (should-not (zero-input-table-can-start-sequence ?1))
  (should-not (zero-input-table-can-start-sequence ?b)))

(provide 'zero-input-table-test)

;;; zero-input-table-test.el ends here
